//
//  BlueManager.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth
import STCore

public enum FirmwareServiceType {
    case stm32
    case blueNrg
    case debugConsole
    case unknown
}

public protocol BlueSTManager {
    /**
     *  Get all the discovered nodes
     *
     *  @return array of {@link STBlueSDKNode} with all the discovered nodes
     */
    var discoveredNodes: [Node] { get }

    func discoveryStart()
    func discoveryStart(_ timeout: Int, delay: Int)
    func discoveryStart(_ timeout: Int, delay: Int, advertiseFilters: [AdvertiseFilter])

    /**
     *  Stop the discovery process
     */
    func discoveryStop()
    /**
     *  Remove all the discovered nodes
     *  @param force if true remove also the connected nodes
     */
    func resetDiscovery(_ disconnectAll: Bool)

    func addDelegate(_ delegate: BlueDelegate)
    func removeDelegate(_ delegate: BlueDelegate)

    func connect(_ node: Node)
    func disconnect(_ node: Node)

    func enableNotifications(for node: Node, feature: Feature)
    func disableNotifications(for node: Node, feature: Feature)
    
    func enableNotifications(for node: Node, features: [Feature])
    func disableNotifications(for node: Node, features: [Feature])
    
    func read(feature: Feature, for node: Node, delegate: BlueDelegate)
    
    func updateCatalog(with environment: Environment, completion: @escaping (Catalog?, STError?) -> Void)
    func updateDtmi(with environment: Environment, firmware: Firmware, completion: @escaping ([PnpLContent], STError?) -> Void)

    func add(customFirmwareToCatalog firmware: Firmware) -> Catalog?
    func removeCustomFirmware(for node: Node) -> Catalog?

    func ignoreFirmwareUpdate(_ firmware: Firmware, deviceTag: String)
    func isFirmwareUpdateIgnored(_ firmware: Firmware, deviceTag: String) -> Bool

    /**
     *  add a new node and call all the delegate for notify the discovery of a new node
     *
     *  @param node new discovered node
     */
    func addVirtualNode()

    func sendCommand(_ command: FeatureCommand, to node: Node, feature: Feature) -> Bool

    func sendMessage(_ message: String, to node: Node, completion: DebugConsoleCallback) -> Bool

    func sendECCommand(_ type: ECCommandType, to node: Node) -> Bool
    func sendECCommand(_ type: ECCommandType, int: Int, to node: Node) -> Bool
    func sendECCommand<T: Encodable>(_ type: ECCommandType, json: T, to node: Node) -> Bool
    func sendECCommand(_ commandName: String, to node: Node) -> Bool
    func sendECCommand(_ commandName: String, string: String, to node: Node) -> Bool
    func sendECCommand(_ commandName: String, int: Int, to node: Node) -> Bool

    func sendHSDGetCommand(_ command: HSDGetCmd, to node: Node)  -> Bool
    func sendHSDSetCommand(_ command: HSDSetCmd, to node: Node, completion: @escaping () -> Void)  -> Bool
    func sendHSDControlCommand(_ command: HSDControlCmd, to node: Node)  -> Bool
    func sendHSDCommand(_ command: String?, to node: Node, completion: @escaping () -> Void)  -> Bool

    func sendPnpLCommand(_ command: PnpLCommand, to node: Node, feature: Feature)  -> Bool

    func firmwareUpgrade(for node: Node, type: FirmwareType, url: URL, catalog: Catalog, callback: FirmwareUpgradeCallback)
    
    func firmwareServiceType(for node: Node) -> FirmwareServiceType

    func readRSSI(for node: Node)

}

public typealias BlueDiscovering = (_ manager: BlueManager, _ discoveredNode: Node) -> Void

public class BlueManager : NSObject, BlueSTManager {

    internal static let retryStartScanningDelay = TimeInterval(0.5)
    internal static let defaultAdvertiseFilter: [AdvertiseFilter] = [AdvertiseParser(), BlueNRGOtaAdvertiseParser()]

    public let featureLogger = FeatureFileLogger()

    public static let shared = BlueManager()

    public var discoveredNodes: [Node] {
        if let favoritesService: FavoritesService = Resolver.shared.resolve() {
            return nodeServices.map {
                $0.node
            }.sorted { first, second in
                return favoritesService.isFavorite(node: first) && !favoritesService.isFavorite(node: second)
            }
        }
        return nodeServices.map { $0.node }
    }

    public var catalog: Catalog? {
        if let catalogService: CatalogService = Resolver.shared.resolve() {
            return catalogService.catalog
        }
        return nil
    }

    internal var nodeServices: [NodeService] = []

    /**
     *  Tell if the manager is in a discovery state
     *
     *  @return true if the manager is seaching for new nodes
     */
    internal(set) public var isDiscovering: Bool = false
    internal var firmwareService: FirmwareService?

    private var discoveringCallbacks: [WeakCallback<BlueDiscovering>] = []

    public var delegates: [WeakObject<BlueDelegate>] = [WeakObject<BlueDelegate>]()

    internal let notificationQueue = DispatchQueue(label: "BlueManager", qos: .background, attributes: .concurrent)
    internal var centralManager: CBCentralManager!
    internal var advertiseFilters: [AdvertiseFilter] = BlueManager.defaultAdvertiseFilter
    internal var timeoutWorkItem: DispatchWorkItem?
    internal var delayWorkItem: DispatchWorkItem?

    private override init() {
        super.init()

        centralManager = CBCentralManager(delegate: self, queue: nil)        
    }

    public func addVirtualNode() {

// TODO: Add virtual node

//        if let node = STBlueSDKNodeFake() {
//            addAndNotify(node: node)
//        }
    }

    public func removeDelegate(_ delegate: BlueDelegate) {
        if let index = delegates.firstIndex(where: { $0.refItem === delegate }) {
            delegates.remove(at: index)
        }
    }

    public func addDelegate(_ delegate: BlueDelegate) {
        guard delegates.firstIndex(where: { $0.refItem === delegate }) == nil else { return }
        delegates.append(WeakObject(refItem: delegate))
    }

    public func addDiscoveringCallback(_ callback: WeakCallback<BlueDiscovering>) {
        cleanupCallback()
        discoveringCallbacks.append(callback)
    }

    public func cleanupCallback() {
        discoveringCallbacks = discoveringCallbacks.filter { cb -> Bool in
            if (cb.refItem == nil) {
                STBlueSDK.log(text: "\(cb.id) has nil reference, will be removed")
                return false
            }
            return true
        }
    }

    public func connect(_ node: Node) {
        guard centralManager.state == .poweredOn else { return }

        if node.isConnected {
            notify(node: node)
            return
        }

        centralManager.connect(node.peripheral, options: nil)
    }

    public func disconnect(_ node: Node) {
        guard centralManager.state == .poweredOn else { return }
        centralManager.cancelPeripheralConnection(node.peripheral)
    }

    public func readRSSI(for node: Node) {
        if let nodeService = nodeServices.nodeService(with: node) {
            nodeService.readRSSI()
        }
    }
}

private extension BlueManager {

    func addAndNotify(node: Node) {
        cleanupCallback()

        guard nodeServices.nodeService(with: node) == nil else { return }

        nodeServices.append(NodeService(node: node, delegate: self))

        notify(node: node)
    }

    func notify(node: Node) {
        delegates.forEach { delegate in
            notificationQueue.async { [weak self] in
                guard let self = self else { return }
                guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
                weakDelegate.manager(self, didDiscover: node)
            }
        }

        discoveringCallbacks.forEach { weakCallback in
            notificationQueue.async { [weak self] in
                guard let self = self else { return }
                if weakCallback.refItem != nil {
                    weakCallback.callback(self, node)
                }
            }
        }
    }
}

extension BlueManager: CBCentralManagerDelegate {

    public func centralManager(_ central: CBCentralManager,
                               didDiscover peripheral: CBPeripheral,
                               advertisementData: [String : Any],
                               rssi RSSI: NSNumber) {

        let uuid = peripheral.identifier.uuidString
        if let node = discoveredNodes.nodeWith(tag: uuid) {
            node.rssi = Int(truncating: RSSI)
            if node.peripheral != peripheral {
                node.peripheral = peripheral
            }
            notify(node: node)
        } else {
            let firstMatch = advertiseFilters.lazy.compactMap { $0.filter(advertisementData) }.first
            if let info = firstMatch {
                let newNode = Node(peripheral: peripheral,
                                   rssi: Int(truncating: RSSI),
                                   advertiseInfo: info)
                addAndNotify(node: newNode)
            }
        }
    }

    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        if central.state != .poweredOn {
            isDiscovering = false
        }
    }

    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        if let node = discoveredNodes.nodeWith(tag: peripheral.identifier.uuidString),
            let nodeService = nodeServices.nodeService(with: node) {
            nodeService.discoverServices()
        }
    }

    public func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        if let node = discoveredNodes.nodeWith(tag: peripheral.identifier.uuidString) {
            delegates.forEach { delegate in
                notificationQueue.async { [weak self] in
                    guard let self = self else { return }
                    guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
                    weakDelegate.manager(self, didChangeStateFor: node)
                }
            }
        }
    }

    public func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        if let node = discoveredNodes.nodeWith(tag: peripheral.identifier.uuidString) {
            STBlueSDK.log(text: "DISCONNECT Node: \(node.name ?? "n/a") - Error: \(error?.localizedDescription ?? "n/a")")
            node.state = .disconnected

            delegates.forEach { delegate in
                notificationQueue.async { [weak self] in
                    guard let self = self else { return }
                    guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
                    weakDelegate.manager(self, didChangeStateFor: node)
                }
            }
        }
    }
}

extension BlueManager: NodeServiceDelegate {

    public func service(_ service: NodeService, didReadRSSIFor node: Node, error: Error?) {
        delegates.forEach { delegate in
            guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
            weakDelegate.manager(self, didChangeStateFor: node)
        }
    }

    public func service(_ service: NodeService, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        
        delegates.forEach { delegate in
            guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
            weakDelegate.manager(self, didUpdateValueFor: node, feature: feature, sample: sample)
        }
    }

    public func service(_ service: NodeService, didCompleteDiscoverWith error: Error?) {
        service.node.state = .connected
        
        delegates.forEach { delegate in
            notificationQueue.async { [weak self] in
                guard let self = self else { return }
                guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
                weakDelegate.manager(self, didChangeStateFor: service.node)
            }
        }
    }

    public func service(_ service: NodeService, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        delegates.forEach { delegate in
            notificationQueue.async { [weak self] in
                guard let self = self else { return }
                guard let weakDelegate = delegate.refItem as? BlueDelegate else { return }
                weakDelegate.manager(self, didReceiveCommandResponseFor: node, feature: feature, response: response)
            }
        }
    }
}

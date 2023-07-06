//
//  NodeService.swift
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

public protocol NodeServiceDelegate: AnyObject {

    func service(_ service: NodeService, didCompleteDiscoverWith error: Error?)

    func service(_ service: NodeService, didReadRSSIFor node: Node, error: Error?)

    func service(_ service: NodeService, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?)

    func service(_ service: NodeService, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse)
}

public class NodeService {
    var node: Node
    var bleService: BleService
    var debugConsole: DebugConsole?
    let unwrapTimestamp = UnwrapTimeStamp()
    var writeDataManager: WriteDataManager

    var debug: Bool = true

    weak var delegate: NodeServiceDelegate?

    public init(node: Node, delegate: NodeServiceDelegate) {
        self.node = node
        self.delegate = delegate
        self.bleService = BleService(with: node.peripheral)
        self.writeDataManager = WriteDataManager(bleService: bleService)
        
        bleService.addDelegate(self)
    }

    deinit {
        bleService.removeDelegate(self)

        if let debugConsole = debugConsole {
            bleService.removeDelegate(debugConsole)
        }
    }
}

public extension NodeService {

    func discoverServices() {
        bleService.discoverServices(for: node.peripheral)
    }

    func update(node: Node) {
        self.node = node
        self.bleService.peripheral = node.peripheral
    }

    func readRSSI() {
        node.peripheral.readRSSI()
    }
}

extension NodeService: BleServiceDelegate {
    func service(_ bleService: BleService, didReadRSSI RSSI: NSNumber, error: Error?) {
        node.rssi = RSSI.intValue
        self.delegate?.service(self, didReadRSSIFor: node, error: error)
    }

    func service(_ bleService: BleService, didDiscoverServices services: [CBService], error: Error?) {
        if error != nil {
            node.state = .disconnected
            delegate?.service(self, didCompleteDiscoverWith: error)
            return
        }

        node.characteristics.removeAll()

        for service in services {
            if service.isDebugService {
                guard let characteristics = service.characteristics else {
                    return
                }

                node.characteristics.append(contentsOf: characteristics.compactMap {
                    BlueCharacteristic(characteristic:$0,
                                       features: [],
                                       maxMtu: node.peripheral.maximumWriteValueLength(for: .withoutResponse))
                })

                if let debugConsole = DebugConsole.create(with: bleService, service: service) {
                    self.debugConsole = debugConsole
                }

            } else if service.isConfigService {
                guard let characteristics = service.characteristics else {
                    return
                }

                node.characteristics.append(contentsOf: characteristics.compactMap {
                    BlueCharacteristic(characteristic:$0,
                                       features: [],
                                       maxMtu: node.peripheral.maximumWriteValueLength(for: .withoutResponse))
                })

                STBlueSDK.log(text: "Create config characteristics done")
            } else {
                guard let characteristics = service.characteristics else {
                    return
                }

                node.characteristics.append(contentsOf: characteristics.compactMap {
                    $0.buildBlueCharacteristic(with: node.availableFeatureTypes,
                                               protocolVersion: node.protocolVersion,
                                               advertisingMask: node.advertisingMask,
                                               maxMtu: node.peripheral.maximumWriteValueLength(for: .withoutResponse))
                })

                STBlueSDK.log(text: "Create standard characteristics done")
            }
        }

        delegate?.service(self, didCompleteDiscoverWith: error)
    }

    func service(_ bleService: BleService, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: Error?) {

        if let error = error {
            STBlueSDK.log(text: "\(error.localizedDescription)")
            return
        }

        guard let data = characteristic.value else {
            STBlueSDK.log(text: "Receive a notification for a characteristic: \(characteristic.uuid.uuidString) with no data")
            return
        }

        if characteristic.isDebugCharacteristic {
            updateValueForDebugConsoleCharacteristic(characteristic, data: data)
//        } else if characteristic.isConfigFeatureCommandCharacteristic || isWaitingForCommandResponse {
        } else if characteristic.isConfigFeatureCommandCharacteristic {
            updateValueForCommandFeatureCharacteristic(characteristic, data: data)
        } else if characteristic.isFeatureCaracteristics ||
                    characteristic.isExternalCharacteristics ||
                    characteristic.isExtendedFeatureCaracteristics {
            updateValueForStandardFeatureCharacteristic(characteristic, data: data)
        }
    }

    func service(_ bleService: BleService, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        
    }

    func service(_ bleService: BleService, didLostPeripheral peripheral: CBPeripheral, error: Error?) {

    }
}

private extension NodeService {

    func updateValueForCommandFeatureCharacteristic(_ characteristic: CBCharacteristic, data: Data) {

        guard let response = BaseCommandResponse.parse(data) else {
            STBlueSDK.log(text: "Responde data not valid for a characteristic: \(characteristic.uuid.uuidString)")
            return
        }

        guard let feature = FeatureType.feature(from: response.featureMask,
                                                types: node.availableFeatureTypes) else {
            STBlueSDK.log(text: "Receive a response for the feature \(characteristic.uuid.uuidString) that is not handle by this node")
            return
        }

        delegate?.service(self,
                          didReceiveCommandResponseFor: node,
                          feature: feature,
                          response: feature.parse(commandResponse: response))
    }

    func updateValueForDebugConsoleCharacteristic(_ characteristic: CBCharacteristic, data: Data) {
        // NOT USED
    }

    func updateValueForStandardFeatureCharacteristic(_ characteristic: CBCharacteristic, data: Data) {
        guard var blueChar = node.characteristics.first(where: { $0.characteristic.uuid == characteristic.uuid }) else { return }

        if blueChar.features.count == 0 {
            STBlueSDK.log(text: "Receive a notification for a characteristic: \(blueChar.characteristic.uuid.uuidString) that isn't handle by the sdk")
            return
        }

        let timestamp = unwrapTimestamp.current(with: data)

        blueChar.parse(data, timestamp: timestamp) { [weak self] feature, lastSample in
            guard let self = self else { return }
            self.delegate?.service(self, didUpdateValueFor: self.node, feature: feature, sample: lastSample)
            if feature.isEnabled {
                BlueManager.shared.featureLogger.log(feature: feature, node: self.node)
            }
        }
    }
}

//
//  BlueService.swift
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

internal protocol BleServiceDelegate: AnyObject {

    func service(_ bleService: BleService, didDiscoverServices services: [CBService], error: Error?)

    func service(_ bleService: BleService, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: Error?)

    func service(_ bleService: BleService, didWriteValueFor characteristic: CBCharacteristic, error: Error?)

    func service(_ bleService: BleService, didLostPeripheral peripheral: CBPeripheral, error: Error?)

    func service(_ bleService: BleService, didReadRSSI RSSI: NSNumber, error: Error?)

}

internal class BleService: NSObject {
    
    private let notificationQueue = DispatchQueue(label: "NotificationQueue")

    var peripheral: CBPeripheral {
        didSet {
            peripheral.delegate = self
        }
    }

    var writeCallbacks: [WeakWriteCallBack] = [WeakWriteCallBack]()
    var delegates: [Object] = [Object]()

    var latestError: Error?
    var isDiscoveringServices: Bool = false

    var discoveredServices = [CBService]()

    init(with peripheral: CBPeripheral) {

        self.peripheral = peripheral

        super.init()

        self.peripheral.delegate = self
    }

    deinit {
        STBlueSDK.log(text: "DEINIT BLESERVICE")
    }
}

private extension BleService {
    func cleanupCallback() {
        writeCallbacks = writeCallbacks.filter { cb -> Bool in
            if (cb.refItem == nil) {
                STBlueSDK.log(text: "\(cb.id) has nil reference, will be removed")
                return false
            }
            return true
        }
    }

    func cleanupDelegates() {
        delegates = delegates.filter { delegate -> Bool in
            if (delegate.refItem == nil) {
                STBlueSDK.log(text: "\(delegate.id) has nil reference, will be removed")
                return false
            }
            return true
        }
    }
}

extension BleService {

    func read(for characteristic: CBCharacteristic) {
        if characteristic.isCharacteristicCanBeRead {
            peripheral.readValue(for: characteristic)
        }
    }
    
    func write(data: Data, characteristic: CBCharacteristic) {
        if characteristic.isCharacteristicCanBeWrite {
            peripheral.writeValue(data,
                                  for: characteristic,
                                  type: characteristic.writeType)
        }
    }

    func write(data: Data, characteristic: CBCharacteristic, callback: WeakWriteCallBack) {
        cleanupCallback()
        if characteristic.isCharacteristicCanBeWrite {
            writeCallbacks.append(callback)
            peripheral.writeValue(data,
                                  for: characteristic,
                                  type: .withResponse)
        }
    }

    func write(data: Data, characteristic: CBCharacteristic, writeType: CBCharacteristicWriteType) {
        if characteristic.isCharacteristicCanBeWrite {
            peripheral.writeValue(data,
                                  for: characteristic,
                                  type: writeType)
        }
    }

    func write(data: Data,
               mtu: Int,
               characteristic: CBCharacteristic,
               writeDelay: TimeInterval,
               completion: (_ bytes: Int, _ totalBytes: Int) -> Void) {
        var sentDataCount = 0
        for chunk in data.chunks(mtu) {
            self.write(data: chunk,
                       characteristic: characteristic)
            Thread.sleep(forTimeInterval: writeDelay)

            sentDataCount += chunk.count
            completion(sentDataCount, data.count)
        }
    }
    
    func enableNotifications(for characteristic: CBCharacteristic) {
        if characteristic.isCharacteristicCanBeNotify {
            peripheral.setNotifyValue(true, for: characteristic)
        }
    }

    func disableNotifications(for characteristic: CBCharacteristic) {
        if characteristic.isCharacteristicCanBeNotify {
            peripheral.setNotifyValue(false, for: characteristic)
        }
    }

    func discoverServices(for peripheral: CBPeripheral) {
        discoveredServices.removeAll()
        peripheral.discoverServices(nil)
    }

    func addDelegate(_ delegate: BleServiceDelegate, weak: Bool = true) {

        cleanupDelegates()

        guard delegates.firstIndex(where: { $0.refItem === delegate }) == nil else {
            return
        }
        
        delegates.append(weak ? WeakObject<BleServiceDelegate>(refItem: delegate) : StrongObject<BleServiceDelegate>(refItem: delegate))
    }

    func removeDelegate(_ delegate: BleServiceDelegate) {
        if let index = delegates.firstIndex(where: { $0.refItem === delegate }) {
            delegates.remove(at: index)
        }
    }
}

extension BleService: CBPeripheralDelegate {

    func peripheral(_ peripheral: CBPeripheral, didReadRSSI RSSI: NSNumber, error: Error?) {
        guard error == nil else { return }

        delegates.forEach { delegate in
            notificationQueue.async { [weak self] in
                guard let self = self else { return }
                guard let weakDelegate = delegate.refItem as? BleServiceDelegate else { return }
                weakDelegate.service(self, didReadRSSI: RSSI, error: error)
            }
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {

        STBlueSDK.log(text: "DID MODIFY SERVICES for Node: \(peripheral.identifier.uuidString)")
        discoveredServices.removeAll()

        if (isDiscoveringServices) {
            return
        }

        isDiscoveringServices = true

        peripheral.discoverServices(nil)
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {

        if let error = error {
            STBlueSDK.log(text: "Error discovering services for peripheral: \(peripheral.identifier.uuidString) - Error: \(error.localizedDescription)")

            // TODO: update node state
            return
        }

        guard let services = peripheral.services else { return }

        for service in services {
            STBlueSDK.log(text: "Discovered Service: \(service.uuid.uuidString)")

            peripheral.discoverCharacteristics(nil, for: service)
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {

        discoveredServices.syncAppend(service)

        if let error = error {
            latestError = error
            STBlueSDK.log(text: "Error discovering characteristis for peripheral: \(peripheral.identifier.uuidString) and service: \(service.uuid.uuidString) - Error: \(error.localizedDescription)")

            if discoveredServices.count == peripheral.services?.count {
                delegates.forEach {
                    guard let weakDelegate = $0.refItem as? BleServiceDelegate else { return }
                    weakDelegate.service(self, didDiscoverServices: discoveredServices, error: error)
                }
                isDiscoveringServices = false
            }
            return
        }

        guard let characteristics = service.characteristics else { return }

        for characteristic in characteristics {
            STBlueSDK.log(text: "Discovered Characteristic: \(characteristic.uuid.uuidString) (\(service.uuid.uuidString))")
        }

        if discoveredServices.count == peripheral.services?.count {
            delegates.forEach {
                guard let weakDelegate = $0.refItem as? BleServiceDelegate else {
                    return
                }
                weakDelegate.service(self, didDiscoverServices: discoveredServices, error: latestError)
            }
            isDiscoveringServices = false
        }
    }

    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            STBlueSDK.log(text: "Error reading characteristic for peripheral: \(peripheral.identifier.uuidString) and characteristic: \(characteristic.uuid.uuidString) - Error: \(error.localizedDescription)")

            delegates.forEach { delegate in
                notificationQueue.async { [weak self] in
                    guard let self = self else { return }
                    guard let weakDelegate = delegate.refItem as? BleServiceDelegate else { return }
                    weakDelegate.service(self, didLostPeripheral: peripheral, error: error)
                }
            }
            
            return
        }

        delegates.forEach { delegate in
            notificationQueue.sync { [weak self] in
                guard let self = self else { return }
                guard let weakDelegate = delegate.refItem as? BleServiceDelegate else {
                    return
                }
                weakDelegate.service(self, didUpdateValueForCharacteristic: characteristic, error: error)
            }
        }
    }

    func peripheral(_ peripheral: CBPeripheral, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if let error = error {
            STBlueSDK.log(text: "Error writing characteristic for peripheral: \(peripheral.identifier.uuidString) and characteristic: \(characteristic.uuid.uuidString) - Error: \(error.localizedDescription)")

            delegates.forEach {
                guard let weakDelegate = $0.refItem as? BleServiceDelegate else { return }
                weakDelegate.service(self, didLostPeripheral: peripheral, error: error)
            }

            if let weakCallback = writeCallbacks.first(where: { $0.characteristicUUID == characteristic.uuid }) {
                weakCallback.callback(error)
                if let index = writeCallbacks.firstIndex(of: weakCallback) {
                    writeCallbacks.remove(at: index)
                }
            }
            
            return
        }

        delegates.forEach {
            guard let weakDelegate = $0.refItem as? BleServiceDelegate else { return }
            weakDelegate.service(self, didWriteValueFor: characteristic, error: error)
        }

        if let weakCallback = writeCallbacks.first(where: { $0.characteristicUUID == characteristic.uuid }) {
            weakCallback.callback(error)
            if let index = writeCallbacks.firstIndex(of: weakCallback) {
                writeCallbacks.remove(at: index)
            }
        }
    }
    
}

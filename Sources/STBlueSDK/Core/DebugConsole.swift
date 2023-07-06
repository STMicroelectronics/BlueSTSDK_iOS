//
//  DebugConsole.swift
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

internal protocol DebugConsoleDelegate: AnyObject {
    func console(_ console: DebugConsole, didReceiveTerminalMessage message: String)
    func console(_ console: DebugConsole, didReceiveErrorMessage message: String)
    func console(_ console: DebugConsole, didSendMessage message: String?, error: Error?)
}

internal class DebugConsole {

    private let internalQueue = DispatchQueue(label: "[DebugConsoleQueue: \(UUID().uuidString)]")

    let bleService: BleService
    let termCharacteristic: CBCharacteristic
    let errorCharacteristic: CBCharacteristic

    var lastSendingFastData: Data?

    var messageQueue = [Data]()

    var delegates: [DebugConsoleDelegate] = [DebugConsoleDelegate]()

    init(bleService: BleService, termCharacteristic: CBCharacteristic,
         errorCharacteristic: CBCharacteristic) {
        self.bleService = bleService
        self.termCharacteristic = termCharacteristic
        self.errorCharacteristic = errorCharacteristic

        self.bleService.addDelegate(self, weak: true)
    }
}

internal extension DebugConsole {
    static func create(with bleService: BleService, service: CBService) -> DebugConsole? {

        guard let characteristics = service.characteristics,
              let termCharacteristic = characteristics.first(where: { $0.isDebugTermCharacteristic }),
              let errorCharacteristic = characteristics.first(where: { $0.isDebugErrorCharacteristic }) else { return nil }

        return DebugConsole(bleService: bleService,
                            termCharacteristic: termCharacteristic,
                            errorCharacteristic: errorCharacteristic)
    }

    func removeDelegate(_ delegate: DebugConsoleDelegate) {
        if let index = delegates.firstIndex(where: { $0 === delegate }) {
            delegates.remove(at: index)
        }

        if delegates.count == 0 {
            bleService.disableNotifications(for: termCharacteristic)
            bleService.disableNotifications(for: errorCharacteristic)
        }
    }

    func addDelegate(_ delegate: DebugConsoleDelegate) {
        guard delegates.firstIndex(where: { $0 === delegate }) == nil else { return }
        delegates.append(delegate)

        if delegates.count == 1 {
            bleService.enableNotifications(for: termCharacteristic)
            bleService.enableNotifications(for: errorCharacteristic)
        }
    }

    @discardableResult
    func writeFast(data: Data) -> Bool {
        lastSendingFastData = data
        let messageToSend = DebugConsole.dataToString(data)

        if bleService.peripheral.state == .connected {
            bleService.write(data: data,
                             characteristic: termCharacteristic,
                             writeType: .withoutResponse)
            internalQueue.sync { [weak self] in
                guard let self = self else { return }
                for delegate in delegates {
                    delegate.console(self, didSendMessage: messageToSend, error: nil)
                }
            }
            return true
        }

        return false
    }

    func sendNextAvailableMessage() {
        guard let data = messageQueue.first else { return }

        bleService.write(data: data,
                         characteristic: termCharacteristic,
                         writeType: .withResponse)
    }

    @discardableResult
    func write(data: Data) -> Int {

        internalQueue.sync {
            let isQueueEmpty = messageQueue.count == 0

            messageQueue.append(contentsOf: data.chunks(DebugConsole.dataChunkSize))

            if isQueueEmpty {
                sendNextAvailableMessage()
            }
        }

        return data.count
    }
}

extension DebugConsole: BleServiceDelegate {
    func service(_ bleService: BleService, didReadRSSI RSSI: NSNumber, error: Error?) {
        
    }

    func service(_ bleService: BleService, didDiscoverServices services: [CBService], error: Error?) {
        // NOT USED
    }

    func service(_ bleService: BleService, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: Error?) {
        if !characteristic.isDebugTermCharacteristic && !characteristic.isDebugErrorCharacteristic {
            return
        }

        guard delegates.count != 0,
              let data = characteristic.value,
              let message = DebugConsole.dataToString(data) else {
                  return
              }

        internalQueue.sync { [weak self] in
            guard let self = self else { return }
            for delegate in delegates {
                if characteristic.isDebugTermCharacteristic {
                    delegate.console(self, didReceiveTerminalMessage: message)
                } else if characteristic.isDebugErrorCharacteristic {
                    delegate.console(self, didReceiveErrorMessage: message)
                }
            }
        }
    }

    func service(_ bleService: BleService, didWriteValueFor characteristic: CBCharacteristic, error: Error?) {
        if !characteristic.isDebugTermCharacteristic {
            return
        }

        guard delegates.count != 0 else { return }

        var sentData: Data?

        internalQueue.sync { [weak self] in
            guard let self = self else { return }
            if self.messageQueue.count != 0 {
                sentData = self.messageQueue.first
                self.messageQueue.removeFirst()

                if self.messageQueue.count != 0 {
                    self.sendNextAvailableMessage()
                }
            } else {
                sentData = self.lastSendingFastData
            }
        }

        guard let sentData = sentData,
              let message = DebugConsole.dataToString(sentData) else { return }

        internalQueue.sync { [weak self] in
            guard let self = self else { return }
            for delegate in delegates {
                delegate.console(self, didSendMessage: message, error: error)
            }
        }
    }

    func service(_ bleService: BleService, didLostPeripheral peripheral: CBPeripheral, error: Error?) {
        // NOT USED
    }
}

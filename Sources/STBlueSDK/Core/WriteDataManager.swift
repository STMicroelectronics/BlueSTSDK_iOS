//
//  WriteDataManager.swift
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

class WriteDataManager {
    class WriteData {
        let mtu: Int
        let data: Data
        let charactheristic: CBCharacteristic
        let completion: (Bool) -> Void
        init(data: Data, charactheristic: CBCharacteristic, mtu: Int = 20, completion: @escaping (Bool) -> Void) {
            self.data = data
            self.charactheristic = charactheristic
            self.mtu = mtu
            self.completion = completion
        }
    }
    
    private var commands: [WriteData] = []
    private var isSending = false
    private let bleService: BleService
    
    var debug = false
    
    init(bleService: BleService) {
        self.bleService = bleService
    }
    
    func enqueueCommand(_ cmd: WriteData) {
        commands.append(cmd)
        
        if !isSending {
            dequeueCommand()
        }
    }
    
    private func dequeueCommand() {
        guard !commands.isEmpty, !isSending else { return }
        
        isSending = true
        
        let command = commands.removeFirst()

        if debug {
            STBlueSDK.log(text: "start write bytes: \(command.data.hex)")
        }

        sendWrite(command.data, characteristic: command.charactheristic, mtu: command.mtu) { [weak self] success in
            command.completion(success)
            self?.isSending = false
            self?.dequeueCommand()
        }
    }
    
    private func sendWrite(_ data: Data, characteristic: CBCharacteristic, mtu: Int, completion: @escaping (Bool) -> Void) {
        if debug {
            STBlueSDK.log(text: "start write bytes: \(data.count) -> \(data.hex)")
        }

        STBlueSDK.log(text: "\(characteristic.uuid.uuidString)")
        
        var bytes: [Data] = []
        var byteSend = 0
        
        while data.count - byteSend > mtu {
            let part = data[byteSend...byteSend + (mtu - 1)]
            bytes.append(part)
            byteSend += mtu
        }
        if byteSend != data.count {
            let part = data[byteSend...]
            bytes.append(part)
        }
        
        guard !bytes.isEmpty else { completion(false); return }
        
        let parts = bytes.count
        
        func writeBytesPart(_ bytes: [Data], characteristic: CBCharacteristic, atIndex index: Int, completion: @escaping (Bool) -> Void) {

            if index < parts {
                if self.debug {
                    STBlueSDK.log(text: "writing bytes: \(bytes[index]) -> \(bytes[index].hex)")
                }

                bleService.write(data: bytes[index],
                                 characteristic: characteristic)

                //  Wait some times otherwise data is not received correctly
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    if index < parts {
                        writeBytesPart(bytes, characteristic: characteristic, atIndex: index + 1, completion: completion)
                    } else {
                        completion(true)
                    }
                }

            } else {
                completion(true)
            }
        }
        
        writeBytesPart(bytes, characteristic: characteristic, atIndex: 0) { success in
            if self.debug {
                STBlueSDK.log(text: "bytes write completion: \(success)")
            }
            
            completion(success)
        }
    }
}

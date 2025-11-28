//
//  NodeService+ECCommand.swift
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

internal extension NodeService {
    
    func sendCommand(_ command: JsonCommand, maxWriteLength: Int,feature: Feature, progress: ((Int, Int) -> Void)? = nil, completion: (() -> Void)? = nil) -> Bool {
        
        guard let json = command.json,
              let blueChar = node.characteristics.characteristic(with: feature),
              blueChar.characteristic.isCharacteristicCanBeWrite else {
            return false
        }
        
        return sendJSONCommand(json, characteristic: blueChar.characteristic, mtu: maxWriteLength, progress: { index, parts in
            guard let progress = progress else { return }
            progress(index, parts)
        }) {
            guard let completion = completion else { return }
            completion()
        }
    }
    
    func sendCommand(_ command: JsonCommand, maxWriteLength: Int, blueChar: BlueCharacteristic, progress: ((Int, Int) -> Void)? = nil, completion: (() -> Void)? = nil) -> Bool {
        
        guard let json = command.json,
              blueChar.characteristic.isCharacteristicCanBeWrite,
              blueChar.characteristic.isExtendedFeatureCaracteristics else {
            return false
        }
        return sendJSONCommand(json, characteristic: blueChar.characteristic, mtu: maxWriteLength,
                               progress: { index, parts in
            guard let progress = progress else { return }
            progress(index, parts)
        }) {
            guard let completion = completion else { return }
            completion()
        }
    }
    
    func sendJSONCommand(_ json: String,
                         characteristic: CBCharacteristic,
                         mtu: Int,
                         progress: @escaping (Int, Int) -> Void,
                         completion: @escaping () -> Void) -> Bool {
        if debug { STBlueSDK.log(text: "Send command: \(json)") }
        
        let dataTransporter = DataTransporter()
        dataTransporter.config.mtu = mtu
        
        return sendWrite(dataTransporter.encapsulate(string: json),
                         characteristic: characteristic,
                         mtu: dataTransporter.config.mtu,
                         progress: progress,
                         completion: completion)
    }
    
    @discardableResult
    func sendWrite(_ data: Data, characteristic: CBCharacteristic, mtu: Int, progress: @escaping (Int, Int) -> Void, completion: @escaping () -> Void) -> Bool {

        Thread.sleep(forTimeInterval: 0.2)

        writeDataManager.enqueueCommand(WriteDataManager.WriteData(data: data,
                                                                   charactheristic: characteristic,
                                                                   mtu: mtu,
                                                                   progress: { index, part in
            progress(index, part)
        },
                                                                   completion: { _ in
            completion()
        }))
        
        return true
    }
}

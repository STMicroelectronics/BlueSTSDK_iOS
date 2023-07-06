//
//  NodeService+Command.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal extension NodeService {
    func sendCommand(_ command: FeatureCommand, feature: Feature) -> Bool {

        guard let blueChar = node.characteristics.characteristic(with: feature) else {
            return false
        }

        var writeChar = blueChar
        
        if !(blueChar.characteristic.isExtendedFeatureCaracteristics){
            writeChar = node.characteristics.commandCharacteristic() ?? blueChar
        }

        if !writeChar.characteristic.isCharacteristicCanBeWrite {
            return false
        }

        if !writeChar.characteristic.isNotifying {
            bleService.enableNotifications(for: writeChar.characteristic)
        }

        let mask = writeChar.characteristic.isConfigFeatureCommandCharacteristic ? blueChar.characteristic.uuid.featureMask : nil

        let message = command.message(with: mask, nodeId: node.deviceId)

//        isWaitingForCommandResponse = true

        bleService.write(data: message, characteristic: writeChar.characteristic)

        return true
    }
}

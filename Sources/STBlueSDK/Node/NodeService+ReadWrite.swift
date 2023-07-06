//
//  NodeService+ReadWrite.swift
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
    
    @discardableResult
    func readFeature(_ feature: Feature) -> Bool {
        guard let blueChar = node.characteristics.characteristic(with: feature),
              blueChar.characteristic.isCharacteristicCanBeRead else {
            return false
        }

        node.peripheral.readValue(for: blueChar.characteristic)

        return true
    }
    
    @discardableResult
    func write(value data: Data, for feature: Feature) -> Bool {
        guard let blueChar = node.characteristics.characteristic(with: feature),
              blueChar.characteristic.isCharacteristicCanBeWrite else {
            return false
        }
        
        bleService.write(data: data, characteristic: blueChar.characteristic)

        return true
    }
}

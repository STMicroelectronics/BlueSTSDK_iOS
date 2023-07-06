//
//  CBUUID+Helper.swift
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

public typealias FeatureMask = UInt32

public extension CBUUID {
    /**
     *  extract the feature mask from an uuid value, tell to the user witch feature
     *  are exported by this characteristics
     *
     *  @return characteristics feature mask
     */
    var featureMask: FeatureMask {
        get {
            return data.extractUInt32(fromOffset: 0, endian: .big)
        }
    }

    static func uuid(_ identifier: UInt32, suffix: String) -> CBUUID {
        let uuidString = String(format: "%08X%@", identifier, suffix)
        return CBUUID(string: uuidString)
    }
}

//
//  GestureType.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum GestureType: UInt8 {
    case unknown = 0x00
    /**
     *  the pick up gesture
     */
    case pickUp = 0x01
    /**
     *  the wake up gesture
     */
    case glance = 0x02
    /**
     *  the glance gesture
     */
    case wakeUp = 0x03
    /**
     *  the error status
     */
    case error = 0xFF
}

extension GestureType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .pickUp:
            return "PickUp"
        case .glance:
            return "Grance"
        case .wakeUp:
            return "WakeUp"
        case .error:
            return "Error"
        }
    }
}

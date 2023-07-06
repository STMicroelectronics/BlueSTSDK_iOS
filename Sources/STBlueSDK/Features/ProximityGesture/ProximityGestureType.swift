//
//  ProximityGestureType.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum ProximityGestureType: UInt8 {
    case unknown = 0x00
    /**
     *  the tap gesture
     */
    case tap = 0x01
    /**
     *  the left gesture
     */
    case left = 0x02
    /**
     *  the right gesture
     */
    case right = 0x03
    /**
     *  the error status
     */
    case error = 0xFF
}

extension ProximityGestureType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .tap:
            return "Tap"
        case .left:
            return "Left"
        case .right:
            return "Right"
        case .error:
            return "Error"
        }
    }
}

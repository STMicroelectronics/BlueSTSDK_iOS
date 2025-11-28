//
//  AssetTrackingEventType.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum AssetTrackingEventType: Int, Codable {
    case reset = 0x00
    case fall = 0x01
    case shock = 0x02
    case stationary = 0x03
    case motion = 0x04
    case null = -1  // valore di fallback

    static func from(rawValue: UInt8) -> AssetTrackingEventType {
        switch rawValue {
        case 0x00: return .reset
        case 0x01: return .fall
        case 0x02: return .shock
        case 0x03: return .stationary
        case 0x04: return .motion
        default:   return .null
        }
    }
    
    public var description: String {
        switch self {
        case .reset: return "Reset"
        case .fall:  return "Fall"
        case .shock: return "Shock"
        case .stationary: return "Stationary"
        case .motion: return "Motion"
        default:    return "N/A"
        }
    }
}

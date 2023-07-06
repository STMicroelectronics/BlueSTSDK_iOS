//
//  PredictiveStatus.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum PredictiveStatus: UInt8 {
    
    case good = 0x00
    case warning = 0x01
    case bad = 0x02
    case unknown = 0xFF
    
    public static func fromByte(_ value: UInt8) -> PredictiveStatus {
        return PredictiveStatus(rawValue: value) ?? .unknown
    }
    
    static func extractXStatus(_ packed: UInt8) -> PredictiveStatus {
        return PredictiveStatus.fromByte((packed >> 4) & 0x03)
    }
    
    static func extractYStatus(_ packed: UInt8) -> PredictiveStatus {
        return PredictiveStatus.fromByte((packed >> 2) & 0x03)
    }
    
    static func extractZStatus(_ packed: UInt8) -> PredictiveStatus {
        return PredictiveStatus.fromByte(packed & 0x03)
    }
    
}

extension PredictiveStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .good:
            return "Good"
        case .warning:
            return "Warning"
        case .bad:
            return "Bad"
        case .unknown:
            return "Unknown"
        }
    }
}

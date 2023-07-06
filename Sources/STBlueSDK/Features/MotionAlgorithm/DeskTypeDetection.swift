//
//  DeskTypeDetection.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum DeskTypeDetection: UInt8 {
    case unknown = 0x00
    case sittingDesk = 0x01
    case standingDesk = 0x02
}

extension DeskTypeDetection: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .sittingDesk:
            return "Sitting Desk"
        case .standingDesk:
            return "Standing Desk"
        }
    }
}

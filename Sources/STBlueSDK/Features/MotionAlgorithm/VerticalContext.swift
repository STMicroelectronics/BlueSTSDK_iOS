//
//  VerticalContext.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum VerticalContext: UInt8 {
    case unknown = 0x00
    case floor = 0x01
    case upDown = 0x02
    case stairs = 0x03
    case elevator = 0x04
    case escalator = 0x05
}

extension VerticalContext: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .floor:
            return "Floor"
        case .upDown:
            return "Up Down"
        case .stairs:
            return "Stairs"
        case .elevator:
            return "Elevetor"
        case .escalator:
            return "Escalator"
        }
    }
}

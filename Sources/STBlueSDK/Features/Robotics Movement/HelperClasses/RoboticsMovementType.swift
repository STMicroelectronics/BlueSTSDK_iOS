//
//  RoboticsMovementType.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation


// Defined Movement Types
public enum RoboticsMovementType: UInt8, FeatureCommandType, CaseIterable {
    
    case getTopology = 0x10
    case setNavigationMode = 0x21
    case setCordinateOrigin = 0x22
    case setTargetOrigin = 0x23
    case setMoveCommand = 0x24
    case setLinearAndAngleCommand = 0x25
    case unknownCommand = 0xFF // Assigned a raw value for unknownCommand
    
    public init(rawValue: UInt8) {
        // Initialize with the known cases or default to unknownCommand
        switch rawValue {
        case 0x10:
            self = .getTopology
        case 0x21:
            self = .setNavigationMode
        case 0x22:
            self = .setCordinateOrigin
        case 0x23:
            self = .setTargetOrigin
        case 0x24:
            self = .setMoveCommand
        case 0x25:
            self = .setLinearAndAngleCommand
        default:
            self = .unknownCommand
        }
    }
    
    public var payload: Data? {
        return nil
    }
    
    public var useMask: Bool {
        false
    }
    
    public func data(with nodeId: UInt8) -> Data {
        Data([rawValue])
    }
}

extension RoboticsMovementType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .getTopology:
            return "Get Topology"
        case .setNavigationMode:
            return "Set Navigation Mode"
        case .setCordinateOrigin:
            return "Set Cordinate Origin"
        case .setTargetOrigin:
            return "Set Target Origin"
        case .setMoveCommand:
            return "Set Move Command"
        case .setLinearAndAngleCommand:
            return "Set Linear and Angle Command"
        case .unknownCommand:
            return "Unknown Command"

        }
    }
}





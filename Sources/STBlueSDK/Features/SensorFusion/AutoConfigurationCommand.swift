//
//  AutoConfigurationCommand.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum AutoConfigurationCommand: UInt8, FeatureCommandType, CustomStringConvertible {

    case start = 0x00
    case stop = 0x01
    case get = 0xFF

    public var description: String {
        switch self {
        case .start:
            return "Start Configuration"
        case .stop:
            return "Stop Configuration"
        case .get:
            return "Get Configuration"
        }
    }
    
    public var useMask: Bool {
        true
    }
    
    public func data(with nodeId: UInt8) -> Data {
        return Data([rawValue])
    }
    
    public var payload: Data? {
        return nil
    }
}

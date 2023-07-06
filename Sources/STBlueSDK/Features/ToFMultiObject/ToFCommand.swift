//
//  ToFCommand.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum ToFCommand: UInt8, FeatureCommandType {
    
    case enablePresenceDetection = 0x01
    case disablePresenceDetection = 0x00
    
    public var payload: Data? {
        nil
    }
    
    public var useMask: Bool {
        false
    }
    
    public func data(with nodeId: UInt8) -> Data {
        Data([rawValue])
    }
}

extension ToFCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .enablePresenceDetection:
            return "Enable presence detection"
        case .disablePresenceDetection:
            return "Disable presence detection"
        }
    }
}

//
//  NEAIClassificationCommand.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum NEAIClassificationCommand: UInt8, FeatureCommandType, CustomStringConvertible {
    
    case stop = 0x00
    case start = 0x01
    
    public var description: String {
        switch self {
        case .stop:
            return "Stop"
        case .start:
            return "Start"
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

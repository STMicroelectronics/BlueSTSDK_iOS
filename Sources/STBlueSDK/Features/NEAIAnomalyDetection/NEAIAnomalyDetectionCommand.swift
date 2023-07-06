//
//  NEAIAnomalyDetectionCommand.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum NEAIAnomalyDetectionCommand: UInt8, FeatureCommandType, CustomStringConvertible {
    
    case stop = 0x00
    case learning = 0x01
    case detection = 0x02
    case resetKnowledge = 0xFF
    
    public var description: String {
        switch self {
        case .stop:
            return "Stop"
        case .learning:
            return "Learning"
        case .detection:
            return "Detection"
        case .resetKnowledge:
            return "Reset Knowledge"
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

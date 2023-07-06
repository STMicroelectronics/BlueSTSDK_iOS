//
//  COSensorCommand.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum COSensorCommand: FeatureCommandType {
    
    case setSensitivity(sentivity: Float)
    case getSesintivity
    
    var value: UInt8 {
        switch self {
        case .setSensitivity:
            return 0x01
        case .getSesintivity:
            return 0x00
        }
    }
    
    public var payload: Data? {
        switch self {
        case .getSesintivity:
            return nil
        case .setSensitivity(let sentivity):
            var data = Data()
            withUnsafeBytes(of: sentivity) { data.append(contentsOf: $0) }
            return data
        }
    }
    
    public var useMask: Bool {
        true
    }
    
    public func data(with nodeId: UInt8) -> Data {
        Data([value])
    }
}

extension COSensorCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .getSesintivity:
            return "Get Sensitivity"
        case .setSensitivity(let sensitivity):
            return "Set Sensitivity: \(sensitivity)"
        }
    }
}

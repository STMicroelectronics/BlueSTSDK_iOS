//
//  SDLoggingCommand.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum SDLoggingCommand: FeatureCommandType {
    
    case start(features: [Feature], logInterval: Int)
    case stop
    
    var value: UInt8 {
        switch self {
        case .start:
            return 0x01
        case .stop:
            return 0x00
        }
    }
    
    public var payload: Data? {
        switch self {
        case .start(let features, let logInterval):
            var data = Data()
            var featuresMask: UInt32 = 0
            
            for feature in features {
                featuresMask |= feature.type.mask
            }
            
            withUnsafeBytes(of: featuresMask.bigEndian) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: UInt32(logInterval).bigEndian) { data.append(contentsOf: $0) }
            return data
        case .stop:
            return Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        }
    }
    
    public var useMask: Bool {
        false
    }
    
    public func data(with nodeId: UInt8) -> Data {
        Data([value])
    }
}

extension SDLoggingCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .start:
            return "Start logging"
        case .stop:
            return "Stop logging"
        }
    }
}

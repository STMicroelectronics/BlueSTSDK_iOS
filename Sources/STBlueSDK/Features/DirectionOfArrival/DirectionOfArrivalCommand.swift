//
//  DirectionOfArrivalCommand.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum DirectionOfArrivalCommandPayload: UInt8 {
    case lowSensitivity = 0x00
    case highSensitivity = 0x01
}

public enum DirectionOfArrivalCommand: FeatureCommandType {

    case changeSensitivity(sentivity: DirectionOfArrivalCommandPayload)
    
    var value: UInt8 {
        return 0xCC
    }
    
    public var payload: Data? {
        switch self {
        case .changeSensitivity(let sentivity):
            var data = Data()
            withUnsafeBytes(of: sentivity.rawValue) { data.append(contentsOf: $0) }
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

extension DirectionOfArrivalCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .changeSensitivity(let sensitivity):
            return "Change Sensitivity: \(sensitivity == .lowSensitivity ? "LOW" : "HIGH")"
        }
    }
}

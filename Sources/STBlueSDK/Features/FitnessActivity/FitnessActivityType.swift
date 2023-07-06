//
//  FitnessActivityType.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum FitnessActivityType: UInt8, FeatureCommandType, CaseIterable {
    case noActivity = 0x00
    case bicepCurl = 0x01
    case squat = 0x02
    case pushUp = 0x03
    
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

extension FitnessActivityType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noActivity:
            return "No activity"
        case .bicepCurl:
            return "Bicep curl"
        case .squat:
            return "Squat"
        case .pushUp:
            return "Push up"
        }
    }
}

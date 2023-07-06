//
//  Algorithm.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum Algorithm: UInt8, FeatureCommandType, CaseIterable {
    case none = 0x00
    case poseEstimation = 0x01
    case deskTypeDetection = 0x02
    case verticalContext = 0x03
    
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

extension Algorithm: CustomStringConvertible {
    public var description: String {
        switch self {
        case .none:
            return "None"
        case .poseEstimation:
            return "Pose Estimation"
        case .deskTypeDetection:
            return "Desk Type Detection"
        case .verticalContext:
            return "Vertical Context"
        }
    }
}

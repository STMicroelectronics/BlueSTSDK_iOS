//
//  PoseEstimation.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum PoseEstimation : UInt8 {
    case unknown = 0x00
    case sitting = 0x01
    case standing = 0x02
    case layingDown = 0x03
}

extension PoseEstimation: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .sitting:
            return "Sitting"
        case .standing:
            return "Standing"
        case .layingDown:
            return "Laying Down"
        }
    }
}

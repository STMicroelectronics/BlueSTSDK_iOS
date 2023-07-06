//
//  SensorFusionCompactData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct SensorFusionCompactData {
    public let samples: [SensorFusionData]
}

extension SensorFusionCompactData: CustomStringConvertible {
    public var description: String {
        return samples.map { $0.description }.joined(separator: "\n\n")
    }
}

extension SensorFusionCompactData: Loggable {
    public var logHeader: String {
        "TBI"
    }

    public var logValue: String {
        "TBI"
    }
}

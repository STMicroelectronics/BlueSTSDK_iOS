//
//  MotionIntensityData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct MotionIntensityData {
    
    public let motionIntensity: FeatureField<UInt8>
    
    init(with data: Data, offset: Int) {
        
        let motionIntensity = data.extractUInt8(fromOffset: offset)
        
        self.motionIntensity = FeatureField<UInt8>(name: "Intensity",
                                        uom: nil,
                                        min: 0,
                                        max: 10,
                                        value: motionIntensity)
    }
    
}

extension MotionIntensityData: CustomStringConvertible {
    public var description: String {
        
        let motionIntensity = motionIntensity.value ?? 0
        
        return String(format: "Intensity: %zd", motionIntensity)
    }
}

extension MotionIntensityData: Loggable {
    public var logHeader: String {
        "\(motionIntensity.logHeader)"
    }
    
    public var logValue: String {
        "\(motionIntensity.logValue)"
    }
    
}

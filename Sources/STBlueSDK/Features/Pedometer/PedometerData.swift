//
//  PedometerData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PedometerData {
    
    public let steps: FeatureField<UInt32>
    public let frequency: FeatureField<UInt16>
    
    init(with data: Data, offset: Int) {
        
        let steps = data.extractUInt32(fromOffset: offset)
        let frequency = data.extractUInt16(fromOffset: offset + 4)
        
        self.steps = FeatureField<UInt32>(name: "Steps",
                                          uom: nil,
                                          min: 0,
                                          max: UInt32.max,
                                          value: steps)
        
        self.frequency = FeatureField<UInt16>(name: "Frequency",
                                              uom: "steps/min",
                                              min: 0,
                                              max: UInt16.max,
                                              value: frequency)
    }
    
}

extension PedometerData: CustomStringConvertible {
    public var description: String {
        
        let steps = steps.value ?? 0
        let frequency = frequency.value ?? 0
        
        return String(format: "Steps: %zd, Frequency: %zd", steps, frequency)
    }
}

extension PedometerData: Loggable {
    public var logHeader: String {
        "\(steps.logHeader),\(frequency.logHeader)"
    }
    
    public var logValue: String {
        "\(steps.logValue),\(frequency.logValue)"
    }
    
}

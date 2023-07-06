//
//  FitnessActivityData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct FitnessActivityData {
    
    public let type: FeatureField<FitnessActivityType>
    public let counter: FeatureField<UInt16>
    
    init(with data: Data, offset: Int) {
        
        let type = FitnessActivityType(rawValue: data.extractUInt8(fromOffset: offset))
        let counter = data.extractUInt16(fromOffset: offset + 1)
        
        self.type = FeatureField<FitnessActivityType>(name: "Activity",
                                       uom: nil,
                                       min: nil,
                                       max: nil,
                                       value: type)
        
        self.counter = FeatureField<UInt16>(name: "Activity counter",
                                         uom: nil,
                                         min: 0,
                                            max: UInt16.max,
                                         value: counter)
    }
    
}

extension FitnessActivityData: CustomStringConvertible {
    public var description: String {
        
        let counter = counter.value ?? 0
        
        if let type = type.value ?? .none {
            return String(format: "Activity type: %@\nCounter: %zd\n", type.description, counter)
        }
        
        return String(format: "Activity type: %@\nCounter: %zd\n", "Unknown", counter)
    }
}

extension FitnessActivityData: Loggable {
    public var logHeader: String {
        "\(type.logHeader),\(counter.logHeader)"
    }
    
    public var logValue: String {
        "\(type.logValue),\(counter.logValue)"
    }
    
}

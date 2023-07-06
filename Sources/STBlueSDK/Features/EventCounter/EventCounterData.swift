//
//  EventCounterData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct EventCounterData {
    
    public let counter: FeatureField<UInt32>
    
    init(with data: Data, offset: Int) {
        
        let counter = data.extractUInt32(fromOffset: offset)
        
        self.counter = FeatureField<UInt32>(name: "Counter",
                                            uom: nil,
                                            min: 0,
                                            max: UInt32.max,
                                            value: counter)
    }
    
}

extension EventCounterData: CustomStringConvertible {
    public var description: String {
        
        let counter = counter.value ?? 0
        
        return String(format: "Counter: %zd", counter)
    }
}

extension EventCounterData: Loggable {
    public var logHeader: String {
        "\(counter.logHeader)"
    }
    
    public var logValue: String {
        "\(counter.logValue)"
    }
    
}

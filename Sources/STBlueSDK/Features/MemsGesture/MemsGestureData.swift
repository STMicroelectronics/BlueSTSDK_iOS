//
//  MemsGestureData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct MemsGestureData {
    
    public let gesture: FeatureField<GestureType>
    
    init(with data: Data, offset: Int) {
        
        let gesture = GestureType(rawValue: data.extractUInt8(fromOffset: offset))
        
        self.gesture = FeatureField<GestureType>(name: "MemsGesture",
                                                 uom: nil,
                                                 min: nil,
                                                 max: nil,
                                                 value: gesture)
    }
    
}

extension MemsGestureData: CustomStringConvertible {
    public var description: String {
        
        let gesture = gesture.value ?? .unknown
        
        return String(format: "Gesture: %@", gesture.description)
    }
}

extension MemsGestureData: Loggable {
    public var logHeader: String {
        "\(gesture.logHeader)"
    }
    
    public var logValue: String {
        "\(gesture.logValue)"
    }
    
}

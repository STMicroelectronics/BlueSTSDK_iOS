//
//  ProximityData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct ProximityData {
    
    private static let lowRangeMax: UInt16 = 0xFE
    private static let highRangeMax: UInt16 = 0x7FFE
    public static let outOfrange: UInt16 = 0xFFFF
    
    public let distance: FeatureField<UInt16>
    
    init(with data: Data, offset: Int) {
        
        var distance = data.extractUInt16(fromOffset: offset)
        var maxValue: UInt16 = 0
        
        if Self.isLowRangeSensor(distance) {
            distance = Self.getLowRangeValue(distance)
            maxValue = Self.lowRangeMax
        } else {
            distance = Self.getHighRangeSample(distance)
            maxValue = Self.highRangeMax
        }
        
        self.distance = FeatureField<UInt16>(name: "Proximity",
                                             uom: "mm",
                                             min: 0,
                                             max: maxValue,
                                             value: distance)
    }
    
}

private extension ProximityData {
    static func isLowRangeSensor(_ value: UInt16) -> Bool {
        return (value & 0x8000) == 0
    }
    
    static func extractRangeValue(_ value: UInt16) -> UInt16 {
        return (value & ~0x8000)
    }
    
    static func getLowRangeValue(_ value: UInt16) -> UInt16 {
        var rangeValue = extractRangeValue(value)
        if rangeValue > lowRangeMax {
            rangeValue = outOfrange
        }
        return rangeValue
    }
    
    static func getHighRangeSample(_ value: UInt16) -> UInt16 {
        var rangeValue = extractRangeValue(value)
        if rangeValue > highRangeMax {
            rangeValue = outOfrange
        }
        return rangeValue
    }
}

extension ProximityData: CustomStringConvertible {
    public var description: String {
        
        let distance = distance.value ?? 0
        
        return String(format: "Distance: %zd", distance)
    }
}

extension ProximityData: Loggable {
    public var logHeader: String {
        "\(distance.logHeader)"
    }
    
    public var logValue: String {
        "\(distance.logValue)"
    }
    
}

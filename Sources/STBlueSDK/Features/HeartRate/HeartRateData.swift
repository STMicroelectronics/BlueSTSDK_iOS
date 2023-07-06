//
//  HeartRateData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct HeartRateData {
    
    public let heartRate: FeatureField<Int32>
    public let energyExpended: FeatureField<Int32>
    public let rrInterval: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        var currentOffset = 0
        let flags = data.extractUInt8(fromOffset: currentOffset)
        currentOffset += 1
        
        let has8BitHeartRate = Self.has8BitHeartRate(flags: flags)
        let heartRate = has8BitHeartRate ? Int32(data.extractUInt8(fromOffset: currentOffset)) : Int32(data.extractUInt16(fromOffset: currentOffset, endian: .little))
        self.heartRate = FeatureField<Int32>(name: "Heart Rate",
                                              uom: "bpm",
                                              min: 0,
                                              max: Int32.max,
                                              value: heartRate)
        currentOffset += has8BitHeartRate ? 0 : 2
        
        let hasEnergyExpended = Self.hasEnergyExpended(flags: flags)
        let energyExpended = hasEnergyExpended ? Int32(data.extractUInt16(fromOffset: currentOffset, endian: .little)) : Int32(-1)
        self.energyExpended = FeatureField<Int32>(name: "Energy Expended",
                                                  uom: "kJ",
                                                  min: 0,
                                                  max: Int32.max,
                                                  value: energyExpended)
        currentOffset += hasEnergyExpended ? 2 : 0
        
        let hasRRInterval = Self.hasRRInterval(flags: flags)
        let rrInterval = hasRRInterval ? Float(data.extractUInt16(fromOffset: currentOffset, endian: .little)) / Float(1024) : Float.nan
        self.rrInterval = FeatureField<Float>(name: "RR-Interval",
                                              uom: "s",
                                              min: 0,
                                              max: Float.greatestFiniteMagnitude,
                                              value: rrInterval)
        currentOffset += hasRRInterval ? 2 : 0
    }
    
}

private extension HeartRateData {
    static func has8BitHeartRate(flags: UInt8) -> Bool {
        return (flags & 0x01) == 0
    }
    
    static func hasEnergyExpended(flags: UInt8) -> Bool {
        return (flags & 0x08) != 0
    }
    
    static func hasRRInterval(flags: UInt8) -> Bool {
        return (flags & 0x10) != 0
    }
}

extension HeartRateData: CustomStringConvertible {
    public var description: String {
        
        let heartRate = heartRate.value ?? 0
        let energyExpended = energyExpended.value ?? 0
        let rrInterval = rrInterval.value ?? Float.nan
        
        return String(format: "Heart Rate: %.2f\nEnergy Expended: %.2f\nRR Interval: %.2f", heartRate, energyExpended, rrInterval)
    }
}

extension HeartRateData: Loggable {
    public var logHeader: String {
        "\(heartRate.logHeader),\(energyExpended.logHeader),\(rrInterval.logHeader)"
    }
    
    public var logValue: String {
        "\(heartRate.logValue),\(energyExpended.logValue),\(rrInterval.logValue)"
    }
    
}

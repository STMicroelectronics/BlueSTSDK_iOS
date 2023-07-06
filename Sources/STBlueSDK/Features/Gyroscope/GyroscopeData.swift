//
//  GyroscopeData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct GyroscopeData {
    
    static let maxValue = Float(1 << 15) / 10.0
    static let minValue = -Self.maxValue
    
    public let gyroX: FeatureField<Float>
    public let gyroY: FeatureField<Float>
    public let gyroZ: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        let gyroX = Float(data.extractInt16(fromOffset: offset))
        let gyroY = Float(data.extractInt16(fromOffset: offset + 2))
        let gyroZ = Float(data.extractInt16(fromOffset: offset + 4))
        
        self.gyroX = FeatureField<Float>(name: "X",
                                         uom: "dps",
                                         min: Self.maxValue,
                                         max: Self.minValue,
                                         value: gyroX)
        
        self.gyroY = FeatureField<Float>(name: "X",
                                         uom: "dps",
                                         min: Self.maxValue,
                                         max: Self.minValue,
                                         value: gyroY)
        
        self.gyroZ = FeatureField<Float>(name: "Z",
                                         uom: "dps",
                                         min: Self.maxValue,
                                         max: Self.minValue,
                                         value: gyroZ)
    }
    
}

extension GyroscopeData: CustomStringConvertible {
    public var description: String {
        
        let gyroX = gyroX.value ?? 0
        let gyroY = gyroY.value ?? 0
        let gyroZ = gyroZ.value ?? 0
        
        return String(format: "GyroX: %.2f\nGyroY: %.2f\nGyroZ: %.2f", gyroX, gyroY, gyroZ)
    }
}

extension GyroscopeData: Loggable {
    public var logHeader: String {
        "\(gyroX.logHeader),\(gyroY.logHeader),\(gyroZ.logHeader)"
    }
    
    public var logValue: String {
        "\(gyroX.logValue),\(gyroY.logValue),\(gyroZ.logValue)"
    }
    
}

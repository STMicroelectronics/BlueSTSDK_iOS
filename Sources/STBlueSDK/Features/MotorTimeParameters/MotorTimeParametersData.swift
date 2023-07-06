//
//  MotorTimeParametersData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct MotorTimeParametersData {
    
    public static let accUom = "m/s^2"
    public static let speedUom = "mm/s"
    
    public static let accMaxValue: Float = 2000.0
    public static let accMinValue: Float = -2000.0
    
    public static let speedMaxValue: Float = 2000.0
    public static let speedMinValue: Float = 0.0
    
    public let accX: FeatureField<Float>
    public let accY: FeatureField<Float>
    public let accZ: FeatureField<Float>
    
    public let speedX: FeatureField<Float>
    public let speedY: FeatureField<Float>
    public let speedZ: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        let accX = Float(data.extractInt16(fromOffset: offset)) / 100.0
        let accY = Float(data.extractInt16(fromOffset: offset + 2)) / 100.0
        let accZ = Float(data.extractInt16(fromOffset: offset + 4)) / 100.0
        
        let speedX = data.extractFloat(fromOffset: offset + 6)
        let speedY = data.extractFloat(fromOffset: offset + 10)
        let speedZ = data.extractFloat(fromOffset: offset + 14)
        
        self.accX = FeatureField<Float>(name: "Acc X",
                                        uom: Self.accUom,
                                        min: Self.accMinValue,
                                        max: Self.accMaxValue,
                                        value: accX)
        
        self.accY = FeatureField<Float>(name: "Acc X",
                                        uom: Self.accUom,
                                        min: Self.accMinValue,
                                        max: Self.accMaxValue,
                                        value: accY)
        
        self.accZ = FeatureField<Float>(name: "Acc Z",
                                        uom: Self.accUom,
                                        min: Self.accMinValue,
                                        max: Self.accMaxValue,
                                        value: accZ)
        
        self.speedX = FeatureField<Float>(name: "Speed X",
                                          uom: Self.speedUom,
                                          min: Self.speedMinValue,
                                          max: Self.speedMaxValue,
                                          value: speedX)
        
        self.speedY = FeatureField<Float>(name: "Speed X",
                                          uom: Self.speedUom,
                                          min: Self.speedMinValue,
                                          max: Self.speedMaxValue,
                                          value: speedY)
        
        self.speedZ = FeatureField<Float>(name: "Speed Z",
                                          uom: Self.speedUom,
                                          min: Self.speedMinValue,
                                          max: Self.speedMaxValue,
                                          value: speedZ)
    }
    
}

extension MotorTimeParametersData: CustomStringConvertible {
    public var description: String {
        
        let accX = accX.value ?? 0
        let accY = accY.value ?? 0
        let accZ = accZ.value ?? 0
        
        let speedX = speedX.value ?? 0
        let speedY = speedY.value ?? 0
        let speedZ = speedZ.value ?? 0
        
        return String(format: "Acc X: %.2f\nAcc Y: %.2f\nAcc Z: %.2f\nSpeed X: %.2f\nSpeed Y: %.2f\nSpeed Z: %.2f", accX, accY, accZ, speedX, speedY, speedZ)
    }
}

extension MotorTimeParametersData: Loggable {
    public var logHeader: String {
        "\(accX.logHeader),\(accY.logHeader),\(accZ.logHeader),\(speedX.logHeader),\(speedY.logHeader),\(speedZ.logHeader)"
    }
    
    public var logValue: String {
        "\(accX.logValue),\(accY.logValue),\(accZ.logValue),\(speedX.logValue),\(speedY.logValue),\(speedZ.logValue)"
    }
    
}

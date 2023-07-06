//
//  AccelerationData.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct AccelerationData {

    public let accelerationX: FeatureField<Float>
    public let accelerationY: FeatureField<Float>
    public let accelerationZ: FeatureField<Float>
    
    
    init(with data: Data, offset: Int) {
        
        let accX = Float(data.extractInt16(fromOffset: offset))
        let accY = Float(data.extractInt16(fromOffset: offset + 2))
        let accZ = Float(data.extractInt16(fromOffset: offset + 4))
        
        self.accelerationX = FeatureField<Float>(name: "X",
                                                 uom: "mg",
                                                 min: -2000,
                                                 max: 2000,
                                                 value: accX)
        
        self.accelerationY = FeatureField<Float>(name: "X",
                                                 uom: "mg",
                                                 min: -2000,
                                                 max: 2000,
                                                 value: accY)
        
        self.accelerationZ = FeatureField<Float>(name: "Z",
                                                 uom: "mg",
                                                 min: -2000,
                                                 max: 2000,
                                                 value: accZ)
    }

}

extension AccelerationData: CustomStringConvertible {
    public var description: String {
        
        let accX = accelerationX.value ?? 0
        let accY = accelerationY.value ?? 0
        let accZ = accelerationZ.value ?? 0

        return String(format: "AccelerationX: %.2f\nAccelerationY: %.2f\nAccelerationZ: %.2f", accX, accY, accZ)
    }
}

extension AccelerationData: Loggable {
    public var logHeader: String {
        "\(accelerationX.logHeader),\(accelerationY.logHeader),\(accelerationZ.logHeader)"
    }
    
    public var logValue: String {
        "\(accelerationX.logValue),\(accelerationY.logValue),\(accelerationZ.logValue)"
    }
    
}

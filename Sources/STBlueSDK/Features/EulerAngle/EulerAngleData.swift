//
//  EulerAngleData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct EulerAngleData {
    
    public let yaw: FeatureField<Float>
    public let pitch: FeatureField<Float>
    public let roll: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
//        let yaw = Float(data.extractInt16(fromOffset: offset))
//        let pitch = Float(data.extractInt16(fromOffset: offset + 4))
//        let roll = Float(data.extractInt16(fromOffset: offset + 8))

        let yaw = data.extractFloat(fromOffset: offset)
        let pitch = data.extractFloat(fromOffset: offset + 4)
        let roll = data.extractFloat(fromOffset: offset + 8)
        
        self.yaw = FeatureField<Float>(name: "Yaw",
                                       uom: "°",
                                       min: 0,
                                       max: 360,
                                       value: yaw)
        
        self.pitch = FeatureField<Float>(name: "Pitch",
                                         uom: "°",
                                         min: -180,
                                         max: 180,
                                         value: pitch)
        
        self.roll = FeatureField<Float>(name: "Roll",
                                        uom: "°",
                                        min: -90,
                                        max: 90,
                                        value: roll)
    }
    
}

extension EulerAngleData: AngleData {
    public var angleValue: Float {
        yaw.value ?? 0.0
    }

    public var orientation: Orientation {
        Orientation.orientation(from: angleValue)
    }
}

extension EulerAngleData: CustomStringConvertible {
    public var description: String {
        
        let yaw = yaw.value ?? Float.nan
        let pitch = pitch.value ?? Float.nan
        let roll = roll.value ?? Float.nan
        
        return String(format: "Yaw: %.2f\nPitch: %.2f\nRoll: %.2f", yaw, pitch, roll)
    }
}

extension EulerAngleData: Loggable {
    public var logHeader: String {
        "\(yaw.logHeader),\(pitch.logHeader),\(roll.logHeader)"
    }
    
    public var logValue: String {
        "\(yaw.logValue),\(pitch.logValue),\(roll.logValue)"
    }
    
}

//
//  PredictiveAccelerationStatusData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PredictiveAccelerationStatusData {
    
    public var statusAccX: FeatureField<PredictiveStatus>
    public var statusAccY: FeatureField<PredictiveStatus>
    public var statusAccZ: FeatureField<PredictiveStatus>
    
    public var accelerationX: FeatureField<Float>
    public var accelerationY: FeatureField<Float>
    public var accelerationZ: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        let status = data.extractUInt8(fromOffset: offset)
        let accX = data.extractFloat(fromOffset: offset + 1)
        let accY = data.extractFloat(fromOffset: offset + 5)
        let accZ = data.extractFloat(fromOffset: offset + 9)
        
        let statusX = PredictiveStatus.extractXStatus(status)
        let statusY = PredictiveStatus.extractYStatus(status)
        let statusZ = PredictiveStatus.extractZStatus(status)
        
        self.statusAccX = FeatureField<PredictiveStatus>(name: "StatusAcc_X",
                                                         uom: nil,
                                                         min: nil,
                                                         max: nil,
                                                         value: statusX)
        
        self.statusAccY = FeatureField<PredictiveStatus>(name: "StatusAcc_Y",
                                                         uom: nil,
                                                         min: nil,
                                                         max: nil,
                                                         value: statusY)
        
        self.statusAccZ = FeatureField<PredictiveStatus>(name: "StatusAcc_Z",
                                                         uom: nil,
                                                         min: nil,
                                                         max: nil,
                                                         value: statusZ)
        
        self.accelerationX = FeatureField<Float>(name: "AccPeak_X",
                                                 uom: nil,
                                                 min: 0,
                                                 max: Float.greatestFiniteMagnitude,
                                                 value: accX)
        
        self.accelerationY = FeatureField<Float>(name: "AccPeak_Y",
                                                 uom: nil,
                                                 min: 0,
                                                 max: Float.greatestFiniteMagnitude,
                                                 value: accY)
        
        self.accelerationZ = FeatureField<Float>(name: "AccPeak_Z",
                                                 uom: nil,
                                                 min: 0,
                                                 max: Float.greatestFiniteMagnitude,
                                                 value: accZ)
    }
    
}

extension PredictiveAccelerationStatusData: CustomStringConvertible {
    public var description: String {
        
        let statusX = statusAccX.value ?? .unknown
        let statusY = statusAccY.value ?? .unknown
        let statusZ = statusAccZ.value ?? .unknown
        
        let accX = accelerationX.value ?? 0
        let accY = accelerationY.value ?? 0
        let accZ = accelerationZ.value ?? 0
        
        return String(format: "Status X: %@\nStatus Y: %@\nStatus Z: %@\nAcc Peack X: %.2f\nAcc Peack Y: %.2f\nAcc Peack Z: %.2f", statusX.description, statusY.description, statusZ.description, accX, accY, accZ)
    }
}

extension PredictiveAccelerationStatusData: Loggable {
    public var logHeader: String {
        "\(statusAccX.logHeader),\(statusAccY.logHeader),\(statusAccZ.logHeader),\(accelerationX.logHeader),\(accelerationY.logHeader),\(accelerationZ.logHeader)"
    }
    
    public var logValue: String {
        "\(statusAccX.logValue),\(statusAccY.logValue),\(statusAccZ.logValue),\(accelerationX.logValue),\(accelerationY.logValue),\(accelerationZ.logValue)"
    }
    
}

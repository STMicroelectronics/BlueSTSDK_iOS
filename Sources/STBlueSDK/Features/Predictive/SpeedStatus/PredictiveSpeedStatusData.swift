//
//  PredictiveSpeedStatusData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PredictiveSpeedStatusData {
    
    public var statusSpeedX: FeatureField<PredictiveStatus>
    public var statusSpeedY: FeatureField<PredictiveStatus>
    public var statusSpeedZ: FeatureField<PredictiveStatus>
    
    public var rmsSpeedX: FeatureField<Float>
    public var rmsSpeedY: FeatureField<Float>
    public var rmsSpeedZ: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        let status = data.extractUInt8(fromOffset: offset)
        let speedX = data.extractFloat(fromOffset: offset + 1)
        let speedY = data.extractFloat(fromOffset: offset + 5)
        let speedZ = data.extractFloat(fromOffset: offset + 9)
        
        let statusX = PredictiveStatus.extractXStatus(status)
        let statusY = PredictiveStatus.extractYStatus(status)
        let statusZ = PredictiveStatus.extractZStatus(status)
        
        self.statusSpeedX = FeatureField<PredictiveStatus>(name: "StatusSpeed_X",
                                                           uom: nil,
                                                           min: nil,
                                                           max: nil,
                                                           value: statusX)
        
        self.statusSpeedY = FeatureField<PredictiveStatus>(name: "StatusSpeed_Y",
                                                           uom: nil,
                                                           min: nil,
                                                           max: nil,
                                                           value: statusY)
        
        self.statusSpeedZ = FeatureField<PredictiveStatus>(name: "StatusSpeed_Z",
                                                           uom: nil,
                                                           min: nil,
                                                           max: nil,
                                                           value: statusZ)
        
        self.rmsSpeedX = FeatureField<Float>(name: "RMSSpeed_X",
                                             uom: "mm/s",
                                             min: 0,
                                             max: Float.greatestFiniteMagnitude,
                                             value: speedX)
        
        self.rmsSpeedY = FeatureField<Float>(name: "RMSSpeed_Y",
                                             uom: "mm/s",
                                             min: 0,
                                             max: Float.greatestFiniteMagnitude,
                                             value: speedY)
        
        self.rmsSpeedZ = FeatureField<Float>(name: "RMSSpeed_Z",
                                             uom: "mm/s",
                                             min: 0,
                                             max: Float.greatestFiniteMagnitude,
                                             value: speedZ)
    }
    
}

extension PredictiveSpeedStatusData: CustomStringConvertible {
    public var description: String {
        
        let statusX = statusSpeedX.value ?? .unknown
        let statusY = statusSpeedY.value ?? .unknown
        let statusZ = statusSpeedZ.value ?? .unknown
        
        let speedX = rmsSpeedX.value ?? 0
        let speedY = rmsSpeedY.value ?? 0
        let speedZ = rmsSpeedZ.value ?? 0
        
        return String(format: "Status X: %@\nStatus Y: %@\nStatus Z: %@\nRMS Speed X: %.2f\nRMS Speed Y: %.2f\nRMS Speed Z: %.2f", statusX.description, statusY.description, statusZ.description, speedX, speedY, speedZ)
    }
}

extension PredictiveSpeedStatusData: Loggable {
    public var logHeader: String {
        "\(statusSpeedX.logHeader),\(statusSpeedY.logHeader),\(statusSpeedZ.logHeader),\(rmsSpeedX.logHeader),\(rmsSpeedY.logHeader),\(rmsSpeedZ.logHeader)"
    }
    
    public var logValue: String {
        "\(statusSpeedX.logValue),\(statusSpeedY.logValue),\(statusSpeedZ.logValue),\(rmsSpeedX.logValue),\(rmsSpeedY.logValue),\(rmsSpeedZ.logValue)"
    }
    
}

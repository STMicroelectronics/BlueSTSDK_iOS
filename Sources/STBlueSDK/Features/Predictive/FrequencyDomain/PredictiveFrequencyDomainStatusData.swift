//
//  PredictiveFrequencyDomainStatusData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PredictiveFrequencyDomainStatusData {
    
    public var statusX: FeatureField<PredictiveStatus>
    public var statusY: FeatureField<PredictiveStatus>
    public var statusZ: FeatureField<PredictiveStatus>
    
    public var freqX: FeatureField<Float>
    public var freqY: FeatureField<Float>
    public var freqZ: FeatureField<Float>
    
    public var valueX: FeatureField<Float>
    public var valueY: FeatureField<Float>
    public var valueZ: FeatureField<Float>
    
    public var pointX: (FeatureField<Float>, FeatureField<Float>) {
        (freqX, valueX)
    }
    
    public var pointY: (FeatureField<Float>, FeatureField<Float>) {
        (freqY, valueY)
    }
    
    public var pointZ: (FeatureField<Float>, FeatureField<Float>) {
        (freqZ, valueZ)
    }
    
    init(with data: Data, offset: Int) {
        
        let status = data.extractUInt8(fromOffset: offset)
        let freqX = Float(data.extractUInt16(fromOffset: offset + 1)) / 10.0
        let valueX = Float(data.extractUInt16(fromOffset: offset + 3)) / 100.0
        let freqY = Float(data.extractUInt16(fromOffset: offset + 5)) / 10.0
        let valueY = Float(data.extractUInt16(fromOffset: offset + 3)) / 100.0
        let freqZ = Float(data.extractUInt16(fromOffset: offset + 9)) / 10.0
        let valueZ = Float(data.extractUInt16(fromOffset: offset + 3)) / 100.0
        
        let statusX = PredictiveStatus.extractXStatus(status)
        let statusY = PredictiveStatus.extractYStatus(status)
        let statusZ = PredictiveStatus.extractZStatus(status)
        
        self.statusX = FeatureField<PredictiveStatus>(name: "StatusFreq_X",
                                                      uom: nil,
                                                      min: nil,
                                                      max: nil,
                                                      value: statusX)
        
        self.statusY = FeatureField<PredictiveStatus>(name: "StatusFreq_Y",
                                                      uom: nil,
                                                      min: nil,
                                                      max: nil,
                                                      value: statusY)
        
        self.statusZ = FeatureField<PredictiveStatus>(name: "StatusFreq_Z",
                                                      uom: nil,
                                                      min: nil,
                                                      max: nil,
                                                      value: statusZ)
        
        self.freqX = FeatureField<Float>(name: "Freq_X",
                                         uom: nil,
                                         min: 0,
                                         max: Float.greatestFiniteMagnitude,
                                         value: freqX)
        
        self.freqY = FeatureField<Float>(name: "Freq_Y",
                                         uom: nil,
                                         min: 0,
                                         max: Float.greatestFiniteMagnitude,
                                         value: freqY)
        
        self.freqZ = FeatureField<Float>(name: "Freq_Z",
                                         uom: nil,
                                         min: 0,
                                         max: Float.greatestFiniteMagnitude,
                                         value: freqZ)
        
        self.valueX = FeatureField<Float>(name: "MaxAmplitude_X",
                                          uom: nil,
                                          min: 0,
                                          max: Float.greatestFiniteMagnitude,
                                          value: valueX)
        
        self.valueY = FeatureField<Float>(name: "MaxAmplitude_Y",
                                          uom: nil,
                                          min: 0,
                                          max: Float.greatestFiniteMagnitude,
                                          value: valueY)
        
        self.valueZ = FeatureField<Float>(name: "MaxAmplitude_Z",
                                          uom: nil,
                                          min: 0,
                                          max: Float.greatestFiniteMagnitude,
                                          value: valueZ)
    }
    
}

extension PredictiveFrequencyDomainStatusData: CustomStringConvertible {
    public var description: String {
        
        let statusX = statusX.value ?? .unknown
        let statusY = statusY.value ?? .unknown
        let statusZ = statusZ.value ?? .unknown
        
        let freqX = freqX.value ?? 0
        let freqY = freqY.value ?? 0
        let freqZ = freqZ.value ?? 0
        
        let valueX = valueX.value ?? 0
        let valueY = valueY.value ?? 0
        let valueZ = valueZ.value ?? 0
        
        return String(format: "Status X: %@\nStatus Y: %@\nStatus Z: %@\nFreq X: %.2f\nFreq Y: %.2f\nFreq Z: %.2f\nValue X: %.2f\nValue Y: %.2f\nValue Z: %.2f", statusX.description, statusY.description, statusZ.description, freqX, freqY, freqZ, valueX, valueY, valueZ)
    }
}

extension PredictiveFrequencyDomainStatusData: Loggable {
    public var logHeader: String {
        "\(statusX.logHeader),\(statusY.logHeader),\(statusZ.logHeader),\(freqX.logHeader),\(freqY.logHeader),\(freqZ.logHeader),\(valueX.logHeader),\(valueY.logHeader),\(valueZ.logHeader)"
    }
    
    public var logValue: String {
        "\(statusX.logValue),\(statusY.logValue),\(statusZ.logValue),\(freqX.logValue),\(freqY.logValue),\(freqZ.logValue),\(valueX.logValue),\(valueY.logValue),\(valueZ.logValue)"
    }
    
}

//
//  FFTAmplitudeData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct FFTAmplitudeData {
    
    private(set) var rawData: Data = Data()
    let rawDataCapacity : Int
    
    public let numberOfSamples: FeatureField<UInt16>
    public let numberOfComponents: FeatureField<UInt8>
    public let frequencyStep: FeatureField<Float>
    public var dataLoadPercentage: FeatureField<UInt8> {
        return FeatureField<UInt8>(name: "DataLoadPercentage",
                                       uom: "%",
                                       min: 0,
                                       max: 100,
                                       value: UInt8((rawData.count * 100) / rawDataCapacity))
    }
    
    init(with data: Data, offset: Int) {
        let numberOfSamples = data.extractUInt16(fromOffset: offset)
        let numberOfComponents = data.extractUInt8(fromOffset: offset + 2)
        let frequencyStep = Float(data.extractUInt16(fromOffset: offset + 3))
        
        let fftData = data.subdata(in: Int(offset + 7)..<data.count)
        rawData.append(fftData)
        
        rawDataCapacity = Int(numberOfSamples) * Int(numberOfComponents) * 4
        
        self.numberOfSamples = FeatureField<UInt16>(name: "N Sample",
                                         uom: nil,
                                         min: 0,
                                         max: UInt16.max,
                                         value: numberOfSamples)
        
        self.numberOfComponents = FeatureField<UInt8>(name: "N Components",
                                        uom: nil,
                                        min: 0,
                                        max: UInt8.max,
                                        value: numberOfComponents)
        
        self.frequencyStep = FeatureField<Float>(name: "Frequency Step",
                                        uom: "Hz",
                                        min: 0,
                                        max: Float.greatestFiniteMagnitude,
                                        value: frequencyStep)
    }
    
    public func getComponent(index: Int) -> [Float]? {
        if let numberOfComponents = self.numberOfComponents.value {
            if let numberOfSamples = self.numberOfSamples.value {
                guard index >= 0 && index<numberOfComponents else{
                    return nil
                }
                let startIndex = index*Int(numberOfSamples)*4
                return rawData.extractFloat(startOffset: UInt(startIndex), nFloat: UInt(numberOfSamples))
            }
        }
        return nil
    }
    
}

public extension FFTAmplitudeData {
    
    var isCompleted: Bool {
        get {
            return rawData.count >= rawDataCapacity
        }
    }
    
    mutating func append(_ data: Data) {
        rawData.append(data)
    }
}

extension FFTAmplitudeData: CustomStringConvertible {
    public var description: String {
        
        let dataLoadPercentage = dataLoadPercentage.value ?? 0
        let numberOfSamples = numberOfSamples.value ?? 0
        let numberOfComponents = numberOfComponents.value ?? 0
        let frequencyStep = frequencyStep.value ?? 0
        
        return String(format: "Data Load Percentage: %zd\nNumber Of Samples: %zd\nNumber Of Components: %zd\nFrequency Step: %.4f", dataLoadPercentage, numberOfSamples, numberOfComponents, frequencyStep)
    }
}

extension FFTAmplitudeData: Loggable {
    public var logHeader: String {
        "\(dataLoadPercentage.logHeader),\(numberOfSamples.logHeader),\(numberOfComponents.logHeader),\(frequencyStep.logHeader)"
    }
    
    public var logValue: String {
        "\(dataLoadPercentage.logValue),\(numberOfSamples.logValue),\(numberOfComponents.logValue),\(frequencyStep.logValue)"
    }
    
}

fileprivate extension Data {
    func extractFloat(startOffset: UInt, nFloat:UInt)->[Float]?{
        guard (UInt(count)-startOffset) >= nFloat*4 else {
            return nil
        }

        var floatData = Array<Float>(repeating: 0.0, count: Int(nFloat))
        let nsData = (self as Data)
        for i in 0..<Int(nFloat) {
            floatData[i] = nsData.extractFloat(fromOffset: Int(startOffset)+i*4)
        }

        return floatData
    }
}

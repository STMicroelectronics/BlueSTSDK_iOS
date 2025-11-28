//
//  MedicalInfo.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//
import Foundation

public struct MedicalInfo {
    
    public let internalTimeStamp: FeatureField<Int>
    public let sigType: FeatureField<MedicalSignalType>
    public let values: FeatureField<[Int]>
    
    init(internalTimeStamp: Int, sigType: MedicalSignalType , values: [Int]) {
        self.internalTimeStamp = FeatureField<Int>(name: "Internal TimeStamp", uom: nil, min: nil, max: nil, value: internalTimeStamp)
        self.sigType  = FeatureField<MedicalSignalType>(name: "Signal Type", uom: nil, min: nil, max: nil, value: sigType)
        self.values = FeatureField<[Int]>(name: "Samples", uom: nil, min: nil, max: nil, value: values)
    }
}

extension MedicalInfo: CustomStringConvertible {
    public var description: String {

        let internalTimeStamp = internalTimeStamp.value
        let signalType = sigType.value
        let samples = values.value
        
        let response: String =
        if signalType!.numberOfSignals == 1 {
            "TimeStamp: \(internalTimeStamp!)\n\tSigType: \(signalType!.description)\n\tSamples: \(samples!)"
        } else {
            "TimeStamp: \(internalTimeStamp!)\n\tSigType: \(signalType!.description)\n\tSamples: \(samples!.splitByChunk(signalType!.numberOfSignals))"
        }

        return response
    }
}

extension MedicalInfo: Loggable {
    public var logHeader: String {
        "TBD"
    }

    public var logValue: String {
        "TBD"
    }
    
}

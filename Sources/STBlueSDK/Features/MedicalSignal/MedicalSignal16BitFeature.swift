//
//  MedicalSignal16BitFeature.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class MedicalSignal16BitFeature: TimestampFeature<MedicalInfo> {
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        
        //at least 4 bytes for timestamp, 1 for Medical Signal type and 1 sample of 16bits
        if data.count - offset < 4+1+2 {
            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
        }
        
        let internalTimeStamp = Int(data.extractInt32(fromOffset: offset))
        let sigType = data.extractUInt8(fromOffset: offset+4).MedicalSignalByte()
        
        if ((sigType.precision != .ubit16)  && (sigType.precision != .bit16)) {
            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
        }
        
        let numberOfSamples = (data.count - offset - 5) / 2
        
        var samples: [Int] = []
        if sigType.precision == .ubit16 {
            for counter in 0..<numberOfSamples {
                samples.append(Int(data.extractUInt16(fromOffset: offset+5+2*counter)))
            }
        } else {
            for counter in 0..<numberOfSamples {
                samples.append(Int(data.extractInt16(fromOffset: offset+5+2*counter)))
            }
        }
                
        let parsedData = MedicalInfo(internalTimeStamp: internalTimeStamp, sigType: sigType, values: samples)
                
        return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), data.count)
    }
}

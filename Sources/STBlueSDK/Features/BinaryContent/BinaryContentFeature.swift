//
//  BinaryContentFeature.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class BinaryContentFeature: TimestampFeature<BinaryContentData> {
    
    public required init(name: String, type: FeatureType) {
        super.init(name: name, type: type)
        isDataNotifyFeature = false
    }
    
    private let dataTransporter = DataTransporter()
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        if let decodedData = dataTransporter.decapsulate(data: data) {
            
            let dataRec = BinaryContentData(with: decodedData,bytesRec: dataTransporter.bytesRec, numberPackets: dataTransporter.numberPackets)
            
            dataTransporter.clear()
            return (FeatureSample(with: timestamp, data: dataRec as? T, rawData: data), 0)
        } else {
            let dataRec = BinaryContentData(with: Data() ,bytesRec: dataTransporter.bytesRec, numberPackets: dataTransporter.numberPackets)
            return (FeatureSample(with: timestamp, data: dataRec as? T, rawData: data), data.count)
        }
    }
}

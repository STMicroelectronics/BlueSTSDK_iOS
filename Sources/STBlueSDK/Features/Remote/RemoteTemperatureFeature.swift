//
//  RemoteTemperatureFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class RemoteTemperatureFeature: BaseFeature<RemoteData<TemperatureData>> {
    
    var unwrapNode: [UInt16: UnwrapTimeStamp] = [UInt16: UnwrapTimeStamp]()
    let packetLength = 2
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        guard let remoteData = remoteExtractData(with: timestamp,
                                                 data: data,
                                                 offset: offset,
                                                 nodeUnwrapper: &unwrapNode) else {
            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
        }
        
        if data.count - remoteData.offset < packetLength {
            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
        }
        
        let parsedData = RemoteData<TemperatureData>(remoteId: remoteData.remoteId,
                                                     data: TemperatureData(with: data, offset: remoteData.offset))
        
        return (FeatureSample(with: remoteData.timestamp, data: parsedData as? T, rawData: data), packetLength + remoteData.offset)
    }

}

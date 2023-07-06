//
//  OpusAudioFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class OpusAudioFeature: AudioFeature<OpusAudioData> {
    
    private let manager = OpusCodecManager()
    private let engine = OpusEngine()
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
    
        if data.count - offset < 20 {
            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
        }
        
        let parsedData = OpusAudioData(with: data, offset: offset, engine: engine, manager: manager)
        
        return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), 20)
    }

    public override func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse {
        response
    }
}

extension OpusAudioFeature: AudioDataFeature {
    
    public var rawData: Data? {
        nil
    }
    
    public var codecManager: AudioCodecManager {
        manager
    }
    
    public var audio: Data? {
        sample?.data?.audio
    }
}

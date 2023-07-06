//
//  ADPCMAudioFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class ADPCMAudioFeature: AudioFeature<ADPCMAudioData> {
    
    private let engine = ADPCMEngine()
    private let manager = ADPCMCodecManager()
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
    
        if data.count - offset < 20 {
            return (FeatureSample(with: nil, rawData: data), 0)
        }
        
        let parsedData = ADPCMAudioData(with: data, offset: offset, engine: engine, manager: manager)
        
        return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), 20)
    }

    public override func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse {
        response
    }
}

extension ADPCMAudioFeature: AudioDataFeature {
    
    public var rawData: Data? {
        sample?.rawData
    }
    
    public var codecManager: AudioCodecManager {
        manager
    }
    
    public var audio: Data? {
        sample?.data?.audio
    }
}

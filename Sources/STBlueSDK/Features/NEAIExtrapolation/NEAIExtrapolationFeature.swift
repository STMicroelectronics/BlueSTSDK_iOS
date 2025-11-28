//
//  NEAIExtrapolationFeature.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class NEAIExtrapolationFeature: TimestampFeature<NEAIExtrapolationData> {
        
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        
        var dataRec = data
        
        do {
            dataRec.removeLast()
            let neaiExtrapolation = try JSONDecoder().decode(NEAIExtrapolation.self, from: dataRec)
            return (FeatureSample(with: timestamp, data: NEAIExtrapolationData(neaiExtrapolation: neaiExtrapolation) as? T, rawData: data),  data.count)
        } catch {
            STBlueSDK.log(text: "Extract Data parse error: \(error)")
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        }
   }

}

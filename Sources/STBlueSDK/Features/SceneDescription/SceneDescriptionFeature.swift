//
//  SceneDescriptionFeature.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class SceneDescriptionFeature: BaseFeature<SceneDescriptionData> {
    
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        
        let parsedData = SceneDescriptionData(with: data, offset: offset)
        
        return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), data.count - offset)
    }
    
}

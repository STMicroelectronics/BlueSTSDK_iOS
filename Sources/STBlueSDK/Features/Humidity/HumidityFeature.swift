//
//  HumidityFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class HumidityFeature: BaseFeature<HumidityData> {

    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {

        if (data.count - offset < 2) {
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        }
        let humidityData = HumidityData(with: data, offset: offset)

        return (FeatureSample(with: timestamp, data: humidityData as? T, rawData: data), 2)
    }
}

//
//  ActivityFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class ActivityFeature: BaseFeature<ActivityData> {
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> BaseFeature<ActivityData>.FeatureExtractDataResult<T> where T : Loggable {
        let packageSize = data.count - offset
        
        switch packageSize {
        case Int.min..<1:
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        case 1 :
            let activityData = ActivityData(withActivityData: data, offset: offset)
            return (FeatureSample(with: timestamp, data: activityData as? T, rawData: data), 1)
        default: // else
            let activityData = ActivityData(withActivityAndAlgorithmData: data, offset: offset)
            return (FeatureSample(with: timestamp, data: activityData as? T, rawData: data), 2)
        }
    }
    
}

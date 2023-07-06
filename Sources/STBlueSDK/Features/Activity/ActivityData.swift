//
//  ActivityData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct ActivityData {

    public let activity: FeatureField<ActivityType>
    public let date: FeatureField<Double>
    public let algorithmId: FeatureField<UInt8>


    init(withActivityData data: Data, offset: Int) {
    
        let activity: ActivityType = ActivityType(rawValue: data.extractUInt8(fromOffset: offset)) ?? .error
        let date: Double = Date.timeIntervalSinceReferenceDate * 1000.0
        
        self.activity = FeatureField<ActivityType>(name: "Activity",
                                                   uom: nil,
                                                   min: nil,
                                                   max: nil,
                                                   value: activity)
        
        self.date = FeatureField<Double>(name: "Date",
                                         uom: nil,
                                         min: 0,
                                         max: Double.infinity,
                                         value: date)
        
        self.algorithmId = FeatureField<UInt8>(name: "AlgorithmId",
                                               uom: nil,
                                               min: 0,
                                               max: UInt8.max,
                                               value: nil)
    }
    
    init(withActivityAndAlgorithmData data: Data, offset: Int) {
    
        let activity: ActivityType = ActivityType(rawValue: data.extractUInt8(fromOffset: offset)) ?? .error
        let date: Double = Date.timeIntervalSinceReferenceDate * 1000.0
        let algorithmId = data.extractUInt8(fromOffset: offset + 1)
        
        self.activity = FeatureField<ActivityType>(name: "Activity",
                                                   uom: nil,
                                                   min: nil,
                                                   max: nil,
                                                   value: activity)
        
        self.date = FeatureField<Double>(name: "Date",
                                         uom: nil,
                                         min: 0,
                                         max: Double.infinity,
                                         value: date)
        
        self.algorithmId = FeatureField<UInt8>(name: "AlgorithmId",
                                               uom: nil,
                                               min: 0,
                                               max: UInt8.max,
                                               value: algorithmId)
    }
}

extension ActivityData: CustomStringConvertible {
    public var description: String {

        let activity = activity.value ?? .error
        let date = date.value ?? -1
        let algorithmId = algorithmId.value ?? 0

        return String(format: "Activity: %zd\nDate: %.4f\nAlgorithmId: \(algorithmId)", activity.rawValue, date)
    }
}

extension ActivityData: Loggable {
    public var logHeader: String {
        "\(activity.logHeader),\(date.logHeader),\(algorithmId.logHeader)"
    }

    public var logValue: String {
        "\(activity.logValue),\(date.logValue),\(algorithmId.logValue)"
    }
}

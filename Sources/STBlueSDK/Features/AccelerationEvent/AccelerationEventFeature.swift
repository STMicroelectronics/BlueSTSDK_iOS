//
//  AccelerationEventFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class AccelerationEventFeature: BaseFeature<AccelerationEventData>, CommandFeature {
    
    public var commands: [FeatureCommandType] = [
        AccelerationEventCommand.orientation(enabled: true),
        AccelerationEventCommand.orientation(enabled: false),
        AccelerationEventCommand.multiple(enabled: true),
        AccelerationEventCommand.multiple(enabled: false),
        AccelerationEventCommand.tilt(enabled: true),
        AccelerationEventCommand.tilt(enabled: false),
        AccelerationEventCommand.freeFall(enabled: true),
        AccelerationEventCommand.freeFall(enabled: false),
        AccelerationEventCommand.singleTap(enabled: true),
        AccelerationEventCommand.singleTap(enabled: false),
        AccelerationEventCommand.doubleTap(enabled: true),
        AccelerationEventCommand.doubleTap(enabled: false),
        AccelerationEventCommand.wakeUp(enabled: true),
        AccelerationEventCommand.wakeUp(enabled: false),
        AccelerationEventCommand.pedometer(enabled: true),
        AccelerationEventCommand.pedometer(enabled: false),
        AccelerationEventCommand.none
    ]
    
    public var isPedometerEnabled = false
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {

        if data.count - offset >= 3 {
            return extractEventAndPedomiterData(with: timestamp, data: data, offset: offset)
        } else if data.count - offset >= 2 && isPedometerEnabled {
            return extractPedometerData(with: timestamp, data: data, offset: offset)
        } else {
            return extractEventData(with: timestamp, data: data, offset: offset)
        }
    }

    public override func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse {
        response
    }

}

private extension AccelerationEventFeature {
    func extractEventAndPedomiterData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        let parsedData = AccelerationEventData(eventAndPedometerWith: data, offset: offset)
        
        return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), 3)
    }
    
    func extractPedometerData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        let parsedData = AccelerationEventData(pedometerWith: data, offset: offset)
        
        return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), 2)
    }
    
    func extractEventData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        
        if data.count - offset < 1 {
            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
        }
        
        let parsedData = AccelerationEventData(eventWith: data, offset: offset)
        
        return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), 1)
    }
}

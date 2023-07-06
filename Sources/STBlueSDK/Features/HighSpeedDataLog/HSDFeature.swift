//
//  HSDFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class HSDFeature: BaseFeature<HSDData> {
    
    let dataTransporter = DataTransporter()
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        
        if let commandFrame = dataTransporter.decapsulate(data: data) {
            let response = HSDDeviceParser.responseFrom(data: commandFrame)
            let deviceStatus = HSDDeviceParser.deviceStatusFrom(data: commandFrame)
            let tagConfig = HSDDeviceParser.tagConfigFrom(data: commandFrame)
            
            var currentDevice: HSDDevice?
            var currentDeviceStatus: HSDDeviceStatus?
            var currentTagConfig: HSDTagConfig?
            
            if let device = response?.device {
                currentDevice = device
                currentTagConfig = device.tagConfig
            }
            
            if let deviceStatus = deviceStatus {
                currentDeviceStatus = deviceStatus
            }
            
            if let tagConfig = tagConfig {
                currentTagConfig = tagConfig.tagConfig
            }
            
            currentTagConfig?.updateTypes()
            
            guard let device = currentDevice,
                  let deviceStatus = currentDeviceStatus,
                  let tagConfig = currentTagConfig else {
                return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
            }
            
            let parsedData = HSDData(with: device,
                                     deviceStatus: deviceStatus,
                                     tagConfig: tagConfig)
            
            return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), data.count)
        }
        
        return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
    }
    
}

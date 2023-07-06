//
//  HSDData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct HSDData {
    
    public let device: FeatureField<HSDDevice>
    public let deviceStatus: FeatureField<HSDDeviceStatus>
    public let tagConfig: FeatureField<HSDTagConfig>
    
    init(with device: HSDDevice, deviceStatus: HSDDeviceStatus, tagConfig: HSDTagConfig) {
        
        self.device = FeatureField<HSDDevice>(name: "HSDDevice",
                                              uom: nil,
                                              min: nil,
                                              max: nil,
                                              value: device)
        
        self.deviceStatus = FeatureField<HSDDeviceStatus>(name: "HSDDeviceStatus",
                                                          uom: nil,
                                                          min: nil,
                                                          max: nil,
                                                          value: deviceStatus)
        
        self.tagConfig = FeatureField<HSDTagConfig>(name: "HSDTagConfig",
                                                    uom: nil,
                                                    min: nil,
                                                    max: nil,
                                                    value: tagConfig)
    }
    
}

extension HSDData: CustomStringConvertible {
    public var description: String {
        
        let device = device.value.debugDescription
        let deviceStatus = deviceStatus.value.debugDescription
        let tagConfig = tagConfig.value.debugDescription
        
        return String(format: "Device: %@\nDevice status: %@\nTag config: %@", device, deviceStatus, tagConfig)
    }
}

extension HSDData: Loggable {
    public var logHeader: String {
        "\(device.logHeader),\(deviceStatus.logHeader),\(tagConfig.logHeader)"
    }
    
    public var logValue: String {
        "\(device.logValue),\(deviceStatus.logValue),\(tagConfig.logValue)"
    }
    
}

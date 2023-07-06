//
//  HSDDevice.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class HSDDevice: Codable {
    public let deviceInfo: HSDDeviceInfo
    public var sensor: [HSDSensor]
    public var tagConfig: HSDTagConfig
    
    public func sensorWithId(_ id: Int) -> HSDSensor? {
        sensor.first(where: { $0.id == id })
    }
}

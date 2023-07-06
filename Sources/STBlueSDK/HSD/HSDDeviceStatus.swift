//
//  HSDDeviceStatus.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct HSDDeviceStatus: Codable {
    public let type: String?
    public let isLogging: Bool?
    public let isSDInserted: Bool?
    public let cpuUsage: Double?
    public let batteryVoltage: Double?
    public let batteryLevel: Double?
    public let ssid: String?
    public let password: String?
    public let ip: String?
    public let sensorId: Int?
    public let sensorStatus: HSDSensor.SensorStatusDescriptor?
}

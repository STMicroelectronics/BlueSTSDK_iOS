//
//  HSDSubSensor.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit

public class HSDSubSensor: Codable {
    public enum SensorType: String, Codable {
        case Accelerometer = "ACC"
        case Magnetometer = "MAG"
        case Gyroscope = "GYRO"
        case Temperature = "TEMP"
        case Humidity = "HUM"
        case Pressure = "PRESS"
        case Microphone = "MIC"
        case MLC = "MLC"
        case Unknown = ""
    }
    
    public let id: Int
    public let sensorType: String
    public let dimensions: Int
    public let dimensionsLabel: [String]
    public let unit: String?
    public let dataType: String?
    public let FS: [Double]?
    public let ODR: [Double]?
    public let samplesPerTs: HSDSamplesPerTs
    
    public var type: SensorType {
        SensorType(rawValue: sensorType) ?? .Unknown
    }
}

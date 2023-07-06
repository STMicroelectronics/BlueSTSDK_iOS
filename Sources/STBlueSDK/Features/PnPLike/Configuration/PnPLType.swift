//
//  PnPLType.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public enum PnPLType: String, Codable {
    case accelerometer = "acc"
    case magnetometer = "mag"
    case gyroscope = "gyro"
    case temperature = "temp"
    case humidity = "hum"
    case pressure = "press"
    case microphone = "mic"
    case mlc = "mlc"
    case unknown = ""
}

public extension PnPLType {
    var iconName: String {
        switch self {
        case .accelerometer:
            return "ic_accelerometer"
        case .magnetometer:
            return "ic_magnetometer"
        case .gyroscope:
            return "ic_gyroscope"
        case .temperature:
            return "ic_termometer"
        case .humidity:
            return "ic_humidity"
        case .pressure:
            return "ic_pressure"
        case .microphone:
            return "ic_microphone"
        case .mlc:
            return "ic_mlc"
        case .unknown:
            return "ic_unknown"
        }
    }

    var nameKey: String? {
        switch self {
        case .accelerometer:
            return "st_pnpl_text_accelerometer"
        case .magnetometer:
            return "st_pnpl_text_magnetometer"
        case .gyroscope:
            return "st_pnpl_text_gyroscope"
        case .temperature:
            return "st_pnpl_text_temperature"
        case .humidity:
            return "st_pnpl_text_humidity"
        case .pressure:
            return "st_pnpl_text_pressure"
        case .microphone:
            return "st_pnpl_text_microphone"
        case .mlc:
            return "st_pnpl_text_mlc"
        case .unknown:
            return nil
        }
    }

    static func type(with sensorName: String) -> PnPLType {
        if let type = PnPLType(rawValue: sensorName) {
            return type
        } else if sensorName.contains("_") {
            let components = sensorName.components(separatedBy: "_")
            let type = PnPLType(rawValue: components[1])
            return type ?? .unknown
        } else {
            return .unknown
        }
    }
}

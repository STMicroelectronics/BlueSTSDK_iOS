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
    case classs = "class"
    case stredl = "stredl"
    case timeOfFlight = "tof"
    case ambientLightSensor = "als" ///Ambient Light Sensor
    case tmosInfrared = "tmos"
    case powerMeter = "pow"
    case ispu = "ispu"
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
        case .classs:
            return "ic_algorithm"
        case .stredl:
            return "ic_algorithm"
        case .timeOfFlight:
            return "ic_tof"
        case .ambientLightSensor:
            return "ic_als"
        case .tmosInfrared:
            return "ic_tmos"
        case .powerMeter:
            return "ic_pow"
        case .ispu:
            return "ic_ispu"
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
        case .classs:
            return "CLASS"
        case .stredl:
            return "STREDL"
        case .timeOfFlight:
            return "Time of Flight"
        case .ambientLightSensor:
            return "Ambient Light"
        case .tmosInfrared:
            return "Infrared"
        case .powerMeter:
            return "Power Meter"
        case .ispu:
            return "ISPU"
        }
    }

    static func type(with sensorName: String) -> PnPLType {
        if let type = PnPLType(rawValue: sensorName) {
            return type
        } else if sensorName.contains("_") {
            let components = sensorName.components(separatedBy: "_")
            var type: PnPLType = .unknown
            if let lastComponent = components.last {
                if let pnplType = PnPLType(rawValue: lastComponent) {
                    type = pnplType
                }
            }
            return type
        } else {
            return .unknown
        }
    }
}

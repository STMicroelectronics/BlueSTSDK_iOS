//
//  BatteryData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum BatteryStatus: UInt8 {
    /**
     *  The battery has a level below the 10%
     */
    case low = 0x00
    /**
     *  The battery is discharging
     */
    case discharging = 0x01
    /**
     *  The battery is plugged, but is already charged
     */
    case pluggedNotCharging = 0x02
    /**
     *  the battery is charging
     */
    case charging = 0x03
    /**
     *  the battery is unknown
     */
    case unknown = 0x04
    /**
     *  error state/battery not present
     */
    case error = 0xFF
}

extension BatteryStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .low:
            return "Low battery"
        case .discharging:
            return "Discharging"
        case .pluggedNotCharging:
            return "Plugged"
        case .charging:
            return "Charging"
        case .unknown:
            return "Unknown"
        case .error:
            return "Error"
        }
    }
}

public struct BatteryData {

    public let level: FeatureField<Float>
    public let voltage: FeatureField<Float>
    public let current: FeatureField<Float>
    public var status: BatteryStatus {
        guard let value = internalStatus.value else { return .unknown }
        return BatteryStatus(rawValue: value) ?? .unknown
    }

    private let internalStatus: FeatureField<UInt8>

    init(level: Float, voltage: Float, current: Float, status: UInt8) {

        self.level = FeatureField<Float>(name: "Level",
                                         uom: "%",
                                         min: 0,
                                         max: 100,
                                         value: level)

        self.voltage = FeatureField<Float>(name: "Voltage",
                                           uom: "V",
                                           min: -10,
                                           max: 10,
                                           value: voltage)

        self.current = FeatureField<Float>(name: "Current",
                                           uom: "mA",
                                           min: -10,
                                           max: 10,
                                           value: current)

        self.internalStatus = FeatureField<UInt8>(name: "Status",
                                                  uom: nil,
                                                  min: 0,
                                                  max: 0xFF,
                                                  value: status)
    }
}

extension BatteryData: CustomStringConvertible {
    public var description: String {

        let level = level.value ?? -1
        let voltage = voltage.value ?? -1
        let current = current.value ?? -1

        return String(format: "Level: %.2f\nVoltage: %.4f\nCurrent: %.4f\nStatus: \(status.description)", level, voltage, current)
    }
}

extension BatteryData: Loggable {
    public var logHeader: String {
        "\(level.logHeader),\(voltage.logHeader),\(current.logHeader),\(internalStatus.logHeader)"
    }

    public var logValue: String {
        "\(level.logValue),\(voltage.logValue),\(current.logValue),\(internalStatus.logValue)"
    }
}

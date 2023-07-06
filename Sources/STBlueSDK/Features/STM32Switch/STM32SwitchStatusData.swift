//
//  STM32SwitchStatusData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct STM32SwitchStatusData {

    public let deviceId: FeatureField<UInt8>
    public let status: FeatureField<UInt8>

    init(with data: Data, offset: Int) {
        
        let deviceId = data.extractUInt8(fromOffset: offset)
        let status = data.extractUInt8(fromOffset: offset + 1)

        self.deviceId = FeatureField<UInt8>(name: "DeviceId",
                                         uom: nil,
                                         min: 0,
                                         max: 6,
                                         value: deviceId)

        self.status = FeatureField<UInt8>(name: "SwitchPressed",
                                           uom: nil,
                                           min: 0,
                                           max: 1,
                                           value: status)
    }
}

extension STM32SwitchStatusData: CustomStringConvertible {
    public var description: String {

        let deviceId = deviceId.value ?? 0
        let status = status.value ?? 0

        return String(format: "deviceId: \(deviceId)\nstatus: \(status)")
    }
}

extension STM32SwitchStatusData: Loggable {
    public var logHeader: String {
        "\(deviceId.logHeader),\(status.logHeader)"
    }

    public var logValue: String {
        "\(deviceId.logValue),\(status.logValue)"
    }
}

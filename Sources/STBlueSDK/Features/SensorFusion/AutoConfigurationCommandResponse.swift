//
//  AutoConfigurationCommandResponse.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum AutoConfigurationStatus: UInt8 {
    case notConfigured = 0
    case configured = 100
}

public class AutoConfigurationCommandResponse: BaseCommandResponse {
    public var status: AutoConfigurationStatus {
        get {
            if commandType == AutoConfigurationCommand.get.rawValue {
                return AutoConfigurationStatus(rawValue: data.extractUInt8(fromOffset: 0)) ?? .notConfigured
            }

            return .notConfigured
        }
    }
}

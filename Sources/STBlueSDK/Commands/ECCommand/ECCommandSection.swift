//
//  ECCommandSection.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum ECCommandSection: String {
    case boardReport
    case boardSecurity
    case boardControl
    case boardSettings
    case customCommands
}

public extension ECCommandSection {
    var title: String {
        "st_extconf_command_section_\(rawValue)Title"
    }
    
    var iconName: String {
        switch self {
            case .boardReport:
                return "ic_ext_conf_report"
            case .boardSecurity:
                return "ic_ext_conf_security"
            case .boardControl:
                return "ic_ext_conf_control"
            case .boardSettings:
                return "ic_ext_conf_settings"
            case .customCommands:
                return "ic_ext_conf_custom_commands"
        }
    }
    
    var commands: [ECCommandType] {
        switch self {
            case .boardReport:
                return [.UID, .versionFw, .info, .help, .powerStatus]
            case .boardSecurity:
                return [.changePIN, .clearDB, .readCert, .setCert]
            case .boardControl:
                return [.DFU, .off, .readBankStatus, .bankSwap]
            case .boardSettings:
                return [.setName, .readCustomCommand, .setTime, .setDate, .setWiFi]
            case .customCommands:
                return []
        }
    }
}

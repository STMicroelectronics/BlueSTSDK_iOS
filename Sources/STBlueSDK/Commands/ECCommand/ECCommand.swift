//
//  ECCommand.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum ECCommandType: String {
    case UID = "UID"
    case versionFw = "VersionFw"
    case info = "Info"
    case help = "Help"
    case powerStatus = "PowerStatus"
    case changePIN = "ChangePIN"
    case clearDB = "ClearDB"
    case DFU = "DFU"
    case off = "Off"
    
    case setTime = "SetTime"
    case setDate = "SetDate"
    case setWiFi = "SetWiFi"
    case setSensorsConfig = "SetSensorsConfig"
    case setName = "SetName"
    case setCert = "SetCert"

    case readCommand = "ReadCommand"
    case readCert = "ReadCert"
    case readSensorsConfig = "ReadSensorsConfig"
    case readCustomCommand = "ReadCustomCommand"
    case readBankStatus = "ReadBanksFwId"

    case bankSwap = "BanksSwap"
}

public extension ECCommandType {
    var title: String {
        "st_extconf_command_text_command\(rawValue)Title"
    }
    
    var executedPhrase: String? {
        switch self {
            case .setDate, .setTime, .clearDB, .DFU, .off:
            return "st_extconf_command_text_command\(rawValue)ExecutedPhrase"
            default:
                return nil
        }
    }
}

public protocol JsonCommand {
    var json: String? { get }
}

public struct ECCommand<T: Encodable>: Encodable, JsonCommand {
    let command: String
    let argString: String?
    let argNumber: Int?
    let argJsonElement: T?
    
    public var jsonData: Data? {
        try? JSONEncoder().encode(self)
    }
    public var json: String? {
        if let data = jsonData,
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return nil
    }
    
    public init(name: String, argString: String? = nil, argNumber: Int? = nil, argJSON: T? = nil) {
        self.command = name
        self.argString = argString
        self.argNumber = argNumber
        self.argJsonElement = argJSON
    }
    
    public init(type: ECCommandType, argString: String? = nil, argNumber: Int? = nil, argJSON: T? = nil) {
        self.init(name: type.rawValue, argString: argString, argNumber: argNumber, argJSON: argJSON)
    }
    
    public func jsonWithHSDSetCommand(_ command: HSDSetCmd) -> String? {
        let serialized: EncodableDictionary = [
            "command": AnyEncodable(self.command),
            "argJsonElement": AnyEncodable(command.serialized)
        ]
        
        STBlueSDK.log(text: "\(serialized)")
        
        if let data = try? JSONEncoder().encode(serialized),
           let json = String(data: data, encoding: .utf8) {
            STBlueSDK.log(text: "\(json)")
            return json
        }
        
        return nil
    }
}

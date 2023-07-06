//
//  ECResponse.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct BankStatusResponse: Codable {
    public let currentBank: Int
    public let fwId1: String
    public let fwId2: String

    enum CodingKeys: String, CodingKey {
        case currentBank, fwId1, fwId2
    }
 }

public class ECResponse: Codable {
    enum CodingKeys: String, CodingKey {
        case commands = "Commands"
        case customCommands = "CustomCommands"
        
        case UID = "UID"
        case versionFw = "VersionFw"
        case info = "Info"
        case help = "Help"
        case powerStatus = "PowerStatus"
        case changePIN = "ChangePIN"
        case clearDB = "ClearDB"
        case DFU = "DFU"
        case off = "Off"
        case bankStatus = "BankStatus"
        case bankSwap = "BanksSwap"
        case setTime = "SetTime"
        case setDate = "SetDate"
        case setWiFi = "SetWiFi"
        case setSensorsConfig = "SetSensorsConfig"
        case setName = "SetName"
        case setCert = "SetCert"
        case readCommand = "ReadCommand"
        case readCert = "Certificate"
        case sensors = "sensor"
    }
    
    let commands: String?

    public let UID: String?
    public let versionFw: String?
    public let info: String?
    public let help: String?
    public let powerStatus: String?
    public let changePIN: String?
    public let clearDB: String?
    public let DFU: String?
    public let off: String?
    public let bankStatus: BankStatusResponse?
    public let bankSwap: String?
    public let setTime: String?
    public let setDate: String?
    public let setWiFi: String?
    public let setSensorsConfig: String?
    public let setName: String?
    public let setCert: String?
    public let readCommand: String?
    public let readCert: String?
    public let sensors: [HSDSensor]?
    public let customCommands: [ECCustomCommand]?
    
    public var type: ECCommandType? {
        if commands != nil { return .readCommand }
        if UID != nil { return .UID }
        if versionFw != nil { return .versionFw }
        if info != nil { return .info }
        if help != nil { return .help }
        if powerStatus != nil { return .powerStatus }
        if changePIN != nil { return .changePIN }
        if clearDB != nil { return .clearDB }
        if DFU != nil { return .DFU }
        if off != nil { return .off }
        if bankStatus != nil { return .readBankStatus }
        if setTime != nil { return .setTime }
        if setDate != nil { return .setDate }
        if setWiFi != nil { return .setWiFi }
        if setSensorsConfig != nil { return .setSensorsConfig }
        if setName != nil { return .setName }
        if setCert != nil { return .setCert }
        if readCommand != nil { return .readCommand }
        if readCert != nil { return .readCert }
        if sensors != nil { return .readSensorsConfig }
        if customCommands != nil { return .readCustomCommand }
        
        return nil
    }
    
    public var stringValue: String? {
        let values = [commands, UID, versionFw, info, help, powerStatus, changePIN, clearDB, DFU, off, setTime, setDate, setWiFi, setSensorsConfig, setName, setCert, readCommand, readCert]
        return values.first { $0 != nil } ?? nil
    }
    
    public var availableCommands: [ECCommandType] {
        commands?.split(separator: ",").compactMap { ECCommandType(rawValue: String($0)) } ?? []
    }
}

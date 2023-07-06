//
//  JsonNFCModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

// MARK: - JsonReadModes
public struct JsonReadModes: Codable {
    public let answer: String?

    enum CodingKeys: String, CodingKey {
        case answer = "Answer"
    }
    
    public init(answer: String?) {
        self.answer = answer
    }
}

// MARK: - JsonWriteCommand
public struct JsonWriteCommand<T: Codable>: Codable {
    public let command: String?
    public let genericText: String?
    public let nfcWiFi: JsonWIFI?
    public let nfcVCard: JsonVCard?
    public let nfcURL: String?

    enum CodingKeys: String, CodingKey {
        case command = "Command"
        case genericText = "GenericText"
        case nfcWiFi = "NFCWiFi"
        case nfcVCard = "NFCVCard"
        case nfcURL = "NFCURL"
    }
    
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
    
    public init(command: String?, genericText: String?, nfcWiFi: JsonWIFI?, nfcVCard: JsonVCard?, nfcURL: String?) {
        self.command = command
        self.genericText = genericText
        self.nfcWiFi = nfcWiFi
        self.nfcVCard = nfcVCard
        self.nfcURL = nfcURL
    }
    
}

// MARK: - JsonWIFI
public struct JsonWIFI: Codable {
    public let networkSSID: String?
    public let networkKey: String?
    public let authenticationType: Int
    public let encryptionType: Int

    enum CodingKeys: String, CodingKey {
        case networkSSID = "NetworkSSID"
        case networkKey = "NetworkKey"
        case authenticationType = "AuthenticationType"
        case encryptionType = "EncryptionType"
    }
    
    public init(networkSSID: String?, networkKey: String?, authenticationType: Int = 0, encryptionType: Int = 0) {
        self.networkSSID = networkSSID
        self.networkKey = networkKey
        self.authenticationType = authenticationType
        self.encryptionType = encryptionType
    }
}

// MARK: - JsonVCard
public struct JsonVCard: Codable {
    public let name: String?
    public let formattedName: String?
    public let title: String?
    public let org: String?
    public let homeAddress: String?
    public let workAddress: String?
    public let address: String?
    public let homeTel: String?
    public let workTel: String?
    public let cellTel: String?
    public let homeEmail: String?
    public let workEmail: String?
    public let url: String?
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case formattedName = "FormattedName"
        case title = "Title"
        case org = "Org"
        case homeAddress = "HomeAddress"
        case workAddress = "WorkAddress"
        case address = "Address"
        case homeTel = "HomeTel"
        case workTel = "WorkTel"
        case cellTel = "CellTel"
        case homeEmail = "HomeEmail"
        case workEmail = "WorkEmail"
        case url = "Url"
    }
    
    public init(name: String?, formattedName: String?, title: String?, org: String?, homeAddress: String?, workAddress: String?, address: String?, homeTel: String?, workTel: String?, cellTel: String?, homeEmail: String?, workEmail: String?, url: String?) {
        self.name = name
        self.formattedName = formattedName
        self.title = title
        self.org = org
        self.homeAddress = homeAddress
        self.workAddress = workAddress
        self.address = address
        self.homeTel = homeTel
        self.workTel = workTel
        self.cellTel = cellTel
        self.homeEmail = homeEmail
        self.workEmail = workEmail
        self.url = url
    }
}

public struct WifiEncryption {
    public let displayName: String
    public let rawValue: Int
    
    public init(_ displayName: String, _ rawValue: Int) {
        self.displayName = displayName
        self.rawValue = rawValue
    }
}

public struct WifiAuthenticationString {
    public let displayName: String
    public let rawValue: Int
    
    public init(_ displayName: String, _ rawValue: Int) {
        self.displayName = displayName
        self.rawValue = rawValue
    }
}

public struct UrlHeaderString {
    public let displayName: String
    public let rawValue: Int
    
    public init(_ displayName: String, _ rawValue: Int) {
        self.displayName = displayName
        self.rawValue = rawValue
    }
}

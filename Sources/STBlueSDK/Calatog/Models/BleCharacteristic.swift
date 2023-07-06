//
//  BleCharacteristic.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct BleCharacteristic {
    public let name: String
    public let uuid: String
    public let dtmiName: String?
    public let description: String?
    public let formatNotify: [BleCharacteristicFormat]?
    public let formatWrite: [BleCharacteristicFormat]?
}

extension BleCharacteristic: Codable {
    enum CodingKeys: String, CodingKey {
        case name
        case uuid
        case dtmiName = "dtmi_name"
        case description
        case formatNotify = "format_notify"
        case formatWrite = "format_write"
    }
}

extension BleCharacteristic: Hashable {
    public var hashValue: String { return self.uuid }
    
    public static func == (lhs: BleCharacteristic, rhs: BleCharacteristic) -> Bool {
        return false
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid)
    }
}

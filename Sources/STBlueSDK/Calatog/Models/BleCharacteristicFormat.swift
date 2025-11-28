//
//  BleCharacteristicFormat.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct BleCharacteristicFormat {
    public let length: Int?
    public let name: String
    public let optional: Bool?
    public let unit: String?
    public let min: Float?
    public let max: Float?
    public let offset: Float?
    public let scaleFactor: Float?
    public let type: BleCharacteristicType?
    public let stringValues: [BleCharacteristicStringValue]?
}


public enum BleCharacteristicType: String, Codable {
    case Float
    case Int64
    case UInt32
    case Int32
    case UInt16
    case Int16
    case UInt8
    case Int8
    case ByteArray
    case RawData
    case Unit16 // TODO: Remove this
}

extension BleCharacteristicFormat: Codable {
    enum CodingKeys: String, CodingKey {
        case length
        case name
        case optional
        case unit
        case min
        case max
        case offset
        case scaleFactor = "scalefactor"
        case type
        case stringValues = "string_values"
    }
}

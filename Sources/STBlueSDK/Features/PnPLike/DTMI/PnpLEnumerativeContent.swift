//
//  PnpLPrimitiveContent.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PnpLEnumerativeContent: Codable {
    public let id: String?
    public var type: String = "enum"
    public let values: [PnpLEnumerativeValue]
    public let valueSchema: PnpLContentSchema

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case values = "enumValues"
        case valueSchema
    }
}

public struct PnpLEnumerativeValue: Codable {
    public let id: String?
    public let displayName: DisplayName?
    public let enumValue: EnumResponseValueType
    public let name: String

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case displayName
        case enumValue
        case name
    }
}

extension PnpLEnumerativeValue: CustomStringConvertible {
    public var description: String {
        displayName?.en ?? ""
    }
}

// MARK: - EnumResponseValueType
public enum EnumResponseValueType: Codable {
    case integer(Int)
    case string(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(Int.self) {
            self = .integer(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(EnumResponseValueType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for EnumResponseValueType"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .integer(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

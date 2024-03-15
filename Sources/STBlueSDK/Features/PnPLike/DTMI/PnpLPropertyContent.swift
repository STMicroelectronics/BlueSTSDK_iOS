//
//  PnpLPropertyContent.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PnpLPropertyContent: Codable {
    public let id: String
    public var type: PnpLPropertyContentType
    public let displayName: DisplayName?
    public let name: String
    public var schema: PnpLContent
    public let writable: Bool
    public let unit: String?

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case displayName
        case name
        case schema
        case writable
        case unit
    }
}

public enum PnpLPropertyContentType: Codable {
    case string(String)
    case stringArray([String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([String].self) {
            self = .stringArray(x)
            return
        }
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        throw DecodingError.typeMismatch(PnpLPropertyContentType.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for PnpLPropertyContentType"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .string(let x):
            try container.encode(x)
        case .stringArray(let x):
            try container.encode(x)
        }
    }
}

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

public struct PnpLPrimitiveContent: Codable {
    public let id: String?
    public let displayName: DisplayName?
    public let name: String
    public let schema: PnpLContentSchema
    public var writable: Bool?
    public var type: [String]?

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(self.id, forKey: .id)
        try container.encodeIfPresent(self.schema.encodeValue, forKey: .type)
        try container.encodeIfPresent(self.displayName, forKey: .displayName)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.schema, forKey: .schema)
        try container.encodeIfPresent(self.writable, forKey: .writable)
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.id = try container.decodeIfPresent(String.self, forKey: .id)
        self.type = try? container.decodeIfPresent([String].self, forKey: .type)
        self.displayName = try container.decodeIfPresent(DisplayName.self, forKey: .displayName)
        self.name = try container.decode(String.self, forKey: .name)
        self.schema = try container.decode(PnpLContentSchema.self, forKey: .schema)
        self.writable = try container.decodeIfPresent(Bool.self, forKey: .writable)
    }

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case displayName
        case name
        case schema
        case writable
    }
}

public enum PnpLContentSchema: String, Codable {
    case string = "string"
    case integer = "integer"
    case double = "double"
    case boolean = "boolean"
    case vector = "vector"

    var encodeValue: [String] {

        switch self {
        case .string:
            return ["property", "stringvalue"]
        case .integer, .double:
            return ["property", "numbervalue"]
        case .boolean:
            return ["property", "booleanvalue"]
        case .vector:
            return ["property", "vector"]
        }
    }
}

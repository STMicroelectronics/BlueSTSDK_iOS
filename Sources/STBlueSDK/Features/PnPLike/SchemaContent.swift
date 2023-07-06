//
//  SchemaContent.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct SchemaObject: Codable {
    public let id: String?
    public let type: String
    public let displayName: DisplayName?
    public let enumValues: [EnumResponseValue]?
    public let valueSchema: String?
    public let fields: [EnumResponseValue]?
    public let writable: Bool?

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case displayName, enumValues, valueSchema, fields, writable
    }
}

public enum SchemaContent: Codable {
    case schemaObject(SchemaObject)
    case string(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }

        if let x = try? container.decode(SchemaObject.self) {
            self = .schemaObject(x)
            return
        }

        throw DecodingError.typeMismatch(SchemaContent.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Wrong type for ContentSchema"))
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .schemaObject(let x):
            try container.encode(x)
        case .string(let x):
            try container.encode(x)
        }
    }
}

public extension SchemaContent {
    var url: String? {
        switch self {
        case .string(let url):
            return url
        default:
            return nil
        }
    }

    /// Extract DTMI Object Schema
    var object: SchemaObject? {
        switch self {
        case .schemaObject(let obj):
            return obj
        default:
            return nil
        }
    }

    /// Extract DTMI Schema String (integer, double, boolean, etc ...)
    var string: String? {
        switch self {
        case .string(let str):
            return str
        default:
            return nil
        }
    }

    var enumResponseValues: [EnumResponseValue]? {
        switch self {
        case .schemaObject(let schemaObject):
            return schemaObject.fields
        default:
            return nil
        }
    }
}

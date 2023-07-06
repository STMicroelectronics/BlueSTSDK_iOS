//
//  ContentType.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum ContentType: Codable {
    case string(String)
    case stringArray([String])

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }
        if let x = try? container.decode([String].self) {
            self = .stringArray(x)
            return
        }
        throw DecodingError.typeMismatch(ContentType.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Wrong type for TypeContent"))
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

public extension ContentType {
    var stringArray: [String]? {
        switch self {
        case .stringArray(let arr):
            return arr

        default:
            return nil
        }

    }

    /// Extract DTMI String Type
    var string: String? {
        switch self {
        case .string(let str):
            return str

        default:
            return nil
        }
    }
}

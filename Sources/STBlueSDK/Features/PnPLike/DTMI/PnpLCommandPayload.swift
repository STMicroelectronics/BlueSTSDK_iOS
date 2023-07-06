//
//  PnpLCommandPayload.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum PnpLCommandPayload: Codable {

    case object(PnpLContent)
    case string(String)

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()

        if let x = try? container.decode(String.self) {
            self = .string(x)
            return
        }

        if let x = try? container.decode(PnpLContent.self) {
            self = .object(x)
            return
        }

        throw DecodingError.typeMismatch(PnpLCommandPayload.self,
                                         DecodingError.Context(codingPath: decoder.codingPath,
                                                               debugDescription: "Wrong type for ContentSchema"))
    }

    public func encode(to encoder: Encoder) throws {
        var singleContainer = encoder.singleValueContainer()

        switch self {
        case .object(let pnpLContent):
            try singleContainer.encode(pnpLContent)
        case .string(let string):
            try singleContainer.encode(string)
        }
    }
}

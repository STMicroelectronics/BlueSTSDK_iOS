//
//  PnpLCommandPayloadContent.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PnpLCommandPayloadContent: Codable {
    public let id: String?
    public var type: String = "commandpayload"
    public let displayName: DisplayName?
    public let name: String
    public let schema: PnpLCommandPayload

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case displayName
        case name
        case schema
    }
}

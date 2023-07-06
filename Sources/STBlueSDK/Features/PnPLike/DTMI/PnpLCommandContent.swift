//
//  PnpLCommandContent.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PnpLCommandContent: Codable {
    public let id: String
    public var type: String = "command"
    public let commandType: String
    public let displayName: DisplayName?
    public let name: String
    public let request: PnpLCommandPayloadContent?
    public let response: PnpLCommandPayloadContent?

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case commandType
        case displayName
        case name
        case request
        case response
    }
}

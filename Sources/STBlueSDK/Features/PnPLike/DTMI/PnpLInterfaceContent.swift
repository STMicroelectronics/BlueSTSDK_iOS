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

public struct PnpLInterfaceContent: Codable {
    public let id: String
    public var type: String = "interface"
    public let name: String?
    public let context: [String]
    public let displayName: DisplayName?
    public var contents: [PnpLContent]

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case name
        case context = "@context"
        case contents
        case displayName
    }
}

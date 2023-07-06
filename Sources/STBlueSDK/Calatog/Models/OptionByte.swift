//
//  OptionByte.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct OptionByte {
    public let format: String?
    public let name: String?
    public let negativeOffset: Int?
    public let scaleFactor: Int?
    public let type: String?
    public let escapeMessage: String?
    public let escapeValue: Int?
    public let stringValues: [StringValue]?
    public let iconValues: [IconValue]?
}

extension OptionByte: Codable {
    enum CodingKeys: String, CodingKey {
        case format
        case name
        case negativeOffset = "negative_offset"
        case scaleFactor = "scale_factor"
        case type
        case escapeMessage = "escape_message"
        case escapeValue = "escape_value"
        case stringValues = "string_values"
        case iconValues = "icon_values"
    }
}

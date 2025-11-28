//
//  RawCustomEntry.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct RawCustomEntry: Codable {
    public let name: String
    public let type: RawPnPLFormat
    public let elements: Int = 1
    
    public enum CodingKeys: String, CodingKey {
        case name
        case type
        case elements = "size"
    }

    
}

public enum RawPnPLFormat: String, Codable {
    case uint8_t
    case int8_t
    case uint16_t
    case int16_t
    case uint32_t
    case int32_t
    case float
    case float_t
    case char
    case enumerative = "enum"
}

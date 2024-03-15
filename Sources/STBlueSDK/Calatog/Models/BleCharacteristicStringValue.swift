//
//  BleCharacteristicStringValue.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct BleCharacteristicStringValue {
    public let displayName: String
    public let value: Int
}

extension BleCharacteristicStringValue: Codable {
    enum CodingKeys: String, CodingKey {
        case displayName = "display_name"
        case value
    }
}

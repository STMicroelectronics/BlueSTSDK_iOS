//
//  Checksum.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct Checksum: Codable {
    public let checksum: String
    public let date: String
    public let version: String

    enum CodingKeys: String, CodingKey {
        case checksum = "checksum"
        case date = "date"
        case version = "version"
    }
}

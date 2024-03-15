//
//  DemoDecorator.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct DemoDecorator {
    public let add: [String]
    public let remove: [String]
    public let rename: [DemoRename]
}

extension DemoDecorator: Codable {
    enum CodingKeys: String, CodingKey {
        case add
        case remove
        case rename
    }
}

public struct DemoRename {
    public let old: String
    public let new: String
}

extension DemoRename: Codable {
    enum CodingKeys: String, CodingKey {
        case old
        case new
    }
}

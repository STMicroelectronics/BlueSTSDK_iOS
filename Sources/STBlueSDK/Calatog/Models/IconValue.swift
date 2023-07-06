//
//  IconValue.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct IconValue {
    public let comment: String?
    public let value: Int?
    public let code: Int?
}

extension IconValue: Codable {
    enum CodingKeys: String, CodingKey {
        case comment
        case value
        case code = "icon_code"
    }
}

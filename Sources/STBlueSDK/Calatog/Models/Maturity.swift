//
//  Maturity.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum Maturity: String, Codable, CustomStringConvertible {
    case draft
    case beta
    case release
    case demo
    case custom
    case special
    
    public var description: String {
        switch self {
        case .draft:
            return "DRAFT FW"
        case .beta:
            return "BETA FW"
        case .release:
            return "RELEASE FW"
        case .demo:
            return "DEMO FW"
        case .custom:
            return "CUSTOM FW"
        case .special:
            return "SPECIAL FW"
        }
    }
}

//
//  RawCustom.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct RawCustom: Codable {
    public let output: [RawCustomEntry]
    
    public enum CodingKeys: CodingKey {
        case output
    }
}

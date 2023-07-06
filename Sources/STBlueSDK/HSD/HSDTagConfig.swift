//
//  HSDTagConfig.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class HSDTagConfigContainer: Codable {
    public let tagConfig: HSDTagConfig
}

public class HSDTagConfig: Codable {
    public let maxTagsPerAcq: Int
    public let swTags: [HSDTag]
    public let hwTags: [HSDTag]
    
    public func updateTypes() {
        swTags.forEach { $0.type = .software }
        hwTags.forEach { $0.type = .hardware }
    }
}

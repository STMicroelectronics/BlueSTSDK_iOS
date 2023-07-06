//
//  CloudApp.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct CloudApp {
    public let description: String?
    public let dtmi: String?
    public let name: String?
    public let shareableLink: String?
    public let url: String?
}

extension CloudApp: Codable {
    enum CodingKeys: String, CodingKey {
        case description
        case dtmi
        case name
        case shareableLink = "shareable_link"
        case url
    }
}

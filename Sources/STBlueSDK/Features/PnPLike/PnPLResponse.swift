//
//  PnPLResponse.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PnPLResponse: Codable {
    public let schemaVersion: String
    public let devices: [PnPLDataModelDevice]

    public enum CodingKeys: String, CodingKey {
        case schemaVersion = "schema_version"
        case devices
    }
}

// MARK: - PnPLDataModelDevice
public struct PnPLDataModelDevice: Codable {
    public let components: JSONValue

    public enum CodingKeys: String, CodingKey {
        case components
    }
}

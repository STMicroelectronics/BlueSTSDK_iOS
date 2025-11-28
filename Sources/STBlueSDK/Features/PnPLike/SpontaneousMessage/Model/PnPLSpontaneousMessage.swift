//
//  PnPLSpontaneousMessage.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum PnPLSpontaneousMessage: Codable {
    case error(String)
    case warning(String)
    case info(String)
    case ok(String)

    private enum CodingKeys: String, CodingKey {
        case error = "PnPL_Error"
        case warning = "PnPL_Warning"
        case info = "PnPL_Info"
        case ok = "PnPL_Ok"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        if let value = try? container.decode(String.self, forKey: .error) {
            self = .error(value)
        } else if let value = try? container.decode(String.self, forKey: .warning) {
            self = .warning(value)
        } else if let value = try? container.decode(String.self, forKey: .info) {
            self = .info(value)
        } else if let value = try? container.decode(String.self, forKey: .ok) {
            self = .ok(value)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .error, in: container, debugDescription: "No matching keys found")
        }
    }
}

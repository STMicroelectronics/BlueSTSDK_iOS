//
//  StandardJsonCommand.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct StandardJsonCommand<T: Encodable>: JsonCommand {
    let value: T?

    public init(value: T?) {
        self.value = value
    }

    public var jsonData: Data? {
        try? JSONEncoder().encode(value)
    }
    public var json: String? {
        if let data = jsonData,
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return nil
    }
}

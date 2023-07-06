//
//  HSDCmd.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class AnyEncodable: Encodable {
    let value: Encodable
    public init(_ value: Encodable) {
        self.value = value
    }

    public func encode(to encoder: Encoder) throws {
        try value.encode(to: encoder)
    }
}

typealias EncodableDictionary = [String: AnyEncodable]

public class HSDCmd: Encodable {
    public static let StartLogging = HSDControlCmd(command: "START")
    public static let StopLogging = HSDControlCmd(command: "STOP")
    public static let Save = HSDControlCmd(command: "SAVE")
    
    let command: String
    var serialized: EncodableDictionary {
        ["command": AnyEncodable(command)]
    }
    public var jsonData: Data? {
        try? JSONEncoder().encode(serialized)
    }
    public var json: String? {
        if let data = jsonData,
           let json = String(data: data, encoding: .utf8) {
            return json
        }
        return nil
    }
    
    public init(command: String) {
        self.command = command
    }
}

public class HSDControlCmd: HSDCmd {}

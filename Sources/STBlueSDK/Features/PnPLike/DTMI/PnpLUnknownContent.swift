//
//  PnpLUnknownContent.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PnpLUnknownContent {
    let value: Any
}

extension PnpLUnknownContent: Codable {

    public init(from decoder: Decoder) throws {
        if let keyedContainer = try? decoder.container(keyedBy: Key.self) {
            var dictionary = [String: Any]()
            for key in keyedContainer.allKeys {
                if let value = try? keyedContainer.decode(Bool.self, forKey: key) {
                    // Wrapping numeric and boolean types in `NSNumber` is important, so `as? Int64` or `as? Float` casts will work
                    dictionary[key.stringValue] = NSNumber(value: value)
                } else if let value = try? keyedContainer.decode(Int64.self, forKey: key) {
                    dictionary[key.stringValue] = NSNumber(value: value)
                } else if let value = try? keyedContainer.decode(Double.self, forKey: key) {
                    dictionary[key.stringValue] = NSNumber(value: value)
                } else if let value = try? keyedContainer.decode(String.self, forKey: key) {
                    dictionary[key.stringValue] = value
                } else if (try? keyedContainer.decodeNil(forKey: key)) ?? false {
                    // NOP
                } else if let value = try? keyedContainer.decode(PnpLUnknownContent.self, forKey: key) {
                    dictionary[key.stringValue] = value.value
                } else {
                    throw DecodingError.dataCorruptedError(forKey: key, in: keyedContainer, debugDescription: "Unexpected value for \(key.stringValue) key")
                }
            }
            value = dictionary
        } else if var unkeyedContainer = try? decoder.unkeyedContainer() {
            var array = [Any]()
            while !unkeyedContainer.isAtEnd {
                let container = try unkeyedContainer.decode(PnpLUnknownContent.self)
                array.append(container.value)
            }
            value = array
        } else if let singleValueContainer = try? decoder.singleValueContainer() {
            if let value = try? singleValueContainer.decode(Bool.self) {
                self.value = NSNumber(value: value)
            } else if let value = try? singleValueContainer.decode(Int64.self) {
                self.value = NSNumber(value: value)
            } else if let value = try? singleValueContainer.decode(Double.self) {
                self.value = NSNumber(value: value)
            } else if let value = try? singleValueContainer.decode(String.self) {
                self.value = value
            } else if singleValueContainer.decodeNil() {
                value = NSNull()
            } else {
                throw DecodingError.dataCorruptedError(in: singleValueContainer, debugDescription: "Unexpected value")
            }
        } else {
            let context = DecodingError.Context(codingPath: [], debugDescription: "Invalid data format for JSON")
            throw DecodingError.dataCorrupted(context)
        }
    }

    public func encode(to encoder: Encoder) throws {
        if let array = value as? [Any] {
            var container = encoder.unkeyedContainer()
            for value in array {
                let decodable = PnpLUnknownContent(value: value)
                try container.encode(decodable)
            }
        } else if let dictionary = value as? [String: Any] {
            var container = encoder.container(keyedBy: Key.self)
            for (key, value) in dictionary {
                let codingKey = Key(stringValue: key)!
                let decodable = PnpLUnknownContent(value: value)
                try container.encode(decodable, forKey: codingKey)
            }
        } else {
            var container = encoder.singleValueContainer()
            if let intVal = value as? Int {
                try container.encode(intVal)
            } else if let doubleVal = value as? Double {
                try container.encode(doubleVal)
            } else if let boolVal = value as? Bool {
                try container.encode(boolVal)
            } else if let stringVal = value as? String {
                try container.encode(stringVal)
            } else {
                throw EncodingError.invalidValue(value, EncodingError.Context.init(codingPath: [], debugDescription: "The value is not encodable"))
            }

        }
    }

    private struct Key: CodingKey {
        var stringValue: String

        init?(stringValue: String) {
            self.stringValue = stringValue
        }

        var intValue: Int?

        init?(intValue: Int) {
            self.init(stringValue: "\(intValue)")
            self.intValue = intValue
        }
    }
}

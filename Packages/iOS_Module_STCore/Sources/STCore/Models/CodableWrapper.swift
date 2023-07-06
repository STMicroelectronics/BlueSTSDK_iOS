//
//  CodableWrapper.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct CodableWrapper<T: NSObject & NSCoding> {
    public let value: T?

    public init(value: T?) {
        self.value = value
    }
}

extension CodableWrapper: Codable {
    enum CodingKeys: String, CodingKey {
        case data
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        let data = try container.decode(Data.self, forKey: .data)
        value = try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: data)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        let data = try NSKeyedArchiver.archivedData(withRootObject: value as Any, requiringSecureCoding: false)
        try container.encode(data, forKey: .data)
    }
}

public extension Data {
    static func data<T: NSObject & NSCoding>(from object: T?) throws -> Data {
        try NSKeyedArchiver.archivedData(withRootObject: object as Any, requiringSecureCoding: false)
    }

    func object<T: NSObject & NSCoding>() throws -> T? {
        try NSKeyedUnarchiver.unarchivedObject(ofClass: T.self, from: self)
    }
}

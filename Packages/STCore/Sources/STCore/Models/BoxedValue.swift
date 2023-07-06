//
//  BoxedValue.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum BoxedValue {
    case string(String)
    case int(Int)
    case double(Double)
    case boolean(Bool)
    case object(CustomStringConvertible & Encodable)
}

public extension BoxedValue {
    var unwrappedValue: Encodable {
        switch self {
        case .string(let value):
            return value
        case .int(let value):
            return value
        case .double(let value):
            return value
        case .boolean(let value):
            return value
        case .object(let value):
            return value
        }
    }
}

public extension String {
    var boxedValue: BoxedValue {
        .string(self)
    }
}

public extension Int {
    var boxedValue: BoxedValue {
        .int(self)
    }
}

public extension Double {
    var boxedValue: BoxedValue {
        .double(self)
    }
}

public extension Bool {
    var boxedValue: BoxedValue {
        .boolean(self)
    }
}


extension BoxedValue: CustomStringConvertible {
    public var description: String {
        switch self {
        case .string(let value):
            return "\(value)"
        case .int(let value):
            return "\(value)"
        case .double(let value):
            return "\(value)"
        case .boolean(let value):
            return "\(value)"
        case .object(let value):
            return "\(value)"
        }
    }
}

//
//  BlueSTCodeValue.swift
//
//  Copyright (c) 2026 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol BlueSTKeyValue: Hashable, Equatable {
    associatedtype BlueSTValue

    var keys: [String] { get set }
    var value: BlueSTValue { get set }
}

public class BlueSTCodeValue<BlueSTValue>: BlueSTKeyValue {
    public var keys: [String]
    public var value: BlueSTValue

    public init(keys: [String], value: BlueSTValue) {
        self.keys = keys
        self.value = value
    }

    public init(value: BlueSTValue) {
        self.keys = [ UUID().uuidString ]
        self.value = value
    }
}

extension BlueSTCodeValue: Hashable {
    public func hash(into hasher: inout Hasher) {
        for key in keys {
            hasher.combine(key)
        }
    }
}

extension BlueSTCodeValue: Equatable {
    public static func == (lhs: BlueSTCodeValue<BlueSTValue>, rhs: BlueSTCodeValue<BlueSTValue>) -> Bool {
        lhs.keys == rhs.keys
    }
}

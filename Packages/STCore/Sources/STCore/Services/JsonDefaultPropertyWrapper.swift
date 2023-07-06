//
//  JsonDefaultPropertyWrapper.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

@propertyWrapper
public struct JsonUserDefault<Value: Codable> {
    let key: String
    let defaultValue: Value?
    var container: UserDefaults = .standard

    public var wrappedValue: Value? {
        get {
            let decoder = JSONDecoder()
            guard let data = container.data(forKey: key),
                  let decodedValue = try? decoder.decode(Value.self, from: data) else { return defaultValue }
            return decodedValue
        }
        set {

            guard let value = newValue else {
                container.removeObject(forKey: key)
                return
            }

            let encoder = JSONEncoder()
            container.set(try? encoder.encode(value), forKey: key)
        }
    }
}

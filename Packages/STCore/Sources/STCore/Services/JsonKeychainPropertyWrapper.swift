//
//  JsonKeychainPropertyWrapper.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import KeychainAccess

@propertyWrapper
public struct JsonKeychain<Value: Codable> {
    let key: String
    let defaultValue: Value?
    let keychain: Keychain = Keychain(service: "com.st").accessibility(.afterFirstUnlock)

    public var wrappedValue: Value? {
        get {
            do {
                guard let data = try keychain.getData(key) else {
                    Logger.debug(text: "Keychain: no state to restore.")
                    return nil
                }

                guard let decodedValue = try? JSONDecoder().decode(Value.self, from: data) else {
                    Logger.debug(text: "Keychain: error decoding data.")
                    return nil
                }

                return decodedValue

            } catch {
                Logger.debug(text: "Keychain: loading error - \(error.localizedDescription)")
                return nil
            }
        }
        set {
            guard let value = newValue else {
                do {
                    try keychain.remove(key)
                } catch {
                    Logger.debug(text: "Keychain: saving error - \(error.localizedDescription)")
                }

                return
            }

            do {
                let data = try JSONEncoder().encode(value)
                try keychain.set(data, key: key)
            } catch {
                Logger.debug(text: "Keychain: saving error - \(error.localizedDescription)")
            }
        }
    }
}

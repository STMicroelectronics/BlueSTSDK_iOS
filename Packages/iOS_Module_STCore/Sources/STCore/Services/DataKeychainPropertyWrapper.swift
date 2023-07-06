//
//  DataKeychainPropertyWrapper.swift
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
public struct DataKeychain {
    let key: String
    let defaultValue: Data?
    var keychain: Keychain

    public init(key: String,
                defaultValue: Data?,
                keychain: Keychain = Keychain(service: "com.st").accessibility(.afterFirstUnlock)) {
        self.key = key
        self.defaultValue = defaultValue
        self.keychain = keychain
    }

    public var wrappedValue: Data? {
        get {
            do {
                guard let data = try keychain.getData(key) else {
                    Logger.debug(text: "Keychain: no state to restore.")
                    return nil
                }

                return data

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
                try keychain.set(value, key: key)
            } catch {
                Logger.debug(text: "Keychain: saving error - \(error.localizedDescription)")
            }
        }
    }
}

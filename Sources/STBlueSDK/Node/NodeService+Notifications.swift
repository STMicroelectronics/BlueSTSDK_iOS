//
//  NodeService+Notifications.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth

internal extension NodeService {
    @discardableResult
    func enableNotifications(for feature: Feature) -> Bool {
        
        objc_sync_enter(self)
        defer { objc_sync_exit(self) }
        
        if !feature.isEnabled || !node.isConnected {
            return false
        }

        guard let blueChar = node.characteristics.characteristic(with: feature) else { return false }

        if !blueChar.characteristic.isCharacteristicCanBeNotify {
            return false
        }

        if blueChar.characteristic.isNotifying {
            return true
        }

        var feature = feature
        feature.isNotificationsEnabled = true

        bleService.enableNotifications(for: blueChar.characteristic)

        return true
    }

    @discardableResult
    func disableNotifications(for feature: Feature) -> Bool {

        if !feature.isEnabled || !node.isConnected {
            return false
        }

        if !feature.isNotificationsEnabled {
            return true
        }

        guard let blueChar = node.characteristics.characteristic(with: feature) else { return false }

        let otherEnabledFeatureCount = blueChar.features.filter({ $0.isNotificationsEnabled && ($0.name != feature.name) }).count

        var feature = feature
        feature.isNotificationsEnabled = false

        if otherEnabledFeatureCount > 0 {
            return true
        } else {
            bleService.disableNotifications(for: blueChar.characteristic)
        }

        return true
    }

    @discardableResult
    func enableNotifications(for characteristic: CBCharacteristic) -> Bool {
        if !node.isConnected {
            return false
        }

        if !characteristic.isCharacteristicCanBeNotify {
            return false
        }

        if characteristic.isNotifying {
            return true
        }

        bleService.enableNotifications(for: characteristic)

        return true
    }

    @discardableResult
    func disableNotifications(for characteristic: CBCharacteristic) -> Bool {

        if !node.isConnected {
            return false
        }

        if !characteristic.isCharacteristicCanBeNotify {
            return true
        }

        bleService.disableNotifications(for: characteristic)

        return true
    }
}

//
//  BlueManager+Notifications.swift
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

public extension BlueManager {
    func enableNotifications(for node: Node, feature: Feature) {
        if let nodeService = nodeServices.nodeService(with: node) {
            nodeService.enableNotifications(for: feature)
        }
    }

    func disableNotifications(for node: Node, feature: Feature) {
        if let nodeService = nodeServices.nodeService(with: node) {
            nodeService.disableNotifications(for: feature)
        }
    }
    
    func enableNotifications(for node: Node, features: [Feature]) {
        for feature in features {
            enableNotifications(for: node, feature: feature)
        }
    }
    
    func disableNotifications(for node: Node, features: [Feature]) {
        for feature in features {
            disableNotifications(for: node, feature: feature)
        }
    }

    func enableNofitications(for node: Node, characteristic: CBCharacteristic) {
        if let nodeService = nodeServices.nodeService(with: node) {
            nodeService.enableNotifications(for: characteristic)
        }
    }

    func disableNotifications(for node: Node, characteristic: CBCharacteristic) {
        if let nodeService = nodeServices.nodeService(with: node) {
            nodeService.disableNotifications(for: characteristic)
        }
    }
}

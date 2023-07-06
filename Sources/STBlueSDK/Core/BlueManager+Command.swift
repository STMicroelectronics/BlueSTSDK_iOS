//
//  BlueManager+Command.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension BlueManager {

    @discardableResult
    func sendCommand(_ command: FeatureCommand, to node: Node, feature: Feature) -> Bool {

        guard let nodeService = nodeServices.nodeService(with: node) else { return false }

        return nodeService.sendCommand(command, feature: feature)
    }

    @discardableResult
    func sendJsonCommand(_ command: JsonCommand,
                       to node: Node,
                       feature: Feature) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node) {
            return nodeService.sendCommand(command, feature: feature)
        }

        return false
    }
}

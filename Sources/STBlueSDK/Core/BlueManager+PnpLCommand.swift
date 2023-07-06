//
//  BlueManager+PnpLCommand.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

import Foundation

public extension BlueManager {

    @discardableResult
    func sendPnpLCommand(_ command: PnpLCommand, to node: Node) -> Bool {
        guard let nodeService = nodeServices.nodeService(with: node),
              let blueChar = node.characteristics.characteristic(with: PnPLFeature.self) else { return false }

        return nodeService.sendCommand(command, blueChar: blueChar)
    }

    @discardableResult
    func sendPnpLCommand(_ command: PnpLCommand, to node: Node, feature: Feature) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node) {
            return nodeService.sendCommand(command, feature: feature)
        }

        return false
    }
}

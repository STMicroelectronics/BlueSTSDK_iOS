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

public extension BlueManager {

    @discardableResult
    func sendPnpLCommand(_ command: PnpLCommand, to node: Node, progress: ((Int, Int) -> Void)? = nil, completion: (() -> Void)? = nil) -> Bool {
        return sendPnpLCommand(command, maxWriteLength: node.maxPnplMtu, to: node, progress:progress, completion: completion)
    }

    @discardableResult
    func sendPnpLCommand(_ command: PnpLCommand,  maxWriteLength: Int, to node: Node, progress: ((Int, Int) -> Void)? = nil, completion: (() -> Void)? = nil) -> Bool {
        guard let nodeService = nodeServices.nodeService(with: node),
              let blueChar = node.characteristics.characteristic(with: PnPLFeature.self) else { return false }

        return nodeService.sendCommand(command,  maxWriteLength:  maxWriteLength, blueChar: blueChar, progress: progress, completion: completion)
    }

    @discardableResult
    func sendPnpLCommand(_ command: PnpLCommand,  maxWriteLength: Int, to node: Node, feature: Feature) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node) {
            return nodeService.sendCommand(command,  maxWriteLength:  maxWriteLength, feature: feature)
        }

        return false
    }
}

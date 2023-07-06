//
//  BlueManager+HSDCommand.swift
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
    func sendHSDGetCommand(_ command: HSDGetCmd, to node: Node)  -> Bool {
        return sendHSDCommand(command.json, to: node) {}
    }
    
    func sendHSDSetCommand(_ command: HSDSetCmd, to node: Node, completion: @escaping () -> Void)  -> Bool {
        return sendHSDCommand(command.json, to: node, completion: completion)
    }
    
    func sendHSDControlCommand(_ command: HSDControlCmd, to node: Node)  -> Bool {
        return sendHSDCommand(command.json, to: node) {}
    }
    
    func sendHSDCommand(_ command: String?, to node: Node, completion: @escaping () -> Void)  -> Bool {
        
        guard let nodeService = nodeServices.nodeService(with: node),
        let blueChar = node.characteristics.characteristic(with: HSDFeature.self),
        let command = command else {
            completion()
            return false
        }
        
        return nodeService.sendJSONCommand(command, characteristic: blueChar.characteristic, mtu: blueChar.maxMtu, completion)
    }
}

//
//  BlueManager+ECCommand.swift
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
    @discardableResult
    func sendECCommand(_ type: ECCommandType,
                       to node: Node,
                       feature: Feature) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node) {
            let command = ECCommand<String>(type: type)
            return nodeService.sendCommand(command, feature: feature)
        }
        
        return false
    }

    @discardableResult
    func sendECCommand(_ type: ECCommandType,
                       to node: Node) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node),
           let blueChar = node.characteristics.characteristic(with: ExtendedConfigurationFeature.self){
            let command = ECCommand<String>(type: type)
            return nodeService.sendCommand(command, blueChar: blueChar)
        }

        return false
    }
    
    @discardableResult
    func sendECCommand(_ type: ECCommandType,
                       int: Int,
                       to node: Node) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node),
           let blueChar = node.characteristics.characteristic(with: ExtendedConfigurationFeature.self) {
            let command = ECCommand<String>(type: type, argNumber: int)
            return nodeService.sendCommand(command, blueChar: blueChar)
        }
        
        return false
    }

    @discardableResult
    func sendECCommand(_ type: ECCommandType,
                       string: String,
                       to node: Node) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node),
           let blueChar = node.characteristics.characteristic(with: ExtendedConfigurationFeature.self) {
            let command = ECCommand<String>(type: type, argString: string)
            return nodeService.sendCommand(command, blueChar: blueChar)
        }

        return false
    }
    
    @discardableResult
    func sendECCommand<T: Encodable>(_ type: ECCommandType,
                                     json: T,
                                     to node: Node) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node),
           let blueChar = node.characteristics.characteristic(with: ExtendedConfigurationFeature.self) {
            let command = ECCommand(type: type, argJSON: json)
            return nodeService.sendCommand(command, blueChar: blueChar)
        }
        
        return false
    }
    
    @discardableResult
    func sendECCommand(_ commandName: String,
                       to node: Node) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node),
           let blueChar = node.characteristics.characteristic(with: ExtendedConfigurationFeature.self) {
            let command = ECCommand<String>(name: commandName)
            return nodeService.sendCommand(command, blueChar: blueChar)
        }
        
        return false
    }
    
    @discardableResult
    func sendECCommand(_ commandName: String,
                       string: String,
                       to node: Node) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node),
           let blueChar = node.characteristics.characteristic(with: ExtendedConfigurationFeature.self) {
            let command = ECCommand<String>(name: commandName, argString: string)
            return nodeService.sendCommand(command, blueChar: blueChar)
        }
        
        return false
    }
    
    @discardableResult
    func sendECCommand(_ commandName: String,
                       int: Int,
                       to node: Node) -> Bool {
        if let nodeService = nodeServices.nodeService(with: node),
           let blueChar = node.characteristics.characteristic(with: ExtendedConfigurationFeature.self) {
            let command = ECCommand<Int>(name: commandName, argNumber: int)
            return nodeService.sendCommand(command, blueChar: blueChar)
        }
        
        return false
    }
}

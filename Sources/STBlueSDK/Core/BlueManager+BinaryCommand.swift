//
//  BlueManager+BinaryCommand.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth

public extension BlueManager {
    
    func sendBinaryCommand(_ data: Data?, to node: Node, feature: Feature, writeSize: Int=20, progress: @escaping (Int, Int) -> Void,completion: @escaping () -> Void)  -> Bool {
        
        guard let nodeService = nodeServices.nodeService(with: node),
              let blueChar = node.characteristics.characteristic(with: feature),
              let payload = data else {
            completion()
            return false
        }
        
        if writeSize > blueChar.maxMtu {
            completion()
            return false
        }
        
        return nodeService.sendBinaryContent(payload, characteristic: blueChar.characteristic, writeSize: blueChar.maxMtu, progress: { index, parts in
            progress(index,parts)
        }, completion: completion)
    }
}

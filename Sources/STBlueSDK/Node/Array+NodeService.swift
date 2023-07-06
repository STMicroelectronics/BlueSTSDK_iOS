//
//  Array+NodeService.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension Array where Element: NodeService {
    func nodeService(with node: Node) -> NodeService? {
        return first { $0.node.address == node.address }
    }

    mutating func remove(with node: Node) {
        removeAll(where: { $0 === node })
    }
}

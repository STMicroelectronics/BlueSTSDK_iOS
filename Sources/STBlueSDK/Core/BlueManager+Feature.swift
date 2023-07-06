//
//  BlueManager+Feature.swift
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
    func read(feature: Feature, for node: Node, delegate: BlueDelegate) {
        if let nodeService = nodeServices.nodeService(with: node) {
            
            addDelegate(delegate)
            
            if !nodeService.readFeature(feature) {
                delegate.manager(self, didUpdateValueFor: node, feature: feature, sample: feature.lastSample)
            }
        }
    }
    
    func write(value: Data, for feature: Feature, to node: Node, delegate: BlueDelegate) {
        if let nodeService = nodeServices.nodeService(with: node) {
            nodeService.write(value: value, for: feature)
        }
    }
}

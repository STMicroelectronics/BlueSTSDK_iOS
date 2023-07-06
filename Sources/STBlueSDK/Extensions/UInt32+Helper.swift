//
//  Int32+Helper.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal extension UInt32 {
    
    func features(for node: Node) -> [Feature] {
        var features: [Feature] = [Feature]()
        var mask: UInt32 = 1 << 31

        for _ in 1..<32 {
            if self & mask != 0,
               var feature = FeatureType.feature(from: mask,
                                                 types: FeatureType.nodeFeatureTypes(node.type)) {

                feature.isEnabled = false

                features.append(feature)
            }

            mask = mask >> 1
        }
        
        return features
    }
    
}

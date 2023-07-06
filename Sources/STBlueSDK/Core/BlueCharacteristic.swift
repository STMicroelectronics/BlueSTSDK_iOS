//
//  BlueCharacteristic.swift
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

public class BlueCharacteristic {
    let characteristic: CBCharacteristic
    let maxMtu: Int
    let features: [Feature]

    init(characteristic: CBCharacteristic, features: [Feature], maxMtu: Int) {
        self.characteristic = characteristic
        self.features = features
        self.maxMtu = maxMtu
    }
}

public extension BlueCharacteristic {
    func parse(_ data: Data, timestamp: UInt64, completion: @escaping (Feature, AnyFeatureSample?) -> Void) {
        var offset = 2
        
        for feature in features {
            let newOffset = feature.update(with: timestamp,
                                           data: data,
                                           offset: offset,
                                           mtu: maxMtu)
            
            offset += newOffset
            
            guard feature.hasData else {
                return
            }

            completion(feature, feature.lastSample)
        }
    }
}

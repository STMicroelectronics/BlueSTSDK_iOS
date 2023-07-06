//
//  BlueNRGAdvertiseInfo.swift
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

class BlueNRGAdvertiseInfo: BlueAdvertiseInfo {
    
    var services: [CBUUID] = []
    
    convenience init(name: String?,
                     address: String?,
                     featureMap: UInt32,
                     deviceId: UInt8,
                     protocolVersion: UInt8,
                     boardType: NodeType,
                     isSleeping: Bool,
                     hasGeneralPurpose: Bool,
                     txPower: UInt8,
                     services: [CBUUID]) {
        
        self.init(name: name,
                  address: address,
                  featureMap: featureMap,
                  deviceId: deviceId,
                  protocolVersion: protocolVersion,
                  boardType: boardType,
                  isSleeping: isSleeping,
                  hasGeneralPurpose: hasGeneralPurpose,
                  txPower: txPower)
        
        self.services = services
    }
    
}

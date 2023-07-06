//
//  BlueAdvertiseInfo.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class BlueAdvertiseInfo: AdvertiseInfo {

    public let name: String?
    public let address: String?
    public var featureMap: UInt32
    public let deviceId: UInt8
    public let protocolVersion: UInt8
    public let boardType: NodeType
    public let isSleeping: Bool
    public let hasGeneralPurpose: Bool
    public let txPower: UInt8
    public var bleFirmwareId: Int {
        let optionBytes = withUnsafeBytes(of: featureMap.bigEndian, Array.init)
        
        var bleFwId: Int = 0
        if optionBytes[0] == 0x00 {
            bleFwId = Int(optionBytes[1]) + 256
        } else if optionBytes[0] == 0xFF {
            bleFwId = 255
        } else {
            bleFwId = Int(optionBytes[0])
        }
        
        return bleFwId
    }

    var offsetForFirstOptByte: Int {
        let optionBytes = withUnsafeBytes(of: featureMap.bigEndian, Array.init)

        return optionBytes[0] == 0x00 ? 1 : 0
    }
    
    init(name: String?,
         address: String?,
         featureMap: UInt32,
         deviceId: UInt8,
         protocolVersion: UInt8,
         boardType: NodeType,
         isSleeping: Bool,
         hasGeneralPurpose: Bool,
         txPower: UInt8) {
        self.name = name
        self.address = address
        self.featureMap = featureMap
        self.deviceId = deviceId
        self.protocolVersion = protocolVersion
        self.boardType = boardType
        self.isSleeping = isSleeping
        self.hasGeneralPurpose = hasGeneralPurpose
        self.txPower = txPower
    }
}

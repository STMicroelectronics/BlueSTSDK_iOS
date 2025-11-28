//
//  LeBlueAdvertiseInfo.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class LeBlueAdvertiseInfo: LeAdvertiseInfo {
    
    public let name: String?
    public let address: String?
    public let deviceId: UInt8
    public let firmwareId: UInt8
    public var protocolId: UInt16
    public var payloadData: Data
    public let protocolVersion: UInt8
    public let type: NodeType
    
    init(name: String?,
         address: String?,
         deviceId: UInt8,
         firmwareId: UInt8,
         protocolId: UInt16,
         payloadData: Data,
         protocolVersion: UInt8,
         type: NodeType) {
        self.name = name
        self.address = address
        self.deviceId = deviceId
        self.firmwareId = firmwareId
        self.protocolId = protocolId
        self.payloadData = payloadData
        self.protocolVersion = protocolVersion
        self.type = type
    }
}

//
//  BleAdvertiseInfo.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

public protocol AdvertiseInfo {
    var name: String? { get }
    var address: String? { get }
    var featureMap: UInt32 { get set }
    var deviceId: UInt8 { get }
    var protocolVersion: UInt8 { get }
    var boardType: NodeType { get }
    var isSleeping: Bool { get }
    var hasGeneralPurpose: Bool { get }
    var txPower: UInt8 { get }
    var bleFirmwareId: Int { get }
    var offsetForFirstOptByte: Int { get }
}

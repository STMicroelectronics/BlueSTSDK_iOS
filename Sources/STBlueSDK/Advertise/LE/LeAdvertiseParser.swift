//
//  LeAdvertiseParser.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth

open class LeAdvertiseParser: LeAdvertiseFilter {
    
    private static let minProtocolVersionSupported: UInt8 = 0x03
    private static let maxProtocolVersionSupported: UInt8 = 0x03
    
    open func filter(_ data: [String: Any]) -> LeAdvertiseInfo? {

        let name = data[CBAdvertisementDataLocalNameKey] as? String
        
        guard let vendorData = data[CBAdvertisementDataManufacturerDataKey] as? Data else {
            return nil
        }
        
        let vendorDataCount = vendorData.count
        var offset = 0
        
        /// Min length:
        ///  - 2 for ST's Manufacture ID
        ///  - 1 for BlueST-SDK Version
        ///  - 1: for DeviceId
        ///  - 1: for FirmwareId
        ///  - 2: for ProtocolId
        ///  - 1: at least one byte used for payload
        if (vendorDataCount < 8) {
            return nil
        }
        
        if ((vendorData[0] != 0x30) && (vendorData[1] != 0x00)) {
            return nil
        } else {
            offset = 2
        }
        
        let protocolVersion = vendorData[offset]
        guard protocolVersion >= LeAdvertiseParser.minProtocolVersionSupported &&
                protocolVersion <= LeAdvertiseParser.maxProtocolVersionSupported else {
            return nil
        }
        
        let deviceId = vendorData[1 + offset].nodeId
        let deviceType = NodeTypeMapper.getNodeType(deviceId: deviceId, protocolVersion: 0x02)
        let firmwareId = vendorData[2 + offset]
        let protocolId = vendorData.extractUInt16(fromOffset: 3 + offset, endian: .big)

        let payload = vendorData.subdata(in: 5 + offset..<vendorData.endIndex)
               
        return LeBlueAdvertiseInfo(
            name: name,
            address: nil,
            deviceId: deviceId,
            firmwareId: firmwareId,
            protocolId: protocolId,
            payloadData: payload,
            protocolVersion: protocolVersion,
            type: deviceType)
    }

}

fileprivate extension UInt8 {
    private static let nucleoBitMask: UInt8 = 0x80
    private static let isSleepingBitMask: UInt8 = 0x70
    private static let hasGeneralPurposeBitMask: UInt8 = 0x80
    
    private var isNucleo: Bool {
        get {
            return (self & UInt8.nucleoBitMask) != 0
        }
    }
    
    var nodeId: UInt8 {
        get {
            //if ((self & UInt8(0x80)) != 0) {
                return self
            //}
        }
    }
}

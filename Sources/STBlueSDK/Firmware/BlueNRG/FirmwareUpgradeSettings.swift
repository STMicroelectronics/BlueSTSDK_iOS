//
//  FirmwareUpgradeSettings.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal struct FirmwareUpgradeSettings {
    
    internal static let defaultAckInterval: UInt8 = 8
    
    let file: URL
    let data: Data
    let ackInterval: UInt8
    let uploadSize: UInt32
    let baseAddress: UInt32
    let packageSize: UInt
    
    var parameterData: Data {
        var message = Data()

        withUnsafeBytes(of: ackInterval) { message.append(contentsOf: $0) }
        withUnsafeBytes(of: uploadSize.littleEndian) { message.append(contentsOf: $0) }
        withUnsafeBytes(of: baseAddress.littleEndian) { message.append(contentsOf: $0) }
        
//        message.append(ackInterval)
//        var imageSizeLe = uploadSize.littleEndian
//        message.append(UnsafeBufferPointer(start: &imageSizeLe, count: 1))
//        var baseAddressLe = baseAddress.littleEndian
//        message.append(UnsafeBufferPointer(start: &baseAddressLe, count: 1))
        
        return message
    }
}

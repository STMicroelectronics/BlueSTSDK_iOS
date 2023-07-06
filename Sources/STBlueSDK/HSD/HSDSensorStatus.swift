//
//  HSDSensorStatus.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class HSDSensorStatus: Codable {
    public var ODR: Double?
    public let ODRMeasured: Double?
    public let initialOffset: Double?
    public var FS: Double?
    public let sensitivity: Double?
    public var isActive: Bool
    public var samplesPerTs: Int
    public let usbDataPacketSize: Int
    public let sdWriteBufferSize: Int
    public let wifiDataPacketSize: Int
    public let comChannelNumber: Int
    public var ucfLoaded: Bool
}

extension HSDSensorStatus: Equatable {
    public static func == (lhs: HSDSensorStatus, rhs: HSDSensorStatus) -> Bool {
        lhs.ODR == rhs.ODR &&
        lhs.FS == rhs.FS &&
        lhs.isActive == rhs.isActive &&
        lhs.samplesPerTs == rhs.samplesPerTs &&
        
        lhs.ODRMeasured == rhs.ODRMeasured &&
        lhs.initialOffset == rhs.initialOffset &&
        lhs.sensitivity == rhs.sensitivity &&
        lhs.usbDataPacketSize == rhs.usbDataPacketSize &&
        lhs.sdWriteBufferSize == rhs.sdWriteBufferSize &&
        lhs.wifiDataPacketSize == rhs.wifiDataPacketSize &&
        lhs.comChannelNumber == rhs.comChannelNumber &&
        lhs.ucfLoaded == rhs.ucfLoaded
    }
}

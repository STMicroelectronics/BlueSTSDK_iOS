//
//  LeAdvertiseInfo.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol LeAdvertiseInfo {
    var name: String? { get }
    var address: String? { get }
    var deviceId: UInt8 { get }
    var firmwareId: UInt8 { get }
    var protocolId: UInt16 { get }
    var payloadData: Data { get set }
    var protocolVersion: UInt8 { get }
    var type: NodeType { get }
}

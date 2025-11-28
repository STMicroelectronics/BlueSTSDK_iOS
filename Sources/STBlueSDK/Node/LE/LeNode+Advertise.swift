//
//  LeNode+Advertise.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore

public extension LeNode {
    var name: String? {
        return advertiseInfo.name
    }

    var address: String? {
        return advertiseInfo.address
    }
    
    var deviceId: UInt8 {
        return advertiseInfo.deviceId
    }

    var firmwareId: UInt8 {
        return advertiseInfo.firmwareId
    }

    var protocolId: UInt16 {
        return advertiseInfo.protocolId
    }
    
    var payloadData: Data {
        get { currentPayloadData }
        set { currentPayloadData = newValue }
    }
    
    var protocolVersion: UInt8 {
        return advertiseInfo.protocolVersion
    }

    var type: NodeType {
        return advertiseInfo.type
    }
}


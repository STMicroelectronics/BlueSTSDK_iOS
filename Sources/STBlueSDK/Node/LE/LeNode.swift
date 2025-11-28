//
//  LeNode.swift
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
import STCore

public class LeNode {

    internal let advertiseInfo: LeAdvertiseInfo
    public var peripheral: CBPeripheral
    public var currentPayloadData: Data

    init(peripheral: CBPeripheral, advertiseInfo: LeAdvertiseInfo) {
        self.peripheral = peripheral
        self.advertiseInfo = advertiseInfo
        self.currentPayloadData = advertiseInfo.payloadData
    }

    deinit {
        STBlueSDK.log(text: "DEINIT LE NODE")
    }
}

extension LeNode: Equatable {
    public static func == (lhs: LeNode, rhs: LeNode) -> Bool {
        return lhs.address == rhs.address
    }
}


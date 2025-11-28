//
//  Node.swift
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
import STCore

public class Node {

    internal let advertiseInfo: AdvertiseInfo
    internal var internalPnpMaxMtu: Int?

    public var peripheral: CBPeripheral
    public var rssi: Int?
    public var state: NodeState = .disconnected
    public var characteristics: [BlueCharacteristic] = [BlueCharacteristic]()

    init(peripheral: CBPeripheral, rssi: Int, advertiseInfo: AdvertiseInfo) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertiseInfo = advertiseInfo
    }

    deinit {
        STBlueSDK.log(text: "DEINIT NODE")
    }
}

extension Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.address == rhs.address
    }
}

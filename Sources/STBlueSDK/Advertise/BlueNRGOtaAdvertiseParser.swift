//
//  BlueNRGOtaAdvertiseParser.swift
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

public class BlueNRGOtaAdvertiseParser: AdvertiseFilter {
    
    private static let defaultName = "BlueNRG OTA"
    
    public init() {
        //needed to be able to build this class from outisde the module..
    }
    
    public func filter(_ data: [String : Any]) -> AdvertiseInfo? {
        let txPower = (data[CBAdvertisementDataTxPowerLevelKey] as? UInt8) ?? 0
        let name = (data[CBAdvertisementDataLocalNameKey] as? String)
        let services = data[CBAdvertisementDataServiceUUIDsKey] as? [CBUUID]
        
        if services?.first == CBUUID(string: BlueUUID.Service.BlueNrg.otaUuid) {
            return BlueNRGAdvertiseInfo(name: name ?? BlueNRGOtaAdvertiseParser.defaultName,
                                        address: nil,
                                        featureMap: 0,
                                        deviceId: 0x84,
                                        protocolVersion: 1,
                                        boardType: .stEvalIDB008VX,
                                        isSleeping: false,
                                        hasGeneralPurpose: false,
                                        txPower: txPower,
                                        services: services ?? [])
        } else {
            return nil
        }
    }
    
}

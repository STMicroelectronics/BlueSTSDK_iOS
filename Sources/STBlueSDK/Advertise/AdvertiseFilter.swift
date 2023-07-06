//
//  AdvertiseFilter.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol AdvertiseFilter {

    /**
     * @param data: advertise data from centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
     * @return nill if the advertise doesn't contain all the needed info, otherwise a info object that is used to build the node
    */
    func filter(_ data:[String:Any]) -> AdvertiseInfo?
}

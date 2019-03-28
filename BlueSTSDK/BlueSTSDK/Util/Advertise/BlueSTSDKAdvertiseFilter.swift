//
//  BlueSTSDKAdvertiseFilter.swift
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 20/02/2019.
//  Copyright © 2019 STCentralLab. All rights reserved.
//

import Foundation

//TODO extend nsobject only to be availabe in Node
@objc open class BlueSTSDKAdvertiseInfo : NSObject{
    @objc public let name:String?
    @objc public let address:String?
    @objc public let featureMap:UInt32
    @objc public let deviceId:UInt8
    @objc public let protocolVersion:UInt8
    @objc public let boardType:BlueSTSDKNodeType
    @objc public let isSleeping:Bool
    @objc public let hasGeneralPurpose:Bool
    @objc public let txPower:UInt8
    
    @objc public init(name: String?, address: String?, featureMap: UInt32, deviceId: UInt8, protocolVersion: UInt8,
         boardType: BlueSTSDKNodeType, isSleeping: Bool, hasGeneralPurpose: Bool, txPower: UInt8){
        self.name = name
        self.address = address
        self.featureMap = featureMap
        self.deviceId = deviceId
        self.protocolVersion = protocolVersion
        self.boardType = boardType
        self.isSleeping = isSleeping
        self.hasGeneralPurpose = hasGeneralPurpose
        self.txPower = txPower
        super.init()
        
    }
    
}

/**
 * Protocol used to decide if we can build a BlueSTSDKNode from a CBPeriperal advertise
 * if we can build an AdvertiseInfo object the sdk will build a node from that infos
 */
//is objc becouse the startScanning is objc
@objc public protocol BlueSTSDKAdvertiseFilter{
    
    /**
     * @param data: advertise data from centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber)
     * @return nill if the advertise doesn't contain all the needed info, otherwise a info object that is used to build the node
    */
    func filter(_ data:[String:Any])->BlueSTSDKAdvertiseInfo?
}

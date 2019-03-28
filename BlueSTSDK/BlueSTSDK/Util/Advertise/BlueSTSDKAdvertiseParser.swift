//
//  BlueSTSDKAdvertiseParser.swift
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 20/02/2019.
//  Copyright © 2019 STCentralLab. All rights reserved.
//

import Foundation

class BlueSTSDKAdvertiseParser : BlueSTSDKAdvertiseFilter {
    
    private static let VERSION_PROTOCOL_SUPPORTED_MIN = UInt8(0x01);
    private static let VERSION_PROTOCOL_SUPPORTED_MAX = UInt8(0x01);
    
    func filter(_ data: [String : Any]) -> BlueSTSDKAdvertiseInfo? {
        let txPower = data[CBAdvertisementDataTxPowerLevelKey] as? UInt8 ?? 0
        let name = data[CBAdvertisementDataLocalNameKey] as? String
        
        guard let vendorData = data[CBAdvertisementDataManufacturerDataKey] as? Data,
            (vendorData.count == 6 || vendorData.count == 12 ) else {
            return nil
        }
        
        let protocolVersion = vendorData[0]
        guard protocolVersion >= BlueSTSDKAdvertiseParser.VERSION_PROTOCOL_SUPPORTED_MIN &&
              protocolVersion <= BlueSTSDKAdvertiseParser.VERSION_PROTOCOL_SUPPORTED_MAX else{
            return nil
        }
        
        let deviceId = vendorData[1].nodeId
        let deviceType = deviceId.nodeType
        let isSleeping = vendorData[1].isSleeping
        let hasGeneralPourpose = vendorData[1].hasGeneralPurpose
        let featureMap = (vendorData as NSData).extractBeUInt32(fromOffset: 2)
        var address:String? = nil
        if vendorData.count == 12 {
            address = String(format: "%02X:%02X:%02X:%02X:%02X:%02X", vendorData[6],vendorData[7],
                             vendorData[8],vendorData[9],vendorData[10],vendorData[11])
        }
        
        return BlueSTSDKAdvertiseInfo(name: name, address: address, featureMap: featureMap, deviceId: deviceId, protocolVersion: protocolVersion, boardType: deviceType, isSleeping: isSleeping, hasGeneralPurpose: hasGeneralPourpose, txPower: txPower)
    }
}
    

fileprivate extension UInt8 {
   private static let NUCLEO_BIT_MASK = UInt8(0x80)
   private static let IS_SLEEPING_BIT_MASK = UInt8(0x70)
   private static let HAS_GENERAL_PURPOSE_BIT_MASK = UInt8(0x80)

    private var isNucleo:Bool {
        get{
            return (self & UInt8.NUCLEO_BIT_MASK) != 0
        }
    }
    
    var nodeId:UInt8{
        get{
            if((self & UInt8(0x80)) != 0){
                return self
            }else{
                return self & UInt8(0x1F)
            }//if else
        }//get
    }
    
    var isSleeping:Bool {
        get{
            if ((self & UInt8.NUCLEO_BIT_MASK) != 0){
                return false
            }else{
                return (self & UInt8.IS_SLEEPING_BIT_MASK) != 0
            }
        }
    }
    
    var hasGeneralPurpose:Bool {
        get{
            if ((self & UInt8.NUCLEO_BIT_MASK) != 0){
                return false
            }else{
                return (self & UInt8.HAS_GENERAL_PURPOSE_BIT_MASK) != 0
            }
        }
    }
    
    var nodeType:BlueSTSDKNodeType{
        get{
            switch nodeId {
                case 0x00:
                    return .generic
                case 0x01:
                    return .STEVAL_WESU1
                case 0x02:
                    return .sensor_Tile
                case 0x03:
                    return .blue_Coin
                case 0x04:
                    return .STEVAL_IDB008VX
                case 0x05:
                    return .STEVAL_BCN002V1
                case 0x06:
                    return .sensor_Tile_101
                case 0x07:
                    return .discovery_IOT01A
                case 0x80...0xFF:
                    return .nucleo
                default:
                    return .generic
            }//switch
        }//get
    }
}


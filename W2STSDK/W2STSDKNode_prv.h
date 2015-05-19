//
//  W2STSDKNode_prv.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef W2STSDK_W2STSDKNode_prv_h
#define W2STSDK_W2STSDKNode_prv_h

#include "W2STSDKNode.h"

/**
 * private method of the node class
 */
@interface W2STSDKNode(Prv)

/**
 *  create a new node, if the node doesn't has a correct advertise this method will
 * throw an exception
 *
 *  @param peripheral        ble perigperal that
 *  @param rssi              advertise rssi
 *  @param advertisementData data in the advertise
 *
 *  @return <#return value description#>
 */
-(id) init :(CBPeripheral *)peripheral rssi:(NSNumber*)rssi advertise:(NSDictionary*)advertisementData;

-(void)updateRssi:(NSNumber*)rssi;
-(void)updateTxPower:(NSNumber*)txPower;
-(void)completeConnection;
-(void)completeDisconnection:(NSError*)error;
-(void)connectionError:(NSError*)error;
-(void)updateNodeStatus:(W2STSDKNodeState)newState;
-(void)characteristicUpdate:(CBCharacteristic*)characteristics;

-(BOOL)sendCommandMessageToFeature:(W2STSDKFeature*)f type:(uint8_t)commandType
                              data:(NSData*) commandData;

-(BOOL)writeDataToFeature:(W2STSDKFeature*)f data:(NSData*)data;


@end


#endif

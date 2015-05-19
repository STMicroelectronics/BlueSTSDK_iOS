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

@interface W2STSDKNode(Prv)

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

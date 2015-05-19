//
//  W2STSDKManager_prv.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef W2STSDK_W2STSDKManager_prv_h
#define W2STSDK_W2STSDKManager_prv_h

#include "W2STSDKManager.h"

@interface W2STSDKManager 

/////////package function//////////////
-(void)connect:(CBPeripheral*)peripheral;
-(void)disconnect:(CBPeripheral*)peripheral;

@end


#endif

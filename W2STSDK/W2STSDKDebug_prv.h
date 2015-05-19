//
//  W2STSDKDebug_prv.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef W2STSDK_W2STSDKDebug_prv_h
#define W2STSDK_W2STSDKDebug_prv_h
#include "W2STSDKDebug.h"

@interface W2STSDKDebug(Prv)

-(void)receiveCharacteristicsWriteUpdate:(CBCharacteristic*)termChar error:(NSError*)error;
-(void)receiveCharacteristicsUpdate:(CBCharacteristic*)termChar;

@end

#endif

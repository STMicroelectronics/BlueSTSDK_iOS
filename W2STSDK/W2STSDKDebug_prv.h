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

/**
 *  package method, called when CBPeripheral finish to write the data to an
 * debug characteristic
 *
 *  @param termChar characteristics where we write the data
 *  @param error    if !=nil error happen during the write
 */
-(void)receiveCharacteristicsWriteUpdate:(CBCharacteristic*)termChar error:(NSError*)error;

/**
 *  package method, called by the CBPeripheral receive an update from the debug service
 *
 *  @param termChar updated characteristics
 */
-(void)receiveCharacteristicsUpdate:(CBCharacteristic*)termChar;

@end

#endif

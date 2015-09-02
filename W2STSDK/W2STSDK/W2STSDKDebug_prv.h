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


/**
 *  add package/private data to the W2STSDKDebug class
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKDebug(Prv)

/**
 * @package
 * called when CBPeripheral finish to write the data to an debug characteristic
 * @par package method
 *
 *  @param termChar characteristics where we write the data
 *  @param error    if !=nil error happen during the write
 */
-(void)receiveCharacteristicsWriteUpdate:(CBCharacteristic*)termChar
                                   error:(NSError*)error;

/**
 * @package
 * called by the CBPeripheral receive an update from the debug service
 * @par package method
 *
 *  @param termChar updated characteristics
 */
-(void)receiveCharacteristicsUpdate:(CBCharacteristic*)termChar;

@end

#endif

//
//  W2STSDKManager_prv.h
//  W2STSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef W2STSDK_W2STSDKManager_prv_h
#define W2STSDK_W2STSDKManager_prv_h

#include <CoreBluetooth/CBPeripheral.h>
#include "W2STSDKManager.h"

/**
 *  private method of the class {@link W2STSDKManager} this method are used 
 *  by the sdk
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKManager(Prv)

/**
 *  start a connection with a ble peripheral
 *
 *  @param peripheral device to connect
 */
-(void)connect:(CBPeripheral*)peripheral;


/**
 *  close the connection with a ble peripheral
 *
 *  @param peripheral device to disconnect
 */
-(void)disconnect:(CBPeripheral*)peripheral;

/**
 * get the list of feature that is possible find in a specific device.
 *
 *  @return map of <{@link featureMask_t},W2STSDKFeature>
 */
-(NSDictionary*)getFeaturesForDevice:(uint8_t)deviceId;

@end

#endif

//
//  BlueSTSDKManager_prv.h
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 19/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef BlueSTSDK_BlueSTSDKManager_prv_h
#define BlueSTSDK_BlueSTSDKManager_prv_h

#include <CoreBluetooth/CBPeripheral.h>
#include "BlueSTSDKManager.h"

/**
 *  private method of the class {@link BlueSTSDKManager} this method are used 
 *  by the sdk
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKManager(Prv)

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
 *  @return map of <{@link featureMask_t},BlueSTSDKFeature>
 */
-(NSDictionary*)getFeaturesForDevice:(uint8_t)deviceId;

@end

#endif

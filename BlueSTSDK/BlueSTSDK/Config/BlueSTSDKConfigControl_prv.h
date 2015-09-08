//
//  BlueSTSDKConfigControl_prv.h
//
//  Created by Antonino Raucea on 06/30/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef BlueSTSDKConfigControl_prv_h
#define BlueSTSDKConfigControl_prv_h

#import <Foundation/Foundation.h>

#import "BlueSTSDKConfigControl.h"

@interface BlueSTSDKConfigControl(prv)

/**
 * call the method onRegisterReadResult or  onRegisterWriteResult for
 * each delegate that subscribe to this feature.
 * @par
 * if you extend the method update you have to call this method after that you update the data
 *
 * @param characteristic byte read from the register
 */
-(void)characteristicsUpdate:(CBCharacteristic *)characteristic;
/**
 * call the method onRequestResult for
 * each listener that subscribe to this feature.
 * @par
 * if you extend the method update you have to call this method after that you update the data
 * 
 * @param characteristic that contains the data command sent to the device
 * @param success true if the wrote command is send correctly
 */
-(void)characteristicsWriteUpdate:(CBCharacteristic *)characteristic success:(bool)success;

@end

#endif //BlueSTSDKConfigControl_prv_h

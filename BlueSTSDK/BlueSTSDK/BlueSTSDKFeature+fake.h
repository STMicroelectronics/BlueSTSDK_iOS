//
//  BlueSTSDKFeature+fake.h
//  BlueSTSDK
//
//  Created by Giovanni Visentini on 20/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#ifndef BlueSTSDK_BlueSTSDKFeature_fake_h
#define BlueSTSDK_BlueSTSDKFeature_fake_h

#import "BlueSTSDKFeature.h"

/**
 * Extend the feature for be able to generate fake data to be uesed in the ios 
 * emulator
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeature (fake)

/**
 *  <b>abstract method</b>, you have to overwrite this method if you want 
 *  enable the possibility to use a fake feature into the ios emulator
 *  @note it is an abstract method, you have to overwrite it!
 
 *  @return data that will be passed to the updateFeature for trigger a fake feature update
 */
-(NSData*) generateFakeData;

@end

#endif

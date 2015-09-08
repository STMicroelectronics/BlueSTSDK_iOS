//
//  BlueSTSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature.h"

/**
 * Export the data from a temperature sensor
 * @author STMicroelectronics - Central Labs.

 */
@interface BlueSTSDKFeatureTemperature : BlueSTSDKFeature

/**
 *  extract the temperature value
 *
 *  @param data sample read from the node
 *
 *  @return temperature value
 */
+(float)getTemperature:(BlueSTSDKFeatureSample*)data;

@end

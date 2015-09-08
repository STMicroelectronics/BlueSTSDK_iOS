//
//  BlueSTSDKFeatureHumidity.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature.h"

/**
 * Feature that contains the data from an humidity sensor
 * @par
 * The data exported is the % of humidity
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureHumidity : BlueSTSDKFeature

/**
 *  % of humidity extracted by the sensor
 *
 *  @param data sample read from the node
 *
 *  @return % of humidity extracted by the sensor
 */
+(float)getHumidity:(BlueSTSDKFeatureSample*)data;

@end

//
//  W2STFeaturePressure.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature.h"

/**
 *  Feature that export the data from a pressure sensor
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeaturePressure : BlueSTSDKFeature

/**
 *  pressure value
 *
 *  @param data sample read from the node
 *
 *  @return pressure value
 */
+(float)getPressure:(BlueSTSDKFeatureSample*)data;


@end

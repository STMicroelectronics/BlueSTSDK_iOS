//
//  BlueSTSDKFeatureLuminosity.h
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature.h"

/**
 *  This feature contains the data from a luminosity sensor
 * @par
 *  the data is the liminosity in lux read from the sensor
 *  @note since the luminosity and the proximity come from the same sensor this
 * two feature can't be used at the same time
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureLuminosity : BlueSTSDKFeature

/**
 *  luminosity value
 *
 *  @param data sample read from the node
 *
 *  @return luminosity value
 */
+(uint16_t)getLuminosity:(BlueSTSDKFeatureSample*)data;

@end

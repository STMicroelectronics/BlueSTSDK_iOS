//
//  W2STSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * Export the data from a temperature sensor
 * @author STMicroelectronics - Central Labs.

 */
@interface W2STSDKFeatureFreeFall : W2STSDKFeature

/**
 *  extract the activity value
 *
 *  @param data sample read from the node
 *
 *  @return activity value
 */
+(bool)getFreeFallStatus:(W2STSDKFeatureSample*)sample;


@end

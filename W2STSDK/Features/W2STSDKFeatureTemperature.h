//
//  W2STSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * export the data from a temperature sensor
 */
@interface W2STSDKFeatureTemperature : W2STSDKFeature

/**
 *  extract the temperature value
 *
 *  @param data data returned by getFieldsData
 *
 *  @return temperature value
 */
+(float)getTemperature:(NSArray*)data;

@end

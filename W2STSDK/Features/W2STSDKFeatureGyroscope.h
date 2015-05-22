//
//  W2STSDKFeatureGyroscope.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * Feature that contains the data from a gyroscope sensor
 */
@interface W2STSDKFeatureGyroscope : W2STSDKFeature

/**
 *  gyroscope data in the x Axis
 *
 *  @param data data returned by getFieldsData
 *
 *  @return  gyroscope data in the x Axis
 */
+(float)getGyroX:(NSArray*)data;

/**
 *  gyroscope data in the y Axis
 *
 *  @param data data returned by getFieldsData
 *
 *  @return  gyroscope data in the y Axis
 */
+(float)getGyroY:(NSArray*)data;

/**
 *  gyroscope data in the z Axis
 *
 *  @param data data returned by getFieldsData
 *
 *  @return  gyroscope data in the z Axis
 */
+(float)getGyroZ:(NSArray*)data;


@end

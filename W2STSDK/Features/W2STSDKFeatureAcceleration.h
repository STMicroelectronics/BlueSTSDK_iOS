//
//  W2STSDKFeatureAcceleration.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * feature that contains the data of an accelerometer
 *
 */
@interface W2STSDKFeatureAcceleration : W2STSDKFeature

/**
 *  return the x component of the acceleration
 *
 *  @param data data returned by getFieldsData
 *
 *  @return acceleration in the x axis
 */
+(float)getAccX:(NSArray*)data;

/**
 *  return the y component of the acceleration
 *
 *  @param data data returned by getFieldsData
 *
 *  @return acceleration in the y axis
 */
+(float)getAccY:(NSArray*)data;

/**
 *  return the z component of the acceleration
 *
 *  @param data data returned by getFieldsData
 *
 *  @return acceleration in the z axis
 */
+(float)getAccZ:(NSArray*)data;

@end

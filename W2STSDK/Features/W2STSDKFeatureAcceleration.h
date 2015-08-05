//
//  W2STSDKFeatureAcceleration.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * Feature that contains the data of an accelerometer.
 * \par
 * The data exported are an array of 3 float component (x,y,z) with the acceleration
 * on that axis
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKFeatureAcceleration : W2STSDKFeature

/**
 *  return the x component of the acceleration
 *
 *  @param data sample read from the node
 *  @return acceleration in the x axis
 */
+(float)getAccX:(W2STSDKFeatureSample*)data;

/**
 *  return the y component of the acceleration
 *
 *  @param data sample read from the node
 *
 *  @return acceleration in the y axis
 */
+(float)getAccY:(W2STSDKFeatureSample*)data;

/**
 *  return the z component of the acceleration
 *
 *  @param data sample read from the node
 *
 *  @return acceleration in the z axis
 */
+(float)getAccZ:(W2STSDKFeatureSample*)data;

@end

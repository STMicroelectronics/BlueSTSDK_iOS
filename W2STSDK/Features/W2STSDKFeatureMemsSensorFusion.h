//
//  W2STSDKFeatureQuaternion.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeatureAutoConfigurable.h"

/**
 *  this feature export the quaternuion data that are computed on the node
 *  using the accelerometer, gyroscope and magnetometer data
 */
@interface W2STSDKFeatureMemsSensorFusion : W2STSDKFeatureAutoConfigurable

/**
 *  extract the x quaternion component
 *
 *  @param data sample read from the node
 *
 *  @return x quaternion component
 */
+(float)getQi:(W2STSDKFeatureSample*)data;

/**
 *  extract the y quaternion component
 *
 *  @param data sample read from the node
 *
 *  @return y quaternion component
 */
+(float)getQj:(W2STSDKFeatureSample*)data;

/**
 *  extract the z quaternion component
 *
 *  @param data sample read from the node
 *
 *  @return z quaternion component
 */
+(float)getQk:(W2STSDKFeatureSample*)data;

/**
 *  extract the w quaternion component
 *
 *  @param data sample read from the node
 *
 *  @return w quaternion component
 */
+(float)getQs:(W2STSDKFeatureSample*)data;

@end

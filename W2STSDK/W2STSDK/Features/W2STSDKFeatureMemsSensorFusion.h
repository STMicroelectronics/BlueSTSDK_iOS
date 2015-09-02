//
//  W2STSDKFeatureQuaternion.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeatureAutoConfigurable.h"

/**
 *  The feature export the quaternuion data that are computed on the node
 *  using the accelerometer, gyroscope and magnetometer data
 * @par
 * the data are the quaternion component: the vector comonents (qi,qj,qk)
 * and the scalar component qs, the quaternion is normalized
 * @note this feature is autoconfigurable for calibrate the magnetometer data
 * @author STMicroelectronics - Central Labs.
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

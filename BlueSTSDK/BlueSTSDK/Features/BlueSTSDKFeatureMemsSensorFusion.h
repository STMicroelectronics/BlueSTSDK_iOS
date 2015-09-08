//
//  BlueSTSDKFeatureQuaternion.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeatureAutoConfigurable.h"

/**
 *  The feature export the quaternuion data that are computed on the node
 *  using the accelerometer, gyroscope and magnetometer data
 * @par
 * the data are the quaternion component: the vector comonents (qi,qj,qk)
 * and the scalar component qs, the quaternion is normalized
 * @note this feature is autoconfigurable for calibrate the magnetometer data
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureMemsSensorFusion : BlueSTSDKFeatureAutoConfigurable

/**
 *  extract the x quaternion component
 *
 *  @param data sample read from the node
 *
 *  @return x quaternion component
 */
+(float)getQi:(BlueSTSDKFeatureSample*)data;

/**
 *  extract the y quaternion component
 *
 *  @param data sample read from the node
 *
 *  @return y quaternion component
 */
+(float)getQj:(BlueSTSDKFeatureSample*)data;

/**
 *  extract the z quaternion component
 *
 *  @param data sample read from the node
 *
 *  @return z quaternion component
 */
+(float)getQk:(BlueSTSDKFeatureSample*)data;

/**
 *  extract the w quaternion component
 *
 *  @param data sample read from the node
 *
 *  @return w quaternion component
 */
+(float)getQs:(BlueSTSDKFeatureSample*)data;

@end

//
//  BlueSTSDKFeatureMemsSensorFusionCompact.h
//  W2STApp
//
//  Created by Giovanni Visentini on 13/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeatureMemsSensorFusion.h"

/**
 *  The feature export the quaternuion data that are computed on the node
 *  using the accelerometer, gyroscope and magnetometer data
 * @par
 * instead of {@link BlueSTSDKFeatureMemsSensorFusion} here the quaternion are send
 * using short instead of float, and more than one at time, for reach hight transmission rate.
 * @par
 * in this case we assume that the quaternions are always normalized since the node
 * will transmit only the vectorial component
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureMemsSensorFusionCompact : BlueSTSDKFeatureMemsSensorFusion


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

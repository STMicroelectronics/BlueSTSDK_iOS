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
 *  @param data data returned by getFieldsData
 *
 *  @return x quaternion component
 */
+(float)getX:(NSArray*)data;

/**
 *  extract the y quaternion component
 *
 *  @param data data returned by getFieldsData
 *
 *  @return y quaternion component
 */
+(float)getY:(NSArray*)data;

/**
 *  extract the z quaternion component
 *
 *  @param data data returned by getFieldsData
 *
 *  @return z quaternion component
 */
+(float)getZ:(NSArray*)data;

/**
 *  extract the w quaternion component
 *
 *  @param data data returned by getFieldsData
 *
 *  @return w quaternion component
 */
+(float)getW:(NSArray*)data;

@end

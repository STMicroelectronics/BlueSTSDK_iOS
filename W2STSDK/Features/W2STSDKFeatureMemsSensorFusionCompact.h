//
//  W2STSDKFeatureMemsSensorFusionCompact.h
//  W2STApp
//
//  Created by Giovanni Visentini on 13/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeatureMemsSensorFusion.h"

/**
 *  this feature export the quaternuion data that are computed on the node
 *  using the accelerometer, gyroscope and magnetometer data.
 *  in this case the quaternion are sended with a low precision and 3 quaternion
 * each package. in this way we can reach an hight frame rate.
 */
@interface W2STSDKFeatureMemsSensorFusionCompact : W2STSDKFeatureMemsSensorFusion


/**
 *  extract the x quaternion component
 *
 *  @param data data returned by getFieldsData
 *
 *  @return x quaternion component
 */
+(float)getQi:(NSArray*)data;

/**
 *  extract the y quaternion component
 *
 *  @param data data returned by getFieldsData
 *
 *  @return y quaternion component
 */
+(float)getQj:(NSArray*)data;

/**
 *  extract the z quaternion component
 *
 *  @param data data returned by getFieldsData
 *
 *  @return z quaternion component
 */
+(float)getQk:(NSArray*)data;

/**
 *  extract the w quaternion component
 *
 *  @param data data returned by getFieldsData
 *
 *  @return w quaternion component
 */
+(float)getQs:(NSArray*)data;


@end

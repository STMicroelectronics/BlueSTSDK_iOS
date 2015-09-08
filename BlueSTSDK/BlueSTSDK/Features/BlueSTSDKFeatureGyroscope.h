//
//  BlueSTSDKFeatureGyroscope.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature.h"

/**
 * Feature that contains the data from a gyroscope sensor
 * \par
 * The data exported are an array of 3 float component (x,y,z) with the gyroscope
 * value on that axis
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureGyroscope : BlueSTSDKFeature

/**
 *  gyroscope data in the x Axis
 *
 *  @param data sample read from the node
 *
 *  @return  gyroscope data in the x Axis
 */
+(float)getGyroX:(BlueSTSDKFeatureSample*)data;

/**
 *  gyroscope data in the y Axis
 *
 *  @param data sample read from the node
 *
 *  @return  gyroscope data in the y Axis
 */
+(float)getGyroY:(BlueSTSDKFeatureSample*)data;

/**
 *  gyroscope data in the z Axis
 *
 *  @param data sample read from the node
 *
 *  @return  gyroscope data in the z Axis
 */
+(float)getGyroZ:(BlueSTSDKFeatureSample*)data;


@end

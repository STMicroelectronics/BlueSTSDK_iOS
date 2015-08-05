//
//  W2STSTSDKFeatureMagnetometer.h
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 *  export the data from a magnetometer sensor
 * \par
 * The data exported are an array of 3 float component (x,y,z) with the magnetometer
 * information on that axis
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKFeatureMagnetometer : W2STSDKFeature

/**
 *  extract the magnetometer value of the X axis
 *
 *  @param data sample read from the node
 *
 *  @return magetometer value of the x axis
 */
+(float)getMagX:(W2STSDKFeatureSample*)data;

/**
 *  extract the magnetometer value of the y axis
 *
 *  @param data sample read from the node
 *
 *  @return magetometer value of the y axis
 */
+(float)getMagY:(W2STSDKFeatureSample*)data;

/**
 *  extract the magnetometer value of the z axis
 *
 *  @param data sample read from the node
 *
 *  @return magetometer value of the z axis
 */
+(float)getMagZ:(W2STSDKFeatureSample*)data;

@end

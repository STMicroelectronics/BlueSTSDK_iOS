//
//  W2STSDKFeatureProximity.h
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"


/**
 *  feature that export the data from a proximity sensor, since this can be the
 * same luminosity sensor, using both feature at the same time can not be possible
 */
@interface W2STSDKFeatureProximity : W2STSDKFeature

/**
 *  proximity value or out of range value
 *
 *  @param data sample read from the node
 *
 *  @return proximity value or out of range
 */
+(uint16_t)getProximityDistance:(W2STSDKFeatureSample*)data;

/**
 *  is a special value returned when the sensor detect an object out of its range
 *
 *  @return sensor out of range values
 */
+(uint16_t)outOfRangeValue;

@end

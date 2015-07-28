//
//  W2STFeaturePressure.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 *  feature that export the data from a pressure sensor
 */
@interface W2STSDKFeaturePressure : W2STSDKFeature

/**
 *  pressure value
 *
 *  @param data sample read from the node
 *
 *  @return pressure value
 */
+(float)getPressure:(W2STSDKFeatureSample*)data;


@end

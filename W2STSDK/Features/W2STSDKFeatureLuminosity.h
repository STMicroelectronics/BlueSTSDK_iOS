//
//  W2STSDKFeatureLuminosity.h
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 *  this feature contains the data from a luminosity sensor
 *  Note: since the luminosity and the proximity come from the same sensor this
 * two feature can't be used at the same time
 */
@interface W2STSDKFeatureLuminosity : W2STSDKFeature

/**
 *  luminosity value
 *
 *  @param data sample read from the node
 *
 *  @return luminosity value
 */
+(uint16_t)getLuminosity:(W2STSDKFeatureSample*)data;

@end

//
//  W2STSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * Notify a node free fall event detection
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKFeatureFreeFall : W2STSDKFeature

/**
 *  @param data sample read from the node
 *
 *  @return true if a free fall was detected by the board
 */
+(bool)getFreeFallStatus:(W2STSDKFeatureSample*)sample;


@end

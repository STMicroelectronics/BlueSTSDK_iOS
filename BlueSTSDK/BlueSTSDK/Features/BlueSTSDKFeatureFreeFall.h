//
//  BlueSTSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature.h"

/**
 * Notify a node free fall event detection
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureFreeFall : BlueSTSDKFeature

/**
 *  @param data sample read from the node
 *
 *  @return true if a free fall was detected by the board
 */
+(bool)getFreeFallStatus:(BlueSTSDKFeatureSample*)sample;


@end

//
//  W2STSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * Export the data from a temperature sensor
 * @author STMicroelectronics - Central Labs.

 */
@interface W2STSDKFeatureActivity : W2STSDKFeature


typedef NS_ENUM(NSInteger, W2STSDKFeatureActivityType){
    W2STSDKFeatureActivityTypeStanding =0x00,
    W2STSDKFeatureActivityTypeWalking =0x01,
    W2STSDKFeatureActivityTypeFastWalking =0x02,
    W2STSDKFeatureActivityTypeRunning =0x03,
    W2STSDKFeatureActivityTypeCycling =0x04,
    W2STSDKFeatureActivityTypeDriving =0x05,
    W2STSDKFeatureActivityTypeError =0xFF
};

/**
 *  extract the activity value
 *
 *  @param data sample read from the node
 *
 *  @return activity value
 */
+(W2STSDKFeatureActivityType)getActivity:(W2STSDKFeatureSample*)sample;

@end

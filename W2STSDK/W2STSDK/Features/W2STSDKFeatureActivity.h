//
//  W2STSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * Export the data from the activiy recognition algorithm
 * @author STMicroelectronics - Central Labs.

 */
@interface W2STSDKFeatureActivity : W2STSDKFeature

/**
 *  different type of activity recognised by the device
 */
typedef NS_ENUM(NSInteger, W2STSDKFeatureActivityType){
    /**
     *  we don't have enough data for select an activity
     */
    W2STSDKFeatureActivityTypeNoActivity =0x00,
    /**
     *  the person is standing
     */
    W2STSDKFeatureActivityTypeStanding =0x01,
    /**
     *  the person is walking
     */
    W2STSDKFeatureActivityTypeWalking =0x02,
    /**
     *  the person is fast walking
     */
    W2STSDKFeatureActivityTypeFastWalking =0x03,
    /**
     *  the person is jogging
     */
    W2STSDKFeatureActivityTypeJogging =0x04,
    /**
     *  the person is biking
     */
    W2STSDKFeatureActivityTypeBiking =0x05,
    /**
     *  the person is driving
     */
    W2STSDKFeatureActivityTypeDriving =0x06,
    /**
     *  unknown activity
     */
    W2STSDKFeatureActivityTypeError =0xFF
};

/**
 *  extract the activity value
 *
 *  @param data sample read from the node
 *
 *  @return activity value
 */
+(W2STSDKFeatureActivityType)getActivityType:(W2STSDKFeatureSample*)sample;

/**
 *  return the data when we receive the notification
 *
 *  @param sample data read from the node
 *
 *  @return data when we receive the data
 */
+(NSDate*)getActivityDate:(W2STSDKFeatureSample*)sample;

@end

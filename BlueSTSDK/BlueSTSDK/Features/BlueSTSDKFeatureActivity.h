//
//  BlueSTSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature.h"

/**
 * Export the data from the activiy recognition algorithm
 * @author STMicroelectronics - Central Labs.

 */
@interface BlueSTSDKFeatureActivity : BlueSTSDKFeature

/**
 *  different type of activity recognised by the device
 */
typedef NS_ENUM(NSInteger, BlueSTSDKFeatureActivityType){
    /**
     *  we don't have enough data for select an activity
     */
    BlueSTSDKFeatureActivityTypeNoActivity =0x00,
    /**
     *  the person is standing
     */
    BlueSTSDKFeatureActivityTypeStanding =0x01,
    /**
     *  the person is walking
     */
    BlueSTSDKFeatureActivityTypeWalking =0x02,
    /**
     *  the person is fast walking
     */
    BlueSTSDKFeatureActivityTypeFastWalking =0x03,
    /**
     *  the person is jogging
     */
    BlueSTSDKFeatureActivityTypeJogging =0x04,
    /**
     *  the person is biking
     */
    BlueSTSDKFeatureActivityTypeBiking =0x05,
    /**
     *  the person is driving
     */
    BlueSTSDKFeatureActivityTypeDriving =0x06,
    /**
     *  unknown activity
     */
    BlueSTSDKFeatureActivityTypeError =0xFF
};

/**
 *  extract the activity value
 *
 *  @param data sample read from the node
 *
 *  @return activity value
 */
+(BlueSTSDKFeatureActivityType)getActivityType:(BlueSTSDKFeatureSample*)sample;

/**
 *  return the data when we receive the notification
 *
 *  @param sample data read from the node
 *
 *  @return data when we receive the data
 */
+(NSDate*)getActivityDate:(BlueSTSDKFeatureSample*)sample;

@end

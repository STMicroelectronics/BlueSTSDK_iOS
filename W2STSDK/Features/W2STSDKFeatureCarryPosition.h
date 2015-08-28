//
//  W2STSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * Export the data from the carry position recognition algorithm
 * @author STMicroelectronics - Central Labs.

 */
@interface W2STSDKFeatureCarryPosition : W2STSDKFeature

/**
 *  different type of position recognised by the device
 */
typedef NS_ENUM(NSInteger, W2STSDKFeatureCarryPositionType){
    /**
     *  we don't have enough data for select a position
     */
    W2STSDKFeatureCarryPositionUnknown =0x00,
    /**
     *  the device is on the desk
     */
    W2STSDKFeatureCarryPositionOnDesk =0x01,
    /**
     *  the device is in the user hand
     */
    W2STSDKFeatureCarryPositionInHand =0x02,
    /**
     *  the device is in near the user head
     */
    W2STSDKFeatureCarryPositionNearHead =0x03,
    /**
     *  the device is in the shirt pocket
     */
    W2STSDKFeatureCarryPositionShirtPocket =0x04,
    /**
     *  the device is in the trousers pocket
     */
    W2STSDKFeatureCarryPositionTrousersPocket =0x05,
    /**
     *  the device is attached to an arm that is swinging
     */
    W2STSDKFeatureCarryPositionArmSwing =0x06,
    /**
     *  invalid code
     */
    W2STSDKFeatureCarryPositionError =0xFF
};

/**
 *  extract the position value
 *
 *  @param data sample read from the node
 *
 *  @return activity value
 */
+(W2STSDKFeatureCarryPositionType)getPositionType:(W2STSDKFeatureSample*)sample;

@end

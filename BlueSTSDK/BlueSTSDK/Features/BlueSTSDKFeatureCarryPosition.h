//
//  BlueSTSDKTemperature.h
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature.h"

/**
 * Export the data from the carry position recognition algorithm
 * @author STMicroelectronics - Central Labs.

 */
@interface BlueSTSDKFeatureCarryPosition : BlueSTSDKFeature

/**
 *  different type of position recognised by the device
 */
typedef NS_ENUM(NSInteger, BlueSTSDKFeatureCarryPositionType){
    /**
     *  we don't have enough data for select a position
     */
    BlueSTSDKFeatureCarryPositionUnknown =0x00,
    /**
     *  the device is on the desk
     */
    BlueSTSDKFeatureCarryPositionOnDesk =0x01,
    /**
     *  the device is in the user hand
     */
    BlueSTSDKFeatureCarryPositionInHand =0x02,
    /**
     *  the device is in near the user head
     */
    BlueSTSDKFeatureCarryPositionNearHead =0x03,
    /**
     *  the device is in the shirt pocket
     */
    BlueSTSDKFeatureCarryPositionShirtPocket =0x04,
    /**
     *  the device is in the trousers pocket
     */
    BlueSTSDKFeatureCarryPositionTrousersPocket =0x05,
    /**
     *  the device is attached to an arm that is swinging
     */
    BlueSTSDKFeatureCarryPositionArmSwing =0x06,
    /**
     *  invalid code
     */
    BlueSTSDKFeatureCarryPositionError =0xFF
};

/**
 *  extract the position value
 *
 *  @param data sample read from the node
 *
 *  @return activity value
 */
+(BlueSTSDKFeatureCarryPositionType)getPositionType:(BlueSTSDKFeatureSample*)sample;

@end

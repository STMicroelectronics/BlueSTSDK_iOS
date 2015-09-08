//
//  BlueSTSDKFeatureBattery.h
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature.h"

/**
 * this feature export the from the battery information from expansion board
 * \par
 * The data exported are an array of 3 float component (% of charge,voltage,current)
 * and the buttery status as an enum value
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureBattery : BlueSTSDKFeature

/**
 * Enumeration that contains the battery status
 */
typedef NS_ENUM(NSInteger, BlueSTSDKFeatureBatteryStatus){
    /**
     *  The battery has a level below the 10%
     */
    BlueSTSDKFeatureBatteryStatusLowBattery  =0x00,
    /**
     *  The battery is discharging
     */
    BlueSTSDKFeatureBatteryStatusDischarging =0x01,
    /**
     *  The battery is plugged, but is already charged
     */
    BlueSTSDKFeatureBatteryStatusPluggedNotCharging =0x02,
    /**
     *  the battery is charging
     */
    BlueSTSDKFeatureBatteryStatusCharging =0x03,
    /**
     *  error state/battery not present
     */
     BlueSTSDKFeatureBatteryStatusError =0xFF
};

/**
 *  current battery status
 *
 *  @param data sample read from the node
 *
 *  @return current battery status
 */
+(BlueSTSDKFeatureBatteryStatus)getBatteryStatus:(BlueSTSDKFeatureSample*)data;

/**
 *  current battery status as a string
 *
 *  @param data sample read from the node
 *
 *  @return current battery status as a string
 */
+(NSString*)getBatteryStatusStr:(BlueSTSDKFeatureSample*)data;

/**
 *  current charge of percentage
 *
 *  @param data sample read from the node
 *
 *  @return battery percentage of charge
 */
+(float)getBatteryLevel:(BlueSTSDKFeatureSample*)data;

/**
 *  current battery voltage
 *
 *  @param data sample read from the node
 *
 *  @return battery voltage in mV
 */
+(float)getBatteryVoltage:(BlueSTSDKFeatureSample*)data;

/**
 *  battery current, if positive the battery is charging, if negative is discharging
 *
 *  @param data sample read from the node
 *
 *  @return battery current in mA
 */
+(float)getBatteryCurrent:(BlueSTSDKFeatureSample*)data;


@end

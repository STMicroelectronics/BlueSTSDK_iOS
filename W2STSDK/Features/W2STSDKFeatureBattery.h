//
//  W2STSDKFeatureBattery.h
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

/**
 * this feature export the from the battery information from expansion board
 * \par
 * The data exported are an array of 3 float component (% of charge,voltage,current)
 * and the buttery status as an enum value
 * @author STMicroelectronics - Central Labs.
 */
@interface W2STSDKFeatureBattery : W2STSDKFeature

/**
 * Enumeration that contains the battery status
 */
typedef NS_ENUM(NSInteger, W2STSDKFeatureBatteryStatus){
    /**
     *  The battery has a level below the 10%
     */
    W2STSDKFeatureBatteryStatusLowBattery  =0x00,
    /**
     *  The battery is discharging
     */
    W2STSDKFeatureBatteryStatusDischarging =0x01,
    /**
     *  The battery is plugged, but is already charged
     */
    W2STSDKFeatureBatteryStatusPluggedNotCharging =0x02,
    /**
     *  the battery is charging
     */
    W2STSDKFeatureBatteryStatusCharging =0x03,
    /**
     *  error state/battery not present
     */
     W2STSDKFeatureBatteryStatusError =0xFF
};

/**
 *  current battery status
 *
 *  @param data sample read from the node
 *
 *  @return current battery status
 */
+(W2STSDKFeatureBatteryStatus)getBatteryStatus:(W2STSDKFeatureSample*)data;

/**
 *  current battery status as a string
 *
 *  @param data sample read from the node
 *
 *  @return current battery status as a string
 */
+(NSString*)getBatteryStatusStr:(W2STSDKFeatureSample*)data;

/**
 *  current charge of percentage
 *
 *  @param data sample read from the node
 *
 *  @return battery percentage of charge
 */
+(float)getBatteryLevel:(W2STSDKFeatureSample*)data;

/**
 *  current battery voltage
 *
 *  @param data sample read from the node
 *
 *  @return battery voltage in mV
 */
+(float)getBatteryVoltage:(W2STSDKFeatureSample*)data;

/**
 *  battery current, if positive the battery is charging, if negative is discharging
 *
 *  @param data sample read from the node
 *
 *  @return battery current in mA
 */
+(float)getBatteryCurrent:(W2STSDKFeatureSample*)data;


@end

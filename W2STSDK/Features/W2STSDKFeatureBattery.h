//
//  W2STSDKFeatureBattery.h
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"

typedef NS_ENUM(NSInteger, W2STSDKFeatureBatteryStatus) {
    //the battery has a level below the 10%
    W2STSDKFeatureBatteryStatusLowBattery  =0x00,
    //the battery is discharging
    W2STSDKFeatureBatteryStatusDischarging =0x01,
    //the battery is plugged, but is already charged
    W2STSDKFeatureBatteryStatusPluggedNotCharging =0x02,
    //the battery is charging
    W2STSDKFeatureBatteryStatusCharging =0x03,
    //error state/battery not present
    W2STSDKFeatureBatteryStatusError =0xFF
};

/**
 *  this feature export the from the battery information from expansion board
 */
@interface W2STSDKFeatureBattery : W2STSDKFeature

/**
 *  current battery status
 *
 *  @param data data returned by getFieldsData
 *
 *  @return current battery status
 */
+(W2STSDKFeatureBatteryStatus)getBatteryStatus:(NSArray*)data;

/**
 *  current battery status as a string
 *
 *  @param data data returned by getFieldsData
 *
 *  @return current battery status as a string
 */
+(NSString*)getBatteryStatusStr:(NSArray*)data;

/**
 *  current charge of percentage
 *
 *  @param data data returned by getFieldsData
 *
 *  @return battery percentage of charge
 */
+(float)getBatteryLevel:(NSArray*)data;

/**
 *  current battery voltage
 *
 *  @param data data returned by getFieldsData
 *
 *  @return battery voltage in mV
 */
+(float)getBatteryVoltage:(NSArray*)data;

/**
 *  battery current, if positive the battery is charging, if negative is discharging
 *
 *  @param data data returned by getFieldsData
 *
 *  @return battery current in mA
 */
+(float)getBatteryCurrent:(NSArray*)data;


@end

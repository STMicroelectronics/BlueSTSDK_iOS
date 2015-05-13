//
//  W2STSDKFeatureBattery.h
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature.h"


typedef NS_ENUM(NSInteger, W2STSDKFeatureBatteryStatus) {
    W2STSDKFeatureBatteryStatusLowBattery  =0x00,
    W2STSDKFeatureBatteryStatusDischarging =0x01,
    W2STSDKFeatureBatteryStatusPluggedNotCharging =0x02,
    W2STSDKFeatureBatteryStatusCharging =0x03,
    W2STSDKFeatureBatteryStatusError =0xFF
};


@interface W2STSDKFeatureBattery : W2STSDKFeature

+(void)initialize;
+(W2STSDKFeatureBatteryStatus)getBatteryStatus:(NSArray*)data;
+(NSString*)getBatteryStatusStr:(NSArray*)data;

+(float)getBatteryLevel:(NSArray*)data;
+(float)getBatteryVoltage:(NSArray*)data;
+(float)getBatteryCurrent:(NSArray*)data;

-(id) initWhitNode:(W2STSDKNode *)node;

//abstract method
-(NSArray*) getFieldsDesc;
-(NSArray*) getFieldsData;
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;

@end

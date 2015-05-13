//
//  W2STSDKFeatureBattery.m
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeatureBattery.h"
#import "W2STSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"Battery"

#define FEATURE_LEVEL_NAME @"Level"
#define FEATURE_LEVEL_UNIT @"%"
#define FEATURE_LEVEL_MAX @100
#define FEATURE_LEVEL_MIN @0

#define FEATURE_VOLTAGE_NAME @"Voltage"
#define FEATURE_VOLTAGE_UNIT @"V"
#define FEATURE_VOLTAGE_MAX @-10
#define FEATURE_VOLTAGE_MIN @10

#define FEATURE_CURRENT_NAME @"Current"
#define FEATURE_CURRENT_UNIT @"mA"
#define FEATURE_CURRENT_MAX @-10
#define FEATURE_CURRENT_MIN @10

#define FEATURE_STATUS_NAME @"Status"
#define FEATURE_STATUS_UNIT @""
#define FEATURE_STATIS_MAX @0xFF
#define FEATURE_STATUS_MIN @0

static NSArray *sFieldDesc;

@implementation W2STSDKFeatureBattery{
    NSMutableArray *mFieldData;
    uint32_t mTimestamp;
    dispatch_queue_t mRwQueue;
}

+(void)initialize{
    if(self == [W2STSDKFeatureBattery class]){
        sFieldDesc = [NSArray arrayWithObjects:
                      [W2STSDKFeatureField  createWithName:FEATURE_LEVEL_NAME
                                                      unit:FEATURE_LEVEL_UNIT
                                                      type:W2STSDKFeatureFieldTypeFloat
                                                       min:FEATURE_LEVEL_MIN
                                                       max:FEATURE_LEVEL_MAX ],
                      [W2STSDKFeatureField  createWithName:FEATURE_VOLTAGE_NAME
                                                      unit:FEATURE_VOLTAGE_UNIT
                                                      type:W2STSDKFeatureFieldTypeFloat
                                                       min:FEATURE_VOLTAGE_MAX
                                                       max:FEATURE_VOLTAGE_MIN ],
                      [W2STSDKFeatureField  createWithName:FEATURE_CURRENT_NAME
                                                      unit:FEATURE_CURRENT_UNIT
                                                      type:W2STSDKFeatureFieldTypeFloat
                                                       min:FEATURE_CURRENT_MAX
                                                       max:FEATURE_CURRENT_MIN ],
                      [W2STSDKFeatureField  createWithName:FEATURE_STATUS_NAME
                                                      unit:FEATURE_STATUS_UNIT
                                                      type:W2STSDKFeatureFieldTypeUInt8
                                                       min:FEATURE_STATIS_MAX
                                                       max:FEATURE_STATUS_MIN ],
                      nil];
    }//if
    
}



+(W2STSDKFeatureBatteryStatus)getBatteryStatus:(NSArray*)data{
    if(data.count<3)
        return NAN;
    switch([[data objectAtIndex:3] unsignedCharValue]){
        case 0x00:
            return W2STSDKFeatureBatteryStatusLowBattery;
        case 0x01:
            return W2STSDKFeatureBatteryStatusDischarging;
        case 0x02:
            return W2STSDKFeatureBatteryStatusPluggedNotCharging;
        case 0x03:
            return W2STSDKFeatureBatteryStatusCharging;
        case 0xFF:
            return W2STSDKFeatureBatteryStatusError;
        default:
            return W2STSDKFeatureBatteryStatusError;
    }
}

+(NSString*)getBatteryStatusStr:(NSArray*)data{
    switch ([W2STSDKFeatureBattery getBatteryStatus:data]){
        case W2STSDKFeatureBatteryStatusLowBattery:
            return @"Low battery";
        case W2STSDKFeatureBatteryStatusDischarging:
            return @"Discharging";
        case W2STSDKFeatureBatteryStatusPluggedNotCharging:
            return @"Plugged not charging";
        case W2STSDKFeatureBatteryStatusCharging:
            return @"Charging";
        case W2STSDKFeatureBatteryStatusError:
            return @"Error";
    }//switch
}//getBatteryStatusStr


+(float)getBatteryLevel:(NSArray*)data{
    if(data.count==0)
        return NAN;
    return[[data objectAtIndex:0] floatValue];
}

+(float)getBatteryVoltage:(NSArray*)data{
    if(data.count<1)
        return NAN;
    return [[data objectAtIndex:1] floatValue];
}

+(float)getBatteryCurrent:(NSArray*)data{
    if(data.count<2)
        return NAN;
    return [[data objectAtIndex:2] floatValue];
}


-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    mRwQueue = dispatch_queue_create("W2STSDKFeatureBattery", DISPATCH_QUEUE_CONCURRENT);
    mFieldData = [NSMutableArray arrayWithObjects:@0,@0,@0,@0, nil];
    mTimestamp=0;
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}

-(NSArray*) getFieldsData{
    __block NSArray *temp;
    dispatch_sync(mRwQueue, ^(){
        temp = [mFieldData copy];
    });
    return temp;
}

-(uint32_t) getTimestamp{
    __block uint32_t temp;
    dispatch_sync(mRwQueue, ^(){
        temp = mTimestamp;
    });
    return temp;
}

-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    float percentage =  [rawData extractLeInt16FromOffset:offset]/10.0f;
    //the data arrive in mV we store it in V
    float voltage = [rawData extractLeInt16FromOffset:offset+2]/1000.0f;
    float current = [rawData extractLeInt16FromOffset:offset+4];
    uint8_t status = [rawData extractUInt8FromOffset:offset+6];
    
    dispatch_barrier_async(mRwQueue, ^(){
        mTimestamp = timestamp;
        [mFieldData replaceObjectAtIndex:0 withObject:[NSNumber numberWithFloat:percentage]];
        [mFieldData replaceObjectAtIndex:1 withObject:[NSNumber numberWithFloat:voltage]];
        [mFieldData replaceObjectAtIndex:2 withObject:[NSNumber numberWithFloat:current]];
        [mFieldData replaceObjectAtIndex:3 withObject:[NSNumber numberWithUnsignedChar:status]];
        [self notifyUpdate];
        [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 7)] data:[mFieldData copy]];
    });
    return 7;
}

@end

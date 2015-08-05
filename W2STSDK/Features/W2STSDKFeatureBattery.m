//
//  W2STSDKFeatureBattery.m
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature_prv.h"
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

/**
 * @memberof W2STSDKFeatureBattery
 *  array with the description of field exported by the feature
 */
static NSArray *sFieldDesc;

@implementation W2STSDKFeatureBattery

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
}//initialize



+(W2STSDKFeatureBatteryStatus)getBatteryStatus:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<3)
        return NAN;
    switch([[sample.data objectAtIndex:3] unsignedCharValue]){
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

+(NSString*)getBatteryStatusStr:(W2STSDKFeatureSample*)sample{
    switch ([W2STSDKFeatureBattery getBatteryStatus:sample]){
        case W2STSDKFeatureBatteryStatusLowBattery:
            return @"Low battery";
        case W2STSDKFeatureBatteryStatusDischarging:
            return @"Discharging";
        case W2STSDKFeatureBatteryStatusPluggedNotCharging:
            return @"Plugged";
        case W2STSDKFeatureBatteryStatusCharging:
            return @"Charging";
        case W2STSDKFeatureBatteryStatusError:
            return @"Error";
    }//switch
}//getBatteryStatusStr


+(float)getBatteryLevel:(W2STSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}

+(float)getBatteryVoltage:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<1)
        return NAN;
    return [[sample.data objectAtIndex:1] floatValue];
}

+(float)getBatteryCurrent:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<2)
        return NAN;
    return [[sample.data objectAtIndex:2] floatValue];
}


-(instancetype) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}

/**
*  read 3*int16+uint8 for build the battery value, create the new sample and
* and notify it to the delegate
*
*  @param timestamp data time stamp
*  @param rawData   array of byte send by the node
*  @param offset    offset where we have to start reading the data
*
*  @throw exception if there are no 7 bytes available in the rawdata array
*  @return number of read bytes
*/
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    
    if(rawData.length-offset < 7){
        @throw [NSException
                exceptionWithName:@"Invalid Battery data"
                reason:@"The feature need 7 byte for extract the data"
                userInfo:nil];
    }//if
    
    float percentage =  [rawData extractLeUInt16FromOffset:offset]/10.0f;
    //the data arrive in mV we store it in V
    float voltage = [rawData extractLeInt16FromOffset:offset+2]/1000.0f;
    float current = [rawData extractLeInt16FromOffset:offset+4];
    uint8_t status = [rawData extractUInt8FromOffset:offset+6];
    
    
    NSArray *data = [NSArray arrayWithObjects:
                     [NSNumber numberWithFloat:percentage],
                     [NSNumber numberWithFloat:voltage],
                     [NSNumber numberWithFloat:current],
                     [NSNumber numberWithUnsignedChar:status],
                     nil];
    
    W2STSDKFeatureSample *sample = [W2STSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    self.lastSample = sample;
    [self notifyUpdateWithSample:sample];
    [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 7)]
                    sample:sample];
    
    return 7;
}

@end


#import "../W2STSDKFeature+fake.h"

@implementation W2STSDKFeatureBattery (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:7];
    
    int16_t temp = rand()%1000;
    [data appendBytes:&temp length:2];
    
    temp = rand()%10000;
    [data appendBytes:&temp length:2];
    
    temp = rand()%10;
    [data appendBytes:&temp length:2];
    
    uint8_t state= rand()%4;
    [data appendBytes:&state length:1];
    return data;
}

@end


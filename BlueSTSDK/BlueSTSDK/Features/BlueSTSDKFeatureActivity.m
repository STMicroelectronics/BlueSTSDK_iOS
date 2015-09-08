//
//  BlueSTSDKTemperature.m
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureActivity.h"
#import "BlueSTSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"Activity"
#define FEATURE_UNIT @""
#define FEATURE_MIN 0
#define FEATURE_MAX 6
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeUInt8

/**
 * @memberof BlueSTSDKFeatureActivity
 *  array with the description of field exported by the feature
 */
static NSArray *sFieldDesc;

@implementation BlueSTSDKFeatureActivity

+(void)initialize{
    if(self == [BlueSTSDKFeatureActivity class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [BlueSTSDKFeatureField  createWithName: FEATURE_NAME
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      [BlueSTSDKFeatureField  createWithName: @"Date"
                                                      unit: @"s" //second
                                                      type:BlueSTSDKFeatureFieldTypeDouble
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      nil];
    }
    
}

+(BlueSTSDKFeatureActivityType)getActivityType:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count>0){
        uint8_t value = [(NSNumber*)[sample.data objectAtIndex:0] unsignedCharValue];
        if(value >= FEATURE_MIN && value<=FEATURE_MAX)
            return value;
        //else -> invalid enum value
        return BlueSTSDKFeatureActivityTypeError;
    }
    return BlueSTSDKFeatureActivityTypeError;
}

+(NSDate*)getActivityDate:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count>1){
        NSTimeInterval time = [(NSNumber*)[sample.data objectAtIndex:0] doubleValue];
        return [NSDate dateWithTimeIntervalSinceReferenceDate:time];
    }
    return nil;
}

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  read int8 for build the activity value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no byte available in the rawdata array
 *  @return number of read bytes
 */
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 1){
        @throw [NSException
                exceptionWithName:@"Invalid Activity data"
                reason:@"The feature need almost 1 byte for extract the data"
                userInfo:nil];
    }//if
    
    uint8_t activityId= [rawData extractUInt8FromOffset:offset];
    
    NSArray *data = [NSArray arrayWithObjects:
                        [NSNumber numberWithUnsignedChar:activityId],
                        [NSNumber numberWithDouble:[NSDate timeIntervalSinceReferenceDate]],
                     nil];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    
    self.lastSample = sample;
    [self notifyUpdateWithSample:sample];
    [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 1)]
                    sample:sample];
    
   return 1;
}

@end

#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureActivity (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:1];
    
    uint8_t temp = FEATURE_MIN + rand()%((FEATURE_MAX-FEATURE_MIN+1));
    [data appendBytes:&temp length:1];
    
    return data;
}

@end

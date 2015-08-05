//
//  W2STSDKFeatureAcceleration.m
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//
#include <math.h>

#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureAcceleration.h"
#import "W2STSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"Acceleration"
#define FEATURE_UNIT @"mg"
#define FEATURE_MIN -2000
#define FEATURE_MAX 2000
#define FEATURE_TYPE W2STSDKFeatureFieldTypeFloat

/**
 * @memberof W2STSDKFeatureAcceleration
 *  array with the description of field exported by the feature
 */
NSArray *sFieldDesc;

@implementation W2STSDKFeatureAcceleration

/**
 *  build the data description statically for all the feature of type W2STSDKFeatureAcceleration
 */
+(void)initialize{
    if(self == [W2STSDKFeatureAcceleration class]){
        sFieldDesc = [NSArray arrayWithObjects:
                      [W2STSDKFeatureField  createWithName: @"X"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"Y"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"Z"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      nil];
    }//if
}//initialize


+(float)getAccX:(W2STSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}//getAccX

+(float)getAccY:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<1)
        return NAN;
    return[[sample.data objectAtIndex:1] floatValue];
}//getAccY

+(float)getAccZ:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<2)
        return NAN;
    return[[sample.data objectAtIndex:2] floatValue];
}//getAccZ

/**
 *  implement the abstract feature method, just build a feature with the right name
 *
 *  @param node node that will export this feature
 *
 *  @return build feature of type acceleration
 */
-(instancetype) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}//initWhitNode

/**
 *  return the field descriptor for this feature
 *
 *  @return the field descriptor for this feature
 */
-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}//getFieldsDesc

/**
 *  read 3*int16 for build the accelerometer value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *  
 *  @throw exception if there are no 6 bytes available in the rawdata array
 *  @return number of read bytes
 */
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 6){
        @throw [NSException
                exceptionWithName:@"Invalid Acceleration data"
                reason:@"The feature need 6 byte for extract the data"
                userInfo:nil];
    }//if
    
    
    int16_t accX,accY,accZ;
    accX= [rawData extractLeInt16FromOffset:offset];
    accY= [rawData extractLeInt16FromOffset:offset+2];
    accZ= [rawData extractLeInt16FromOffset:offset+4];
    
    NSArray *newData = [NSArray arrayWithObjects:[NSNumber numberWithFloat:accX],
                        [NSNumber numberWithFloat:accY],
                        [NSNumber numberWithFloat:accZ],
                        nil];
    
    W2STSDKFeatureSample *sample = [W2STSDKFeatureSample sampleWithTimestamp:timestamp data:newData];
    
    self.lastSample = sample;
    
    [self notifyUpdateWithSample:sample];
    
    [self logFeatureUpdate: [rawData subdataWithRange:NSMakeRange(offset, 6)]
                    sample:sample];
    
    return 6;
}//update

@end

#import "../W2STSDKFeature+fake.h"

@implementation W2STSDKFeatureAcceleration (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:6];
    
    int16_t temp = FEATURE_MIN + rand()%(FEATURE_MAX-FEATURE_MIN);
    [data appendBytes:&temp length:2];
    
    temp = FEATURE_MIN + rand()%(FEATURE_MAX-FEATURE_MIN);
    [data appendBytes:&temp length:2];
    
    temp = FEATURE_MIN + rand()%(FEATURE_MAX-FEATURE_MIN);
    [data appendBytes:&temp length:2];
    
    return data;
}//generateFakeData

@end


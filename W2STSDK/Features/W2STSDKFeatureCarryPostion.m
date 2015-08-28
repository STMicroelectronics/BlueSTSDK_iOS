//
//  W2STSDKTemperature.m
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureCarryPosition.h"
#import "W2STSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"Carry Position"
#define FEATURE_UNIT @""
#define FEATURE_MIN 0
#define FEATURE_MAX 6
#define FEATURE_TYPE W2STSDKFeatureFieldTypeUInt8

/**
 * @memberof W2STSDKFeatureCarryPosition
 *  array with the description of field exported by the feature
 */
static NSArray *sFieldDesc;

@implementation W2STSDKFeatureCarryPosition

+(void)initialize{
    if(self == [W2STSDKFeatureCarryPosition class]){
        sFieldDesc = [NSArray arrayWithObject:
                      [W2STSDKFeatureField  createWithName: FEATURE_NAME
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ]];
    }
    
}

+(W2STSDKFeatureCarryPositionType)getPositionType:(W2STSDKFeatureSample*)sample{
    if(sample.data.count>0){
        uint8_t value = [(NSNumber*)[sample.data objectAtIndex:0] unsignedCharValue];
        if(value >= FEATURE_MIN && value<=FEATURE_MAX)
            return value;
        //else -> invalid enum value
            return W2STSDKFeatureCarryPositionError;
    }//if
    return W2STSDKFeatureCarryPositionError;
}//getPositionType


-(instancetype) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  read int8 for build the position value, create the new sample and
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
    
    uint8_t positionId= [rawData extractUInt8FromOffset:offset];
    
    NSArray *data = [NSArray arrayWithObject:
                        [NSNumber numberWithUnsignedChar:positionId]];
    
    W2STSDKFeatureSample *sample = [W2STSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    
    self.lastSample = sample;
    [self notifyUpdateWithSample:sample];
    [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 1)]
                    sample:sample];
    
   return 1;
}

@end

#import "../W2STSDKFeature+fake.h"

@implementation W2STSDKFeatureCarryPosition (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:1];
    
    uint8_t temp = FEATURE_MIN + rand()%((FEATURE_MAX-FEATURE_MIN+1));
    [data appendBytes:&temp length:1];
    
    return data;
}

@end

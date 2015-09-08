//
//  BlueSTSDKTemperature.m
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureFreeFall.h"
#import "BlueSTSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"FreeFall"
#define FEATURE_UNIT @""
#define FEATURE_MIN 0
#define FEATURE_MAX 1
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeUInt8

/**
 * @memberof BlueSTSDKFeatureFreeFall
 *  array with the description of field exported by the feature
 */
static NSArray *sFieldDesc;

@implementation BlueSTSDKFeatureFreeFall

+(void)initialize{
    if(self == [BlueSTSDKFeatureFreeFall class]){
        sFieldDesc = [NSArray arrayWithObject:
                      [BlueSTSDKFeatureField  createWithName: FEATURE_NAME
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ]];
    }
    
}

+(bool)getFreeFallStatus:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count>0)
        return [(NSNumber*)[sample.data objectAtIndex:0] unsignedCharValue]!=0;
    return false;
}

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  read int8 for build the free fall value,if the value is different from 0 a 
 * free fall event was detected by the node.
 * create the new sample and and notify it to the delegate
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
    
    uint8_t statusId= [rawData extractUInt8FromOffset:offset];
    
    NSArray *data = [NSArray arrayWithObject:
                        [NSNumber numberWithUnsignedChar:statusId]];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample
                                    sampleWithTimestamp:timestamp data:data ];
    
    self.lastSample = sample;
    [self notifyUpdateWithSample:sample];
    [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 1)]
                    sample:sample];
    
   return 1;
}

@end

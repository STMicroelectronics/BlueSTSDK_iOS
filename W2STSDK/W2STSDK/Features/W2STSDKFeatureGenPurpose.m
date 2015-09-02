//
//  W2STSDKFeatureGenPurpose.m
//  W2STSDK
//
//  Created by Giovanni Visentini on 25/05/15.
//  Copyright (c) 2015 STCentralLab. All rights reserved.
//

#import <CoreBluetooth/CBUUID.h>

#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureGenPurpose.h"

#import "W2STSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"General Purpose"
#define FEATURE_UNIT @"RawData"
#define FEATURE_MIN 0
#define FEATURE_MAX 255
#define FEATURE_TYPE W2STSDKFeatureFieldTypeUInt8

/**
 * @memberof W2STSDKFeatureGenPurpose
 *  array with the description of field exported by the feature
 */
static NSArray *sFieldDesc;

@implementation W2STSDKFeatureGenPurpose
    
+(void)initialize{
    if(self == [W2STSDKFeatureGenPurpose class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [W2STSDKFeatureField  createWithName: FEATURE_NAME
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      nil];
    }//if
}//initialize

+(NSData*) getRawData:(W2STSDKFeatureSample*)sample{
    NSMutableData *rawData = [NSMutableData dataWithCapacity:sample.data.count];
    
    for( NSNumber *n in sample.data){
        uint8_t temp = [n unsignedCharValue];
        [rawData appendBytes:&temp length:1];
    }//for
    return rawData;
}

-(instancetype)initWhitNode:(W2STSDKNode *)node characteristics:(CBCharacteristic*)c{
    NSString *name = [NSString stringWithFormat:@"GenPurpose_%@",c.UUID.UUIDString];

    self = [super initWhitNode:node name:name];
    _characteristics=c;
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  read all the available byte and generate the sample and notify to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @return number of read bytes
 */
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{

    NSMutableArray *tempData = [NSMutableArray arrayWithCapacity:rawData.length-offset];
    
    for(uint32_t i=offset ; i< rawData.length ; i++){
        uint8_t temp = [rawData extractUInt8FromOffset:i];
        [tempData addObject: [NSNumber numberWithUnsignedChar:temp]];
    }//for
    
    W2STSDKFeatureSample *sample =
        [W2STSDKFeatureSample sampleWithTimestamp:timestamp data:tempData];
    
    self.lastSample = sample;
    
    [self notifyUpdateWithSample:sample];
    [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, rawData.length-offset)]
                 sample:sample];

    return (uint32_t)(rawData.length-offset);
}


-(NSString*) description{
    NSMutableString *s = [NSMutableString stringWithString:@"Ts:"];
    W2STSDKFeatureSample *sample = self.lastSample;
    [s appendFormat:@"%d ",sample.timestamp];
    NSArray *datas = sample.data;
    [s appendString:@"Data: "];
    for (NSNumber *n in datas) {
       [s appendFormat:@" %X ",[n unsignedCharValue]];
    }//for
    return s;
}

@end



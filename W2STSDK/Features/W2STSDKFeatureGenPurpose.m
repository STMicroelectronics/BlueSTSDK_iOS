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

static NSArray *sFieldDesc;

@implementation W2STSDKFeatureGenPurpose{
    NSMutableArray *mFieldData;
    uint32_t mTimestamp;
    dispatch_queue_t mRwQueue;
}

+(void)initialize{
    if(self == [W2STSDKFeatureGenPurpose class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [W2STSDKFeatureField  createWithName: FEATURE_NAME
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      nil];
    }
    
}

+(NSData*) getRawData:(NSArray*)data{
    NSMutableData *rawData = [NSMutableData dataWithCapacity:data.count];
    
    for( NSNumber *n in data){
        uint8_t temp = [n unsignedCharValue];
        [rawData appendBytes:&temp length:1];
//        [rawData appendBytes:&temp length:1];
    }//for
    return rawData;
}

-(id)initWhitNode:(W2STSDKNode *)node characteristics:(CBCharacteristic*)c{
    NSString *name = [NSString stringWithFormat:@"GenPurpose: %@",c.UUID.UUIDString];
    mRwQueue = dispatch_queue_create("W2STSDKFeatureMag", DISPATCH_QUEUE_CONCURRENT);
    self = [super initWhitNode:node name:name];
    _characteristics=c;
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

    NSMutableArray *tempData = [NSMutableArray arrayWithCapacity:rawData.length-offset];
    
    for(uint32_t i=offset ; i< rawData.length ; i++){
        uint8_t temp = [rawData extractUInt8FromOffset:i];
        [tempData addObject: [NSNumber numberWithUnsignedChar:temp]];
    }//for
    
    dispatch_barrier_async(mRwQueue, ^(){
        mTimestamp = timestamp;
        mFieldData = tempData;
        
        [self notifyUpdate];
        [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, rawData.length-offset)]
                          data:[mFieldData copy]];
    });
    return (uint32_t)(rawData.length-offset);
}


-(NSString*) description{
    NSMutableString *s = [NSMutableString stringWithString:@"Ts:"];
    [s appendFormat:@"%d ",[self getTimestamp] ];
    NSArray *datas = [self getFieldsData ];
    [s appendString:@"Data: "];
    for (NSNumber *n in datas) {
       [s appendFormat:@" %X ",[n unsignedCharValue]];
    }//for
    return s;
}

@end



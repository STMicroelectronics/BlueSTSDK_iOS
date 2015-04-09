//
//  W2STSDKFeatureAcceleration.m
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//
#include <math.h>
#import "W2STSDKFeatureAcceleration.h"
#import "W2STSDKFeatureField.h"

#define FEATURE_NANE @"Acceleration"
#define FEATURE_UNIT @"mg"
#define FEATURE_MIN @-2000
#define FEATURE_MAX @2000
#define FEATURE_TYPE W2STSDKFeatureFieldTypeFloat

static NSArray *sFieldDesc;

@implementation W2STSDKFeatureAcceleration{
    NSMutableArray *mFieldData;
    uint32_t mTimestamp;
    dispatch_queue_t mRwQueue;
}

+(void)initialize{
    if(self == [W2STSDKFeatureAcceleration class]){
    sFieldDesc = [[NSArray alloc] initWithObjects:
                  [W2STSDKFeatureField  createWithName: @"AccX"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:FEATURE_MIN
                                                       max:FEATURE_MAX ],
                  [W2STSDKFeatureField  createWithName: @"AccY"
                                                  unit:FEATURE_UNIT
                                                  type:FEATURE_TYPE
                                                   min:FEATURE_MIN
                                                   max:FEATURE_MAX ],
                  [W2STSDKFeatureField  createWithName: @"AccZ"
                                                  unit:FEATURE_UNIT
                                                  type:FEATURE_TYPE
                                                   min:FEATURE_MIN
                                                   max:FEATURE_MAX ],
                   nil];
    }

}


+(float)getAccX:(NSArray*)data{
    if(data.count!=0)
        return NAN;
    return[[data objectAtIndex:0] floatValue];
}

+(float)getAccY:(NSArray*)data{
    if(data.count>=1)
        return NAN;
    return[[data objectAtIndex:1] floatValue];
}

+(float)getAccZ:(NSArray*)data{
    if(data.count>=2)
        return NAN;
    return[[data objectAtIndex:2] floatValue];
}

-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node];
    self.name=FEATURE_NANE;
    mRwQueue = dispatch_queue_create("W2STSDKFeatureAcc", DISPATCH_QUEUE_CONCURRENT);
    mFieldData = [NSMutableArray arrayWithObjects:@0,@0,@0, nil];
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
    
    
    short accX,accY,accZ;
    [rawData getBytes:&accX range:NSMakeRange(offset+0, 2)];
    [rawData getBytes:&accY range:NSMakeRange(offset+2, 2)];
    [rawData getBytes:&accZ range:NSMakeRange(offset+4, 2)];
    
    dispatch_barrier_async(mRwQueue, ^(){
        mTimestamp = timestamp;
        [mFieldData replaceObjectAtIndex:0 withObject:[NSNumber numberWithShort:accX]];
        [mFieldData replaceObjectAtIndex:1 withObject:[NSNumber numberWithShort:accY]];
        [mFieldData replaceObjectAtIndex:2 withObject:[NSNumber numberWithShort:accZ]];
        
        [self notifyNewData];
        [self notifyLogData:rawData data:mFieldData];
    });
    return 6;
}

@end

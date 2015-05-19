//
//  W2STSDKFeatureMemsSensorFusionCompact.m
//  W2STApp
//
//  Created by Giovanni Visentini on 13/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "../Util/NSData+NumberConversion.h"

#import "W2STSDKFeatureMemsSensorFusionCompact.h"
#import "W2STSDKFeatureField.h"

//#define FEATURE_NAME @"MemsSensorFusion (Compact)"
#define FEATURE_NAME @"MemsSensorFusionCompact"
#define FEATURE_UNIT @""
#define FEATURE_MIN @-1.0f
#define FEATURE_MAX @1.0
#define FEATURE_TYPE W2STSDKFeatureFieldTypeFloat

#define QUATERNION_DELAY_MS 30
#define SCALE_FACTOR 10000.0f

static NSArray *sFieldDesc;

@implementation W2STSDKFeatureMemsSensorFusionCompact{
    NSMutableArray *mFieldData;
    uint32_t mTimestamp;
    dispatch_queue_t mRwQueue;
    dispatch_queue_t mNotificationQueue;
}

+(void)initialize{
    if(self == [W2STSDKFeatureMemsSensorFusionCompact class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [W2STSDKFeatureField  createWithName: @"x"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:FEATURE_MIN
                                                       max:FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"y"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:FEATURE_MIN
                                                       max:FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"z"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:FEATURE_MIN
                                                       max:FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"w"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:FEATURE_MIN
                                                       max:FEATURE_MAX ],
                      
                      nil];
    }
    
}


-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    mNotificationQueue = dispatch_queue_create("W2STSDKFeatureMemsSensorFusionCompactNotification",
                                               DISPATCH_QUEUE_CONCURRENT);
    mRwQueue = dispatch_queue_create("W2STSDKFeatureMemsSensorFusionCompactNotificationRwQueue",
                                     DISPATCH_QUEUE_CONCURRENT);
    mFieldData = [NSMutableArray arrayWithObjects:@0,@0,@0,@0, nil];
    mTimestamp=0;

    return self;
}

+(float)getX:(NSArray*)data{
    if(data.count==0)
    return NAN;
    return[[data objectAtIndex:0] floatValue];
}

+(float)getY:(NSArray*)data{
    if(data.count<1)
    return NAN;
    return[[data objectAtIndex:1] floatValue];
}

+(float)getZ:(NSArray*)data{
    if(data.count<2)
    return NAN;
    return[[data objectAtIndex:2] floatValue];
}

+(float)getW:(NSArray*)data{
    if(data.count<3)
    return NAN;
    return[[data objectAtIndex:3] floatValue];
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

    const uint32_t nQuat = (((uint32_t)rawData.length)-offset)/6;
    const int64_t quatDelay = QUATERNION_DELAY_MS/nQuat;
    
    float x,y,z,w;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0);
    for (uint32_t i=0; i<nQuat; i++) {
        x= [rawData extractLeInt16FromOffset:offset+0]/SCALE_FACTOR;
        y= [rawData extractLeInt16FromOffset:offset+2]/SCALE_FACTOR;
        z= [rawData extractLeInt16FromOffset:offset+4]/SCALE_FACTOR;
        w = sqrt(1-(x*x+y*y+z*z));

        dispatch_after(startTime, mNotificationQueue, ^{
            dispatch_barrier_async(mRwQueue, ^(){
                mTimestamp = timestamp;
                [mFieldData replaceObjectAtIndex:0 withObject:[NSNumber numberWithFloat:x]];
                [mFieldData replaceObjectAtIndex:1 withObject:[NSNumber numberWithFloat:y]];
                [mFieldData replaceObjectAtIndex:2 withObject:[NSNumber numberWithFloat:z]];
                [mFieldData replaceObjectAtIndex:3 withObject:[NSNumber numberWithFloat:w]];
                [self notifyUpdate];
                [self logFeatureUpdate: [rawData subdataWithRange:NSMakeRange(offset, 6)] data:[mFieldData copy]];
            });

        });
        offset += 6;
        startTime = dispatch_time(startTime,quatDelay);
    }//for
    return 6*nQuat;
}

@end

//
//  W2STSTSDKFeatureMagnetometer.m
//  W2STApp
//
//  Created by Giovanni Visentini on 02/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#include <math.h>
#import "W2STSTSDKFeatureMagnetometer.h"
#import "W2STSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"


#define FEATURE_NAME @"Magnetometer"
#define FEATURE_UNIT @"mGa"
#define FEATURE_MIN @-2000
#define FEATURE_MAX @2000
#define FEATURE_TYPE W2STSDKFeatureFieldTypeFloat

static NSArray *sFieldDesc;

@implementation W2STSTSDKFeatureMagnetometer{
    NSMutableArray *mFieldData;
    uint32_t mTimestamp;
    dispatch_queue_t mRwQueue;
}

+(void)initialize{
    if(self == [W2STSTSDKFeatureMagnetometer class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [W2STSDKFeatureField  createWithName: @"MagX"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:FEATURE_MIN
                                                       max:FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"MagY"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:FEATURE_MIN
                                                       max:FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"MagZ"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:FEATURE_MIN
                                                       max:FEATURE_MAX ],
                      nil];
    }
    
}


+(float)getMagX:(NSArray*)data{
    if(data.count!=0)
        return NAN;
    return[[data objectAtIndex:0] floatValue];
}

+(float)getMagY:(NSArray*)data{
    if(data.count>=1)
        return NAN;
    return[[data objectAtIndex:1] floatValue];
}

+(float)getMagZ:(NSArray*)data{
    if(data.count>=2)
        return NAN;
    return[[data objectAtIndex:2] floatValue];
}

-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    mRwQueue = dispatch_queue_create("W2STSDKFeatureMag", DISPATCH_QUEUE_CONCURRENT);
    mFieldData = [NSMutableArray arrayWithObjects:@0,@0,@0,nil];
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
    
    
    short magX,magY,magZ;
    magX= [rawData extractLeUInt16FromOffset:offset];
    magY= [rawData extractLeUInt16FromOffset:offset+2];
    magZ= [rawData extractLeUInt16FromOffset:offset+4];
    
    dispatch_barrier_async(mRwQueue, ^(){
        mTimestamp = timestamp;
        [mFieldData replaceObjectAtIndex:0 withObject:[NSNumber numberWithShort:magX]];
        [mFieldData replaceObjectAtIndex:1 withObject:[NSNumber numberWithShort:magY]];
        [mFieldData replaceObjectAtIndex:2 withObject:[NSNumber numberWithShort:magZ]];
        
        [self notifyUpdate];
        [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 6)] data:[mFieldData copy]];
    });
    return 6;
}

@end

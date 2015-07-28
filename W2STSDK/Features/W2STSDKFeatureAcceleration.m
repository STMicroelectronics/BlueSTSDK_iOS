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

static NSArray *sFieldDesc;

@implementation W2STSDKFeatureAcceleration

+(void)initialize{
    if(self == [W2STSDKFeatureAcceleration class]){
    sFieldDesc = [[NSArray alloc] initWithObjects:
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
    }

}


+(float)getAccX:(W2STSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}

+(float)getAccY:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<1)
        return NAN;
    return[[sample.data objectAtIndex:1] floatValue];
}

+(float)getAccZ:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<2)
        return NAN;
    return[[sample.data objectAtIndex:2] floatValue];
}

-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}


-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    
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
}

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
}

@end


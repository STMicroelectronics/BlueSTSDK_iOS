//
//  W2STSDKFeatureLuminosity.m
//  W2STApp
//
//  Created by Giovanni Visentini on 28/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureLuminosity.h"

#import "W2STSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"Luminosity"
#define FEATURE_UNIT @"Lux"
#define FEATURE_MIN 0
#define FEATURE_MAX 1000
#define FEATURE_TYPE W2STSDKFeatureFieldTypeUInt16

static NSArray *sFieldDesc;

@implementation W2STSDKFeatureLuminosity

+(void)initialize{
    if(self == [W2STSDKFeatureLuminosity class]){
        sFieldDesc = [NSArray arrayWithObjects:
                      [W2STSDKFeatureField  createWithName:FEATURE_NAME
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                     nil];
    }//if
    
}


+(uint16_t)getLuminosity:(W2STSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] intValue];
}

-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}

-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    
    uint16_t lux = [rawData extractLeUInt16FromOffset:offset];
    
    
    NSArray *data = [NSArray arrayWithObject:[NSNumber numberWithFloat:lux]];
    W2STSDKFeatureSample *sample = [W2STSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    self.lastSample = sample;
    [self notifyUpdateWithSample:sample];
    [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 2)]
                    sample:sample];

    return 2;
}

@end

#import "../W2STSDKFeature+fake.h"

@implementation W2STSDKFeatureLuminosity (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:2];
    
    uint16_t temp = FEATURE_MIN + rand()%((FEATURE_MAX-FEATURE_MIN));
    [data appendBytes:&temp length:2];
    
    return data;
}

@end

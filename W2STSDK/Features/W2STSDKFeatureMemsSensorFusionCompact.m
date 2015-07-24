//
//  W2STSDKFeatureMemsSensorFusionCompact.m
//  W2STApp
//
//  Created by Giovanni Visentini on 13/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "../Util/NSData+NumberConversion.h"
#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureMemsSensorFusionCompact.h"
#import "W2STSDKFeatureField.h"

//#define FEATURE_NAME @"MemsSensorFusion (Compact)"
#define FEATURE_NAME @"MemsSensorFusionCompact"
#define FEATURE_UNIT @""
#define FEATURE_MIN -1.0f
#define FEATURE_MAX 1.0
#define FEATURE_TYPE W2STSDKFeatureFieldTypeFloat


//since we receve a 3 quaternion at times, we notify to the user a new quaternion
// each 30ms
#define QUATERNION_DELAY_MS 30
#define SCALE_FACTOR 10000.0f

static NSArray *sFieldDesc;

@interface W2STSDKFeatureMemsSensorFusionCompact()
    @property (atomic) NSArray *mFieldData;
    @property (atomic) uint32_t mTimestamp;
@end

@implementation W2STSDKFeatureMemsSensorFusionCompact{
    dispatch_queue_t mNotificationQueue;
}

+(void)initialize{
    if(self == [W2STSDKFeatureMemsSensorFusionCompact class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [W2STSDKFeatureField  createWithName: @"qi"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"qj"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"qk"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"qs"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      
                      nil];
    }
    
}


-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    mNotificationQueue = dispatch_queue_create("W2STSDKFeatureMemsSensorFusionCompactNotification",
                                               DISPATCH_QUEUE_SERIAL);
    _mTimestamp=0;
    _mFieldData=nil;
    return self;
}

+(float)getQi:(NSArray*)data{
    if(data.count==0)
    return NAN;
    return[[data objectAtIndex:0] floatValue];
}

+(float)getQj:(NSArray*)data{
    if(data.count<1)
    return NAN;
    return[[data objectAtIndex:1] floatValue];
}

+(float)getQk:(NSArray*)data{
    if(data.count<2)
    return NAN;
    return[[data objectAtIndex:2] floatValue];
}

+(float)getQs:(NSArray*)data{
    if(data.count<3)
    return NAN;
    return[[data objectAtIndex:3] floatValue];
}


-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}

-(NSArray*) getFieldsData{
    return self.mFieldData;
}

-(uint32_t) getTimestamp{
    return self.mTimestamp;
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
        
        NSArray *newData = [NSArray arrayWithObjects:[NSNumber numberWithFloat:x],
                            [NSNumber numberWithFloat:y],
                            [NSNumber numberWithFloat:z],
                            [NSNumber numberWithFloat:w],
                            nil];
        
        //since we recevive 3 quaternions at times, we delay the feature update
        // -> we put the task that do that in a serial queue
        dispatch_after(startTime, mNotificationQueue, ^{
                self.mTimestamp = timestamp;
                self.mFieldData = newData;
                [self notifyUpdate];
                [self logFeatureUpdate: [rawData subdataWithRange:NSMakeRange(offset, 6)] data:[newData copy]];
        });
        offset += 6;
        startTime = dispatch_time(startTime,quatDelay);
    }//for
    return 6*nQuat;
}

@end

#import "../W2STSDKFeature+fake.h"

#define N_DECIMAL 100
@implementation W2STSDKFeatureMemsSensorFusionCompact (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:18];
    
    for(int i=0 ; i< 3 ; i++){
    
        float x = FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
        float y= FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
        float z = FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
        float w = FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
        const float norm = sqrtf(x*x+y*y+z*z+w*w);
    
        x/=norm;
        y/=norm;
        z/=norm;
    
        int16_t xFix = (int16_t)(x*SCALE_FACTOR);
        int16_t yFix = (int16_t)(y*SCALE_FACTOR);
        int16_t zFix = (int16_t)(z*SCALE_FACTOR);

        [data appendBytes:&xFix length:2];
        [data appendBytes:&yFix length:2];
        [data appendBytes:&zFix length:2];
    }
    return data;
}
@end
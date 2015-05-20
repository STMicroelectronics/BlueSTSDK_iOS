//
//  W2STSDKFeatureQuaternion.m
//  W2STApp
//
//  Created by Giovanni Visentini on 10/04/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKFeature_prv.h"
#import "W2STSDKFeatureMemsSensorFusion.h"
#import "W2STSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"MemsSensorFusion"
#define FEATURE_UNIT @""
#define FEATURE_MIN -1.0f
#define FEATURE_MAX 1.0
#define FEATURE_TYPE W2STSDKFeatureFieldTypeFloat

static NSArray *sFieldDesc;

@implementation W2STSDKFeatureMemsSensorFusion{
    NSMutableArray *mFieldData;
    uint32_t mTimestamp;
    dispatch_queue_t mRwQueue;
}

+(void)initialize{
    if(self == [W2STSDKFeatureMemsSensorFusion class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [W2STSDKFeatureField  createWithName: @"x"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"y"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"z"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      [W2STSDKFeatureField  createWithName: @"w"
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      
                      nil];
    }
    
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

-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    mRwQueue = dispatch_queue_create("FeatureMemsSensorFusion", DISPATCH_QUEUE_CONCURRENT);
    mFieldData = [NSMutableArray arrayWithObjects:@0,@0,@0,@0, nil];
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
    
    
    float x,y,z,w;
    x= [rawData extractLeFloatFromOffset:offset];
    y= [rawData extractLeFloatFromOffset:offset+4];
    z= [rawData extractLeFloatFromOffset:offset+8];
    
    if((rawData.length-offset) > 12)
        w= [rawData extractLeFloatFromOffset:offset+12];
    else
        w = sqrt(1-(x*x+y*y+z*z));
    
    dispatch_barrier_async(mRwQueue, ^(){
        mTimestamp = timestamp;
        [mFieldData replaceObjectAtIndex:0 withObject:[NSNumber numberWithFloat:x]];
        [mFieldData replaceObjectAtIndex:1 withObject:[NSNumber numberWithFloat:y]];
        [mFieldData replaceObjectAtIndex:2 withObject:[NSNumber numberWithFloat:z]];
        [mFieldData replaceObjectAtIndex:3 withObject:[NSNumber numberWithFloat:w]];
        [self notifyUpdate];
        [self logFeatureUpdate:[rawData subdataWithRange:NSMakeRange(offset, 6)] data:[mFieldData copy]];
    });
    return 6;
}

@end


#import "../W2STSDKFeature+fake.h"

#define N_DECIMAL 100
@implementation W2STSDKFeatureMemsSensorFusion (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:12];
    
    float x = FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
    float y= FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
    float z = FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));

    float w = FEATURE_MIN*N_DECIMAL + rand()%((int)((FEATURE_MAX-FEATURE_MIN)*N_DECIMAL));
    
    const float norm = sqrtf(x*x+y*y+z*z+w*w);
    
    x/=norm;
    y/=norm;
    z/=norm;
    w/=norm;
    
    [data appendBytes:&x length:4];
    [data appendBytes:&y length:4];
    [data appendBytes:&z length:4];
    [data appendBytes:&w length:4];
    return data;
}

@end

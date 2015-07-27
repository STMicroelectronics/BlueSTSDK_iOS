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

@interface W2STSDKFeatureMemsSensorFusion()
    @property (atomic) NSArray *mFieldData;
    @property (atomic) uint32_t mTimestamp;
@end

@implementation W2STSDKFeatureMemsSensorFusion

+(void)initialize{
    if(self == [W2STSDKFeatureMemsSensorFusion class]){
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

-(id) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
   
    _mFieldData = nil;
    _mTimestamp = 0;
    return self;
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
    
    
    float x,y,z,w;
    x= [rawData extractLeFloatFromOffset:offset];
    y= [rawData extractLeFloatFromOffset:offset+4];
    z= [rawData extractLeFloatFromOffset:offset+8];
    
    if((rawData.length-offset) > 12)
        w= [rawData extractLeFloatFromOffset:offset+12];
    else
        w = sqrt(1-(x*x+y*y+z*z));
    
    NSArray *newData = [NSArray arrayWithObjects:[NSNumber numberWithFloat:x],
                        [NSNumber numberWithFloat:y],
                        [NSNumber numberWithFloat:z],
                        [NSNumber numberWithFloat:w],
                        nil];
    self.mTimestamp = timestamp;
    self.mFieldData = newData;
    [self notifyUpdate];
    [self logFeatureUpdate: [rawData subdataWithRange:NSMakeRange(offset, 6)]
                      timestamp:timestamp data:newData];
    
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

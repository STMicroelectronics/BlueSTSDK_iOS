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

/**
 * @memberof W2STSDKFeatureMemsSensorFusion
 *  array with the description of field exported by the feature
 */
static NSArray *sFieldDesc;

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
    }//if
}//initialize


+(float)getQi:(W2STSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}//getQi

+(float)getQj:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<1)
        return NAN;
    return[[sample.data objectAtIndex:1] floatValue];
}

+(float)getQk:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<2)
        return NAN;
    return[[sample.data objectAtIndex:2] floatValue];
}

+(float)getQs:(W2STSDKFeatureSample*)sample{
    if(sample.data.count<3)
        return NAN;
    return[[sample.data objectAtIndex:3] floatValue];
}

-(instancetype) initWhitNode:(W2STSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray*) getFieldsDesc{
    return sFieldDesc;
}

/**
 *  read 3 or 4 float for build the quaternion value, create the new sample and
 * and notify it to the delegate.
 * it the scalar component is not present we assume that the other are normalized
 * and we compute it
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no almost 12 bytes available in the rawdata array
 *  @return number of read bytes
 */
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 12){
        @throw [NSException
                exceptionWithName:@"Invalid SensorFunsion data"
                reason:@"The feature need almost 12 byte for extract the data"
                userInfo:nil];
    }//if
    
    float x,y,z,w;
    x= [rawData extractLeFloatFromOffset:offset];
    y= [rawData extractLeFloatFromOffset:offset+4];
    z= [rawData extractLeFloatFromOffset:offset+8];
    
    uint8_t readbyte =12;
    
    if((rawData.length-offset) > 12){
        w= [rawData extractLeFloatFromOffset:offset+12];
        readbyte=16;
        
        //normalize the quaternion
        const float norm = sqrtf(x*x+y*y+z*z+w*w);
        x/=norm;
        y/=norm;
        z/=norm;
        w/=norm;
        
    }else
        w = sqrt(1-(x*x+y*y+z*z));
        
    NSArray *newData = [NSArray arrayWithObjects:[NSNumber numberWithFloat:x],
                        [NSNumber numberWithFloat:y],
                        [NSNumber numberWithFloat:z],
                        [NSNumber numberWithFloat:w],
                        nil];
    
    W2STSDKFeatureSample *sample = [W2STSDKFeatureSample sampleWithTimestamp:timestamp data:newData];
    
    self.lastSample = sample;
    
    [self notifyUpdateWithSample:sample];
    
    [self logFeatureUpdate: [rawData subdataWithRange:NSMakeRange(offset, 6)]
                    sample:sample];
    
    return readbyte;
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

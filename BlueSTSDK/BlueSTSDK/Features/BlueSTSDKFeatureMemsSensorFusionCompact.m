/*******************************************************************************
 * COPYRIGHT(c) 2015 STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *   1. Redistributions of source code must retain the above copyright notice,
 *      this list of conditions and the following disclaimer.
 *   2. Redistributions in binary form must reproduce the above copyright notice,
 *      this list of conditions and the following disclaimer in the documentation
 *      and/or other materials provided with the distribution.
 *   3. Neither the name of STMicroelectronics nor the names of its contributors
 *      may be used to endorse or promote products derived from this software
 *      without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
 * DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
 * FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
 * CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
 * OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
 * OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 *
 ******************************************************************************/

#import "../Util/NSData+NumberConversion.h"
#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureMemsSensorFusionCompact.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"


//#define FEATURE_NAME @"MemsSensorFusion (Compact)"
#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"MEMS Sensor Fusion (Compact)",nil)
#define FEATURE_UNIT @""
#define FEATURE_MIN -1.0f
#define FEATURE_MAX 1.0
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeFloat


//since we receve a 3 quaternion at times, we notify to the user a new quaternion
// each 30ms
#define QUATERNION_DELAY_MS 30
#define SCALE_FACTOR 10000.0f

/**
 * @memberof BlueSTSDKFeatureMemsSensorFusionCompact
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;


@implementation BlueSTSDKFeatureMemsSensorFusionCompact{
    /**
     *  internal queue used for notify in different moment the 3 quaternion that
     * we receive with an update
     */
    dispatch_queue_t mNotificationQueue;
}

+(void)initialize{
    if(self == [BlueSTSDKFeatureMemsSensorFusionCompact class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:@"qi"
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_MAX],
                [BlueSTSDKFeatureField createWithName:@"qj"
                                                 unit:FEATURE_UNIT
                                                 type:FEATURE_TYPE
                                                  min:@FEATURE_MIN
                                                  max:@FEATURE_MAX],
                [BlueSTSDKFeatureField createWithName:@"qk"
                                                 unit:FEATURE_UNIT
                                                 type:FEATURE_TYPE
                                                  min:@FEATURE_MIN
                                                  max:@FEATURE_MAX],
                [BlueSTSDKFeatureField createWithName:@"qs"
                                                 unit:FEATURE_UNIT
                                                 type:FEATURE_TYPE
                                                  min:@FEATURE_MIN
                                                  max:@FEATURE_MAX]];
    }//if
}//initialize


-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    mNotificationQueue = dispatch_queue_create("BlueSTSDKFeatureMemsSensorFusionCompactNotification",
                                               DISPATCH_QUEUE_SERIAL);
    return self;
}

+(float)getQi:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[sample.data[0] floatValue];
}

+(float)getQj:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<1)
        return NAN;
    return[sample.data[1] floatValue];
}

+(float)getQk:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<2)
        return NAN;
    return[sample.data[2] floatValue];
}

+(float)getQs:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<3)
        return NAN;
    return[sample.data[3] floatValue];
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

/**
 * this update will consume all the data and extract a quaternion each 6 byte that
 * are available create the new sample and and notify it to the delegate.
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no almost 6 bytes available in the rawdata array
 *  @return number of read bytes
 */
-(uint32_t) update:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 6){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid SensorFunsionCompact data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 6 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    const uint32_t nQuat = (((uint32_t)rawData.length)-offset)/6;
    const int64_t quatDelay = QUATERNION_DELAY_MS/nQuat;
    
    float x,y,z,w;
    dispatch_time_t startTime = dispatch_time(DISPATCH_TIME_NOW, 0);
    for (uint32_t i=0; i<nQuat; i++) {
        x= [rawData extractLeInt16FromOffset:offset+0]/SCALE_FACTOR;
        y= [rawData extractLeInt16FromOffset:offset+2]/SCALE_FACTOR;
        z= [rawData extractLeInt16FromOffset:offset+4]/SCALE_FACTOR;
        w = sqrt(1-(x*x+y*y+z*z));
        
        NSArray *newData = @[@(x), @(y), @(z), @(w)];
        BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:newData];
        //since we recevive 3 quaternions at times, we delay the feature update
        // -> we put the task that do that in a serial queue
        dispatch_after(startTime, mNotificationQueue, ^{
            self.lastSample = sample;
            
            [self notifyUpdateWithSample:sample];
            
            [self logFeatureUpdate: [rawData subdataWithRange:NSMakeRange(offset, 6)]
                            sample:sample];
        });
        offset += 6;
        startTime = dispatch_time(startTime,quatDelay);
    }//for
    return 6*nQuat;
}

@end

#import "../BlueSTSDKFeature+fake.h"

#define N_DECIMAL 100
@implementation BlueSTSDKFeatureMemsSensorFusionCompact (fake)

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

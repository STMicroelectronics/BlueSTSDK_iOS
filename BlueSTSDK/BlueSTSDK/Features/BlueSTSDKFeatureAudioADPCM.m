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

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureAudioADPCM.h"

#import "../Util/NSData+NumberConversion.h"
#import "BlueSTSDKFeatureAudioADPCMSync.h"

#define FEATURE_NAME @"AudioPCM"

#define FEATURE_UNIT nil
#define FEATURE_MIN INT16_MIN
#define FEATURE_MAX INT16_MAX
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeInt16Array

static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@interface ADPCMEngine :NSObject

+(instancetype)engine;
-(int16_t)decode:(int8_t)code syncManager:(ADPCMAudioSyncManager*)syncManager;

@end

/** Quantizer step size lookup table */
const static int16_t StepSizeTable[]={7,8,9,10,11,12,13,14,16,17,
        19,21,23,25,28,31,34,37,41,45,
        50,55,60,66,73,80,88,97,107,118,
        130,143,157,173,190,209,230,253,279,307,
        337,371,408,449,494,544,598,658,724,796,
        876,963,1060,1166,1282,1411,1552,1707,1878,2066,
        2272,2499,2749,3024,3327,3660,4026,4428,4871,5358,
        5894,6484,7132,7845,8630,9493,10442,11487,12635,13899,
        15289,16818,18500,20350,22385,24623,27086,29794,32767};

/** Table of index changes */
const static int8_t IndexTable[] = {-1,-1,-1,-1,2,4,6,8,-1,-1,-1,-1,2,4,6,8};


@implementation ADPCMEngine{
    int16_t index;
    int32_t predSample;
}
+ (instancetype)engine {
    return [[ADPCMEngine alloc]init];
}

-(instancetype)init{
    self = [super init];
    index=0;
    predSample=0;
    return self;
}

- (int16_t)decode:(int8_t)code syncManager:(ADPCMAudioSyncManager*)syncManager {
    int16_t step;
    int32_t diffq;

    if(syncManager.intra_flag) {
        predSample = syncManager.adpcm_predsample_in;
        index = syncManager.adpcm_index_in;
        syncManager.intra_flag=FALSE;
    }
    step = StepSizeTable[index];

    /* 2. inverse code into diff */
    diffq = step>> 3;
    if ((code&4)!=0)
    {
        diffq += step;
    }

    if ((code&2)!=0)
    {
        diffq += step>>1;
    }

    if ((code&1)!=0)
    {
        diffq += step>>2;
    }

    /* 3. add diff to predicted sample*/
    if ((code&8)!=0)
    {
        predSample -= diffq;
    }
    else
    {
        predSample += diffq;
    }

    /* check for overflow*/
    if (predSample > 32767)
    {
        predSample = 32767;
    }
    else if (predSample < -32768)
    {
        predSample = -32768;
    }

    /* 4. find new quantizer step size */
    index += IndexTable [code];
    /* check for overflow*/
    if (index < 0)
    {
        index = 0;
    }
    if (index > 88)
    {
        index = 88;
    }

    /* 5. save predict sample and index for next iteration */
    /* done! static variables */

    /* 6. return new speech sample*/
    return (short)predSample;
}

@end


@implementation ADPCMAudioSyncManager{

}

+ (instancetype)audioManager {
    return [[ADPCMAudioSyncManager alloc]init];
}

-(instancetype)init {
    self = [super init];
    self.adpcm_index_in=0;
    self.adpcm_predsample_in=0;
    self.intra_flag=false;
    return self;
}

- (void)setSyncParam:(BlueSTSDKFeatureSample *)sample {

    self.adpcm_index_in= [BlueSTSDKFeatureAudioADPCMSync getIndex:sample];
    self.adpcm_predsample_in= [BlueSTSDKFeatureAudioADPCMSync getPredictedSample:sample];

    self.intra_flag=true;
}


@end
@implementation BlueSTSDKFeatureAudioADPCM {

    ADPCMEngine *mDecoder;

}

+(void)initialize {
    if (self == [BlueSTSDKFeatureAudioADPCM class]) {
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_NAME
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_MAX],
        ];
    }

}


-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    _audioManager = [ADPCMAudioSyncManager audioManager];
    mDecoder = [ADPCMEngine engine];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{

    if((rawData.length-offset)!= 20){
        @throw [NSException
                exceptionWithName:@"Invalid Audio ADPCM data"
                           reason:@"The feature need almost 20 byte for extract the data"
                         userInfo:nil];
    }//if

    NSMutableArray<NSNumber *> *data = [NSMutableArray arrayWithCapacity:40];

    const int8_t *pcmData = rawData.bytes;
    for(NSUInteger i=offset;i<offset+20;i++){
        int16_t temp =[mDecoder decode:(int8_t)(pcmData[i]&0x0F) syncManager:self.audioManager];
        data[2*i]= @(temp);
        temp =[mDecoder decode:(int8_t)((pcmData[i]>>4)&0x0F) syncManager:self.audioManager];
        data[2*i+1]= @(temp);
    }

    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample
            sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:20];
}

+ (NSData *)getLinearPCMAudio:(BlueSTSDKFeatureSample *)sample {
    if(sample.data==nil){
        return nil;
    }
    NSArray<NSNumber *> *data = sample.data;
    NSMutableData *outData= [NSMutableData dataWithCapacity:sizeof(int16_t)*data.count];
    for(NSUInteger i=0;i<data.count;i++){
        int16_t temp = [data[i] shortValue];
        [outData appendBytes:&temp length:sizeof(int16_t)];
    }
    return  outData;
}

-(void) notifyUpdateWithSample:(BlueSTSDKFeatureSample *)sample{
    for (id<BlueSTSDKFeatureDelegate> delegate in self.featureDelegates) {
        [delegate didUpdateFeature:self sample:sample];
    }//for
}//notifyUpdateWithSample

-(NSString*) description{
    NSMutableString *s = [NSMutableString stringWithString:@"Data:"];
    BlueSTSDKFeatureSample *sample = self.lastSample;
    NSArray<NSNumber *> *datas = sample.data;
    for (NSUInteger i = 0; i < datas.count; i++) {
        NSNumber *data = datas[i];
        [s appendFormat:@"%04X",data.shortValue];
    }//for
    return s;
}

@end



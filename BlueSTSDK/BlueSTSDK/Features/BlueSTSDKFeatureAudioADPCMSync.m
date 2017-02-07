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

#import <stdint.h>

#import "BlueSTSDKFeature_pro.h"
#import "BlueSTSDKFeatureAudioADPCMSync.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME @"AudioSync"

#define FEATURE_INDEX_INDEX 0

#define FEATURE_INDEX_UNIT nil
#define FEATURE_INDEX_NAME @"ADPCM_Index"
#define FEATURE_INDEX_MIN INT16_MIN
#define FEATURE_INDEX_MAX INT16_MAX
#define FEATURE_INDEX_TYPE BlueSTSDKFeatureFieldTypeInt16

#define FEATURE_PREDSAMPLE_INDEX 1
#define FEATURE_PREDSAMPLE_UNIT @""
#define FEATURE_PREDSAMPLE_NAME @"ADPCM_Predsample"
#define FEATURE_PREDSAMPLE_MIN INT32_MIN
#define FEATURE_PREDSAMPLE_MAX INT32_MAX
#define FEATURE_PREDSAMPLE_TYPE BlueSTSDKFeatureFieldTypeInt32

/**
 * @memberof BlueSTSDKFeatureAudioADPCMSync
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureAudioADPCMSync

    +(void)initialize {
        if (self == [BlueSTSDKFeatureAudioADPCMSync class]) {
            sFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_INDEX_NAME
                                                            unit:FEATURE_INDEX_UNIT
                                                            type:FEATURE_INDEX_TYPE
                                                             min:@FEATURE_INDEX_MIN
                                                             max:@FEATURE_INDEX_MAX],
                    [BlueSTSDKFeatureField createWithName:FEATURE_PREDSAMPLE_NAME
                                                     unit:FEATURE_PREDSAMPLE_UNIT
                                                     type:FEATURE_PREDSAMPLE_TYPE
                                                      min:@FEATURE_PREDSAMPLE_MIN
                                                      max:@FEATURE_PREDSAMPLE_MAX],
            ];
        }

    }

    -(instancetype) initWhitNode:(BlueSTSDKNode *)node{
        self = [super initWhitNode:node name:FEATURE_NAME];
        return self;
    }

    -(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
        return sFieldDesc;
    }

    -(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{

        if((rawData.length-offset) < 6){
            @throw [NSException
                    exceptionWithName:@"Invalid Audio ADPCM Sync data"
                               reason:@"The feature need almost 6 byte for extract the data"
                             userInfo:nil];
        }//if

        //timestamp is not used!!
        int16_t index = [rawData extractLeInt16FromOffset:offset+0];
        int32_t prevSampleIdx = [rawData extractLeInt32FromOffset:offset+2];

        NSArray *data = @[@(index),@(prevSampleIdx)];

        BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample
                sampleWithTimestamp:0 data:data ];
        return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:6];
    }

    + (int16_t) getIndex:(BlueSTSDKFeatureSample *) sample {
        if(sample.data.count>FEATURE_INDEX_INDEX)
            return [sample.data[FEATURE_INDEX_INDEX] shortValue];
        else
            return 0;
    }

    + (int32_t)getPredictedSample:(BlueSTSDKFeatureSample *) sample {
        if(sample.data.count>FEATURE_PREDSAMPLE_INDEX)
            return [sample.data[FEATURE_PREDSAMPLE_INDEX] intValue];
        else
            return -1;
    }

-(void) notifyUpdateWithSample:(BlueSTSDKFeatureSample *)sample{
    for (id<BlueSTSDKFeatureDelegate> delegate in self.featureDelegates) {
            [delegate didUpdateFeature:self sample:sample];
    }//for
}//notifyUpdateWithSample


@end

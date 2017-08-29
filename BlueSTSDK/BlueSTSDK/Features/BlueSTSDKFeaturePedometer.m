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

#import <limits.h>
#import <float.h>

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeaturePedometer.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"


#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Pedometer",nil)
#define FEATURE_STEPS_DATA_NAME BLUESTSDK_LOCALIZE(@"Steps",nil)
#define FEATURE_STEPS_UNIT nil
#define FEATURE_STEPS_MIN @0
#define FEATURE_STEPS_MAX @(UINT_MAX)
#define FEATURE_STEPS_TYPE BlueSTSDKFeatureFieldTypeUInt32

#define FEATURE_FREQ_DATA_NAME BLUESTSDK_LOCALIZE(@"Frequency",nil)
#define FEATURE_FREQ_UNIT BLUESTSDK_LOCALIZE(@"steps/min",nil)
#define FEATURE_FREQ_MIN @0
#define FEATURE_FREQ_MAX @(FLT_MAX)
#define FEATURE_FREQ_TYPE BlueSTSDKFeatureFieldTypeUInt16

/**
 * @memberof BlueSTSDKFeaturePedometer
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeaturePedometer

+(void)initialize{
    if(self == [BlueSTSDKFeaturePedometer class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_STEPS_DATA_NAME
                                                        unit:FEATURE_STEPS_UNIT
                                                        type:FEATURE_STEPS_TYPE
                                                         min:FEATURE_STEPS_MIN
                                                         max:FEATURE_STEPS_MAX],
                [BlueSTSDKFeatureField createWithName:FEATURE_FREQ_DATA_NAME
                                                 unit:FEATURE_FREQ_UNIT
                                                 type:FEATURE_FREQ_TYPE
                                                  min:FEATURE_FREQ_MIN
                                                  max:FEATURE_FREQ_MAX]];
    }//if
    
}

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  extract the number of steps and the frequency 
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no byte available in the rawdata array
 *  @return number of steps (uint) + frequency (uint16)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 6){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Pedometer data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 6 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    uint32_t steps= [rawData extractLeUInt32FromOffset:offset];
    uint16_t freq= [rawData extractLeUInt16FromOffset:offset+4];
    NSArray *data = @[[NSNumber numberWithUnsignedChar:steps],  @(freq)];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:6];
    
}

+(NSUInteger)getSteps:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count>0){
        return [(NSNumber*)[sample.data objectAtIndex:0] unsignedIntegerValue];
    }//if
    return -1;
}//getSteps

+(uint16_t)getFrequency:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count>1){
        return [(NSNumber*)[sample.data objectAtIndex:1] unsignedShortValue];
    }//if
    return -1;
}//getSteps

@end

#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeaturePedometer(fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:6];
    
    NSUInteger temp = (uint32_t)rand();
    [data appendBytes:&temp length:4];

    uint16_t freq = rand() % 100;
    
    [data appendBytes:&freq length:2];
    
    return data;
}

@end

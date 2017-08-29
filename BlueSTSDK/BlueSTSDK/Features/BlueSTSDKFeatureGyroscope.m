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
#import <math.h>

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureGyroscope.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Gyroscope",nil)
#define FEATURE_UNIT @"dps"
#define FEATURE_MAX ((float)(1<<15)/10.0f)
#define FEATURE_MIN (-FEATURE_MAX)
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeFloat

/**
 * @memberof BlueSTSDKFeatureGyroscope
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*>*sFieldDesc;

@implementation BlueSTSDKFeatureGyroscope

+(void)initialize{
    if(self == [BlueSTSDKFeatureGyroscope class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:@"X"
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_MAX],
                [BlueSTSDKFeatureField createWithName:@"Y"
                                                 unit:FEATURE_UNIT
                                                 type:FEATURE_TYPE
                                                  min:@FEATURE_MIN
                                                  max:@FEATURE_MAX],
                [BlueSTSDKFeatureField createWithName:@"Z"
                                                 unit:FEATURE_UNIT
                                                 type:FEATURE_TYPE
                                                  min:@FEATURE_MIN
                                                  max:@FEATURE_MAX]];
    }//if
}//initialize


+(float)getGyroX:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}

+(float)getGyroY:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<1)
        return NAN;
    return[[sample.data objectAtIndex:1] floatValue];
}

+(float)getGyroZ:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<2)
        return NAN;
    return[[sample.data objectAtIndex:2] floatValue];
}

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

/**
 *  read 3*int16 for build the gyroscope value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no 6 bytes available in the rawdata array
 *  @return gyroscope information + number of read bytes (6)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 6){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Gyroscope data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need 6 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    int16_t gyroX,gyroY,gyroZ;
    gyroX= [rawData extractLeInt16FromOffset:offset];
    gyroY= [rawData extractLeInt16FromOffset:offset+2];
    gyroZ= [rawData extractLeInt16FromOffset:offset+4];
    
    NSArray *newData = @[@(gyroX / 10.0f), @(gyroY / 10.0f), @(gyroZ / 10.0f)];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:newData];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:6];
}

@end

#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureGyroscope (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:6];
    
    int16_t temp = (int16_t)(( FEATURE_MIN + ((float)rand() / RAND_MAX)*(FEATURE_MAX-FEATURE_MIN))*10);
    [data appendBytes:&temp length:2];
    
    temp = (int16_t)( FEATURE_MIN + ((float)rand() / RAND_MAX)*(FEATURE_MAX-FEATURE_MIN))*10;
    [data appendBytes:&temp length:2];
    
    temp = (int16_t)( FEATURE_MIN + ((float)rand() / RAND_MAX)*(FEATURE_MAX-FEATURE_MIN))*10;
    [data appendBytes:&temp length:2];
    
    return data;
}

@end

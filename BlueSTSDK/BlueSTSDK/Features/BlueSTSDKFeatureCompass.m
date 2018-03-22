/*******************************************************************************
 * COPYRIGHT(c) 2016 STMicroelectronics
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
#import "BlueSTSDKFeatureCompass.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../Util/NSData+NumberConversion.h"


#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Compass",nil)
#define FEATURE_UNIT @"°"
#define FEATURE_DATA_NAME BLUESTSDK_LOCALIZE(@"Angle",nil)
#define FEATURE_MIN 0
#define FEATURE_MAX 360
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeFloat

static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureCompass

+(void)initialize{
    if(self == [BlueSTSDKFeatureCompass class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_DATA_NAME
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_MAX]];
    }//if
    
}


+(float)getCompassAngle:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  read uint16 for build the distance value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no 2 bytes available in the rawdata array
 *  @return proximity information + number of read bytes (2)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 2){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Compass data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 2 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    float angle = [rawData extractLeUInt16FromOffset:offset]/100.0f;
    
    NSArray *data = @[@(angle)];
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:2];
    
}

@end


#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureCompass (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:2];
    
    int16_t temp = FEATURE_MIN + rand()%((FEATURE_MAX-FEATURE_MIN));
    [data appendBytes:&temp length:2];
    
    return data;
}

@end


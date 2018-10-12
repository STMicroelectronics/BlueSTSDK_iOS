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
#import "BlueSTSDKFeatureFreeFall.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"FreeFall",nil)
#define FEATURE_UNIT nil
#define FEATURE_MIN 0
#define FEATURE_MAX 1
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeUInt8

/**
 * @memberof BlueSTSDKFeatureFreeFall
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureFreeFall

+(void)initialize{
    if(self == [BlueSTSDKFeatureFreeFall class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_NAME
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_MAX]];
    }
    
}

+(bool)getFreeFallStatus:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count>0)
        return [(NSNumber*)[sample.data objectAtIndex:0] unsignedCharValue]!=0;
    return false;
}

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  read int8 for build the free fall value,if the value is different from 0 a 
 * free fall event was detected by the node.
 * create the new sample and and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no byte available in the rawdata array
 *  @return free fall status + number of read bytes (1)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 1){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid FreeFall data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 1 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    uint8_t statusId= [rawData extractUInt8FromOffset:offset];
    
    NSArray *data = @[@(statusId)];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample
                                    sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:1];
}

@end

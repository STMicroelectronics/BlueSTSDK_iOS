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
#import "BlueSTSDKFeatureAcceleration.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Accelerometer",nil)
#define FEATURE_UNIT BLUESTSDK_LOCALIZE(@"mg",nil)
#define FEATURE_MIN -2000
#define FEATURE_MAX 2000
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeFloat

/**
 * @memberof BlueSTSDKFeatureAcceleration
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureAcceleration

/**
 *  build the data description statically for all the feature of type BlueSTSDKFeatureAcceleration
 */
+(void)initialize{
    if(self == [BlueSTSDKFeatureAcceleration class]){
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


+(float)getAccX:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] floatValue];
}//getAccX

+(float)getAccY:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<1)
        return NAN;
    return[[sample.data objectAtIndex:1] floatValue];
}//getAccY

+(float)getAccZ:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count<2)
        return NAN;
    return[[sample.data objectAtIndex:2] floatValue];
}//getAccZ

/**
 *  implement the abstract feature method, just build a feature with the right name
 *
 *  @param node node that will export this feature
 *
 *  @return build feature of type acceleration
 */
-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}//initWhitNode

/**
 *  return the field descriptor for this feature
 *
 *  @return the field descriptor for this feature
 */
-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}//getFieldsDesc

/**
 *  read 3*int16 for build the accelerometer value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *  
 *  @throw exception if there are no 6 bytes available in the rawdata array
 *  @return acceleration data + number of read bytes (6)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 6){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Acceleration data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need 6 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    
    int16_t accX,accY,accZ;
    accX= [rawData extractLeInt16FromOffset:offset];
    accY= [rawData extractLeInt16FromOffset:offset+2];
    accZ= [rawData extractLeInt16FromOffset:offset+4];
    
    NSArray *newData = @[@(accX), @(accY), @(accZ)];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:newData];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:6];

}//update

@end

#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureAcceleration (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:6];
    
    int16_t temp = FEATURE_MIN + rand()%(FEATURE_MAX-FEATURE_MIN);
    [data appendBytes:&temp length:2];
    
    temp = FEATURE_MIN + rand()%(FEATURE_MAX-FEATURE_MIN);
    [data appendBytes:&temp length:2];
    
    temp = FEATURE_MIN + rand()%(FEATURE_MAX-FEATURE_MIN);
    [data appendBytes:&temp length:2];
    
    return data;
}//generateFakeData

@end


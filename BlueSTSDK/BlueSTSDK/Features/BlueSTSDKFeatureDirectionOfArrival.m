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
#import "BlueSTSDKFeatureDirectionOfArrival.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Direction of arrival",nil)
#define FEATURE_DATA_NAME BLUESTSDK_LOCALIZE(@"Angle",nil)
#define FEATURE_UNIT @"\u00B0"
#define FEATURE_MIN 0
#define FEATURE_MAX 360
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeUInt16

/**
 * @memberof BlueSTSDKFeatureDirectionOfArrival
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureDirectionOfArrival

+(void)initialize{
    if(self == [BlueSTSDKFeatureDirectionOfArrival class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_DATA_NAME
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_MAX]];
    }//if
}//initialize


+(int16_t)getAudioSourceAngle:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count==0)
        return SHRT_MIN;
    return[sample.data[0] unsignedShortValue];
}

#define CHANGE_SL_SENSITIVITY (0xCC)
#define ENABLE_LOW_SENSITIVITY (0X00)
#define ENABLE_HIGH_SENSITIVITY (0X01)

- (void)enableLowSensitivity:(BOOL)enable {
    uint8_t commandData;
    if(enable){
        commandData = ENABLE_LOW_SENSITIVITY;
    }else{
        commandData = ENABLE_HIGH_SENSITIVITY;
    }
    [self sendCommand:CHANGE_SL_SENSITIVITY data:[NSData dataWithBytes:&commandData length:1]];
}


-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

static int16_t normalizeAngle(int16_t angle){

    while (angle<0){
        angle+=360;
    }
    while (angle>360){
        angle-=360;
    }
    return angle;
}

/**
 *  read int32 for build the pressure value, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no 4 bytes available in the rawdata array
 *  @return pressure information + number of read bytes (4)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 2){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Source Of Arrival data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 2 bytes for extract the data",nil)
                userInfo:nil];
    }//if
    
    int16_t angle= [rawData extractLeInt16FromOffset:offset];
    angle = normalizeAngle(angle);
    NSArray *data = @[@(angle)];
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:2];
}

@end



#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureDirectionOfArrival (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:2];
    
    uint16_t temp = rand()%((FEATURE_MAX-FEATURE_MIN));
    [data appendBytes:&temp length:2];
    
    return data;
}

@end

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
#import "BlueSTSDKFeatureProximity.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "BlueSTSDKFeatureField.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Proximity",nil)
#define FEATURE_UNIT @"mm"
#define FEATURE_MIN 0
#define FEATURE_LOW_RANGE_MAX (0xFE)
#define FEATURE_HIGHT_RANGE_MAX (0x7FFE)

#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeUInt16
#define FEATURE_OUT_OF_RANGE_VALUE (0xFFFF)

/**
 * @memberof BlueSTSDKFeatureProximity
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sLowRangeFieldDesc;
static NSArray<BlueSTSDKFeatureField*> *sHightRangeFieldDesc;

@implementation BlueSTSDKFeatureProximity{
    NSArray<BlueSTSDKFeatureField*> *mCurrentFeatureField;
}

+(void)initialize{
    if(self == [BlueSTSDKFeatureProximity class]){
        sLowRangeFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_NAME
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_LOW_RANGE_MAX]];
        sHightRangeFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_NAME
                                                                unit:FEATURE_UNIT
                                                                type:FEATURE_TYPE
                                                                 min:@FEATURE_MIN
                                                                 max:@FEATURE_HIGHT_RANGE_MAX]];
    }//if
    
}


+(uint16_t)getProximityDistance:(BlueSTSDKFeatureSample*)sample{
    if(sample.data.count==0)
        return NAN;
    return[[sample.data objectAtIndex:0] intValue];
}

+(BOOL)isOutOfRangeSample:(BlueSTSDKFeatureSample*)sample{
    return [BlueSTSDKFeatureProximity getProximityDistance:sample] ==
        [BlueSTSDKFeatureProximity outOfRangeValue];
}

+(uint16_t)outOfRangeValue{
    return FEATURE_OUT_OF_RANGE_VALUE;
}


-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    mCurrentFeatureField = sLowRangeFieldDesc;
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return mCurrentFeatureField;
}


 static BOOL isLowRangeSensor(uint16_t value){
     return (value & 0x8000)==0;
 }
 
 static uint16_t extractRangeValue(uint16_t value){
     return (value & ~0x8000);
 }
 
 static uint16_t getLowRangeValue(uint16_t value){
     uint16_t rangeValue = extractRangeValue(value);
     if(rangeValue > FEATURE_LOW_RANGE_MAX){
         rangeValue = FEATURE_OUT_OF_RANGE_VALUE;
     }
     return rangeValue;
 }

 static uint16_t getHighRangeSample(uint16_t value){
     uint16_t rangeValue = extractRangeValue(value);
     if(rangeValue > FEATURE_HIGHT_RANGE_MAX){
         rangeValue = FEATURE_OUT_OF_RANGE_VALUE;
     }
     return rangeValue;
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
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Proximity data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 2 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    uint16_t distance = [rawData extractLeUInt16FromOffset:offset];
    if(isLowRangeSensor(distance))
        distance = getLowRangeValue(distance);
    else
        distance = getHighRangeSample(distance);
    
    NSArray *data = @[@(distance)];
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:2];

}

-(NSString*) description{
    NSMutableString *s = [NSMutableString stringWithString:@"Ts:"];
    BlueSTSDKFeatureSample *sample = self.lastSample;
    [s appendFormat:@"%lld %@:",sample.timestamp,FEATURE_NAME];
    uint16_t distance = [sample.data[0] unsignedShortValue];
    if(distance != FEATURE_OUT_OF_RANGE_VALUE){
        [s appendFormat:@"%u",distance];
    }else{
        [s appendFormat:@"%@",BLUESTSDK_LOCALIZE(@"Out Of Range",nil)];
    }
    return s;
}//description

@end


#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureProximity (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:2];
    
    int16_t temp = FEATURE_MIN + rand()%((FEATURE_LOW_RANGE_MAX-FEATURE_MIN));
    [data appendBytes:&temp length:2];
    
    return data;
}

@end

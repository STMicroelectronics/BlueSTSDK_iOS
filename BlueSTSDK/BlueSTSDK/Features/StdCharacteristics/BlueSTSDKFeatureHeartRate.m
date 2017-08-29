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

#import "BlueSTSDKFeatureHeartRate.h"
#import "BlueSTSDKFeature_pro.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Heart Rate",nil)

#define HEART_RATE_INDEX (0)

#define HEART_RATE_NAME BLUESTSDK_LOCALIZE(@"Heart Rate Measurement",nil)
#define HEART_RATE_UNIT @"bpm"
#define HEART_RATE_MIN (0)
#define HEART_RATE_MAX (1<<16)
#define HEART_RATE_TYPE BlueSTSDKFeatureFieldTypeUInt16

#define ENERGY_INDEX (1)
#define ENERGY_NAME BLUESTSDK_LOCALIZE(@"Energy Expended",nil)
#define ENERGY_UNIT @"kJ"
#define ENERGY_MIN 0
#define ENERGY_MAX (1<<16)
#define ENERGY_TYPE BlueSTSDKFeatureFieldTypeUInt16


#define RR_INTERVAL_INDEX (2)
#define RR_INTERVAL_NAME BLUESTSDK_LOCALIZE(@"RR-Interval",nil)
#define RR_INTERVAL_UNIT @"s"
#define RR_INTERVAL_MIN 0
#define RR_INTERVAL_MAX HUGE_VALF
#define RR_INTERVAL_TYPE BlueSTSDKFeatureFieldTypeFloat

/**
 * @memberof BlueSTSDKFeatureHeartRate
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureHeartRate

/**
 *  build the data description statically for all the feature of type BlueSTSDKFeatureAcceleration
 */
+(void)initialize{
    if(self == [BlueSTSDKFeatureHeartRate class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:HEART_RATE_NAME
                                                        unit:HEART_RATE_UNIT
                                                        type:HEART_RATE_TYPE
                                                         min:@HEART_RATE_MIN
                                                         max:@HEART_RATE_MAX],
                [BlueSTSDKFeatureField createWithName:ENERGY_NAME
                                                 unit:ENERGY_UNIT
                                                 type:ENERGY_TYPE
                                                  min:@ENERGY_MIN
                                                  max:@ENERGY_MAX],
                [BlueSTSDKFeatureField createWithName:RR_INTERVAL_NAME
                                                 unit:RR_INTERVAL_UNIT
                                                 type:RR_INTERVAL_TYPE
                                                  min:@RR_INTERVAL_MIN
                                                  max:@(RR_INTERVAL_MAX)]];
    }//if
}//initialize

+ (int32_t)getHeartRate:(BlueSTSDKFeatureSample *)sample {
    if(sample.data.count>=HEART_RATE_INDEX)
        return [sample.data[HEART_RATE_INDEX] intValue];
    return -1;
}

+ (int32_t)getEnergyExtended:(BlueSTSDKFeatureSample *)sample {
    if(sample.data.count>=ENERGY_INDEX)
        return [sample.data[ENERGY_INDEX] intValue];
    return -1;
}

+ (float)getRRInterval:(BlueSTSDKFeatureSample *)sample {
    if(sample.data.count>=RR_INTERVAL_INDEX)
        return [sample.data[RR_INTERVAL_INDEX] floatValue];
    return NAN;
}


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


static BOOL has8BitHeartRate(uint8_t flags){
    return (flags & 0x01)==0;
}

static BOOL hasEnergyExpended(uint8_t flags){
    return (flags & 0x08)!=0;
}

static BOOL hasRRInterval(uint8_t flags){
    return (flags & 0x10)!=0;
}


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

    if(rawData.length-offset < 2){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Heart rate data",nil)
                           reason:BLUESTSDK_LOCALIZE(@"The feature need almost 2 bytes for extract the data",nil)
                         userInfo:nil];
    }//if

    int32_t heartRate,energyExpended;
    float rrInterval;
    uint32_t startOffset = offset;

    uint8_t flags = [rawData extractUInt8FromOffset:offset];
    offset++;

    if(has8BitHeartRate(flags)){
        heartRate = [rawData extractUInt8FromOffset:offset];
    }else{
        heartRate = [rawData extractLeUInt16FromOffset:offset];
        offset+=2;
    }

    if(hasEnergyExpended(flags)){
        energyExpended = [rawData extractLeUInt16FromOffset:offset];
        offset+=2;
    }else{
        energyExpended=-1;
    }

    if(hasRRInterval(flags)){
        rrInterval = [rawData extractLeUInt16FromOffset:offset]/1024.0f;
        offset+=2;
    } else
        rrInterval =NAN;


    NSArray *newData = @[@(heartRate), @(energyExpended), @(rrInterval)];

    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:newData];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:offset-startOffset];

}


//update

@end

#import "../../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureHeartRate (fake)

-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:2];

    int8_t temp =0;
    [data appendBytes:&temp length:1];
    temp =(uint8_t) (HEART_RATE_MIN + rand()%(HEART_RATE_MAX-HEART_RATE_MIN));
    [data appendBytes:&temp length:1];

    return data;
}//generateFakeData

@end

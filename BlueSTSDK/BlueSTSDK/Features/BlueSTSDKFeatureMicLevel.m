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

#import "BlueSTSDKFeatureMicLevel.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Mic Level",nil)
#define FEATURE_DATA_NAME BLUESTSDK_LOCALIZE(@"Mic",nil)
#define FEATURE_UNIT @"db"
#define FEATURE_MIN 0
#define FEATURE_MAX 128
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeUInt8

@implementation BlueSTSDKFeatureMicLevel{
    NSArray<BlueSTSDKFeatureField*> *mFieldDesc;
}

+(int8_t) getMicLevel:(BlueSTSDKFeatureSample*)sample micId:(uint8_t)micId{
    if(sample.data.count<micId)
        return -1;
    return[[sample.data objectAtIndex:0] charValue];
}


-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    BlueSTSDKFeatureField *temp = [BlueSTSDKFeatureField
                                   createWithName:FEATURE_DATA_NAME
                                             unit:FEATURE_UNIT
                                             type:FEATURE_TYPE
                                              min:@FEATURE_MIN
                                              max:@FEATURE_MAX];
    mFieldDesc = @[temp];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return mFieldDesc;
}


/**
 *  read all the byte as microphone levels, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no byte available in the rawdata array
 *  @return magnetometer datas + number of read bytes
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    int32_t nMic = (uint32_t)rawData.length-offset;
    if( nMic <= 0){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Mic Level data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need 1 byte for extract the data",nil)
                userInfo:nil];
    }//if
    
    //if the number of microphones change we recreate the descriptor
    if(mFieldDesc.count!=nMic){
        NSMutableArray *newFileDesc = [NSMutableArray arrayWithCapacity:nMic];
        for(int32_t i =0 ; i< nMic ; i++){
            NSString *name = [NSString stringWithFormat:@"%@ %d",FEATURE_DATA_NAME,i+1];
            BlueSTSDKFeatureField *temp = [BlueSTSDKFeatureField
                                           createWithName:name
                                           unit:FEATURE_UNIT
                                           type:FEATURE_TYPE
                                           min:@FEATURE_MIN
                                           max:@FEATURE_MAX];
            [newFileDesc addObject:temp];
        }//for
        mFieldDesc = newFileDesc;
    }//
    
    NSMutableArray *newData = [NSMutableArray arrayWithCapacity:nMic];
    for (uint32_t i=0; i<nMic; i++) {
        NSNumber *data = @([rawData extractUInt8FromOffset:offset + i]);
        [newData addObject:data];
    }
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample
                                      sampleWithTimestamp:timestamp
                                                     data:newData];
    
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:nMic];
}

@end

#import "../BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKFeatureMicLevel (fake)

/**
 * generate fake data for 3 microphones
 */
-(NSData*) generateFakeData{
    NSMutableData *data = [NSMutableData dataWithCapacity:3];
    
    uint8_t temp = FEATURE_MIN + rand()%(FEATURE_MAX-FEATURE_MIN);
    [data appendBytes:&temp length:1];
    
    temp = FEATURE_MIN + rand()%(FEATURE_MAX-FEATURE_MIN);
    [data appendBytes:&temp length:1];
    
    temp = FEATURE_MIN + rand()%(FEATURE_MAX-FEATURE_MIN);
    [data appendBytes:&temp length:1];
    
    return data;
}

@end

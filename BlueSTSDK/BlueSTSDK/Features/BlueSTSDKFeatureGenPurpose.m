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

#import <CoreBluetooth/CBUUID.h>

#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureGenPurpose.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"

#import "../Util/NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"General Purpose",nil)
#define FEATURE_UNIT BLUESTSDK_LOCALIZE(@"RawData",nil)
#define FEATURE_MIN 0
#define FEATURE_MAX 255
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeUInt8

/**
 * @memberof BlueSTSDKFeatureGenPurpose
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureGenPurpose
    
+(void)initialize{
    if(self == [BlueSTSDKFeatureGenPurpose class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [BlueSTSDKFeatureField  createWithName: FEATURE_NAME
                                                      unit:FEATURE_UNIT
                                                      type:FEATURE_TYPE
                                                       min:@FEATURE_MIN
                                                       max:@FEATURE_MAX ],
                      nil];
    }//if
}//initialize

+(NSData*) getRawData:(BlueSTSDKFeatureSample*)sample{
    NSMutableData *rawData = [NSMutableData dataWithCapacity:sample.data.count];
    
    for( NSNumber *n in sample.data){
        uint8_t temp = [n unsignedCharValue];
        [rawData appendBytes:&temp length:1];
    }//for
    return rawData;
}

-(instancetype)initWhitNode:(BlueSTSDKNode *)node characteristics:(CBCharacteristic*)c{
    NSString *name = [NSString stringWithFormat:@"GenPurpose_%@",c.UUID.UUIDString];

    self = [super initWhitNode:node name:name];
    _characteristics=c;
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}


/**
 *  read all the available byte and generate the sample and notify to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @return rawdata + number of read bytes 
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{

    NSMutableArray *tempData = [NSMutableArray arrayWithCapacity:rawData.length-offset];
    
    for(uint32_t i=offset ; i< rawData.length ; i++){
        uint8_t temp = [rawData extractUInt8FromOffset:i];
        [tempData addObject: [NSNumber numberWithUnsignedChar:temp]];
    }//for
    
    BlueSTSDKFeatureSample *sample =
        [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:tempData];
    
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:(uint32_t)(rawData.length-offset)];
}


-(NSString*) description{
    NSMutableString *s = [NSMutableString stringWithString:@"Ts:"];
    BlueSTSDKFeatureSample *sample = self.lastSample;
    [s appendFormat:@"%llu ",sample.timestamp];
    NSArray *datas = sample.data;
    [s appendString:BLUESTSDK_LOCALIZE(@"Data: ",nil)];
    for (NSNumber *n in datas) {
       [s appendFormat:@" %X ",[n unsignedCharValue]];
    }//for
    return s;
}

@end



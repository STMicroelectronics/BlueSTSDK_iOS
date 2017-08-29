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

#import "UnwrapTimeStamp.h"
#import "NSData+NumberConversion.h"

#import "BlueSTSDKFeature_pro.h"
#import "BlueSTSDKFeature+Remote.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"

/**
 * Max number of remote nodes
 */
#define DATA_MAX ((1<<16)-1)

/**
 * Min number of remote nodes
 */
#define DATA_MIN  0

static BlueSTSDKFeatureField *sFieldDesc;

@implementation BlueSTSDKFeature(Remote)

+(uint16_t) getNodeId:(BlueSTSDKFeatureSample*)sample idPos:(uint32_t)idPos{
    if(sample!=nil)
        if(sample.data.count>idPos){
            NSNumber *n = (NSNumber*) [sample.data objectAtIndex:idPos];
            if ( n != nil)
                return [n unsignedShortValue];
        }//if
    //else
    return -1;
}

+(BlueSTSDKFeatureField*) getNodeIdFieldDesc{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sFieldDesc = [BlueSTSDKFeatureField  createWithName:BLUESTSDK_LOCALIZE(@"Node Id",nil)
                                                       unit:@""
                                                       type:BlueSTSDKFeatureFieldTypeUInt16
                                                        min:@DATA_MIN
                                                        max:@DATA_MAX ];
    });
    
    return sFieldDesc;
}

+(BlueSTSDKFeatureSample*) appendRemoteId:(uint16_t)remoteId
                                   sample:(BlueSTSDKFeatureSample*)sample{
    NSMutableArray *remoteData = [NSMutableArray arrayWithArray:sample.data];
    [remoteData addObject:[NSNumber numberWithUnsignedShort:remoteId]];
    return [BlueSTSDKFeatureSample sampleWithTimestamp:sample.timestamp data:remoteData];
}

+(BlueSTSDKExtractResult*) extractRemoteData:(id<BlueSTSDKRemoteFeature>)feature
                                 unTsWrapper:(NSMutableDictionary *) nodeUnWrapper
                                   timestamp:(uint64_t)timestamp
                                        data:(NSData*)rawData
                                  dataOffset:(uint32_t)offset {
    

    if(rawData.length-offset < 3){ //2 bytes for the ts + 1 for some data
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Remote data",nil)
                reason:BLUESTSDK_LOCALIZE(@"There are not enough bytes available to read",nil)
                userInfo:nil];
    }//if
    
    //remove multiple of 2^16 since the node can unwrap the timestamp
    NSNumber *remoteId = [NSNumber numberWithUnsignedShort: ((int)timestamp %(1<<16))];
    //if it is the fist time that we see the node
    UnwrapTimeStamp *unWrap = [nodeUnWrapper objectForKey:remoteId];
    if(unWrap==nil){
        unWrap = [[UnwrapTimeStamp alloc]init];
        [nodeUnWrapper setObject:unWrap forKey:remoteId];
    }//if

    uint16_t ts = [rawData extractLeUInt16FromOffset:offset];
    timestamp = [unWrap unwrap:ts];

    BlueSTSDKExtractResult *tempData = [feature extractRemoteData:timestamp
                                                       data:rawData
                                                 dataOffset:offset+2 ];
    
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeature appendRemoteId:[remoteId unsignedShortValue]
                                                             sample:tempData.sample];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:2+tempData.nReadBytes];
    
}

@end

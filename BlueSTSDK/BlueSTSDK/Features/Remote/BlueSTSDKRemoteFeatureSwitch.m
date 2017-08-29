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

#import "BlueSTSDKRemoteFeatureSwitch.h"
#import "BlueSTSDKFeature_pro.h"
#import "BlueSTSDKFeature+Remote.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDK_LocalizeUtil.h"
#import "NSData+NumberConversion.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"Remote Switch",nil)

// census degree
#define FEATURE_UNIT @""
#define FEATURE_MIN 0
#define FEATURE_MAX 256
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeUInt8

/**
 * @memberof BlueSTSDKRemoteFeatureSwitch
 *  array with the description of field exported by the feature
 */
static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@interface BlueSTSDKRemoteFeatureSwitch ()<BlueSTSDKRemoteFeature>

@end


@implementation BlueSTSDKRemoteFeatureSwitch{
    NSMutableDictionary * mNodeUnWrapper;
}

+(void)initialize{
    if(self == [BlueSTSDKRemoteFeatureSwitch class]){
        sFieldDesc = [[NSArray alloc] initWithObjects:
                      [BlueSTSDKFeatureField  createWithName: FEATURE_NAME
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_MAX ],
                      [BlueSTSDKFeature getNodeIdFieldDesc],
                      nil];
    }//if
}//initialize

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    mNodeUnWrapper = [NSMutableDictionary dictionary];
    return self;
}

+(int)getNodeId:(BlueSTSDKFeatureSample*)sample{
    return [self getNodeId:sample idPos:1];
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

-(BlueSTSDKExtractResult*) extractRemoteData:(uint64_t)timestamp
                                        data:(NSData *)data
                                  dataOffset:(uint32_t)offset{
    return [super extractData:timestamp data:data dataOffset:offset];
}

-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData
                            dataOffset:(uint32_t)offset{
    
    return [BlueSTSDKFeature extractRemoteData: self
                                   unTsWrapper:mNodeUnWrapper
                                     timestamp:timestamp
                                          data:rawData
                                    dataOffset:offset];
    
}

-(bool) setSwitchStatus:(uint16_t)nodeId newStatus:(uint8_t) newStatus{
    uint16_t nodeIdBE = CFSwapInt16HostToBig(nodeId);
    return [self sendCommand:newStatus
                        data:[NSData dataWithBytes:&nodeIdBE length:2]];
}

-(bool) setSwitchStatus:(uint8_t) newStatus{
    [NSException raise:@"UnsupportedOperationException"
                format:@"You have to specify the remote node,"
                        "use setSwitchStatus(uint16_t,uint8_t) instead."];
    return false;
}

@end

#import "BlueSTSDKFeature+fake.h"

@implementation BlueSTSDKRemoteFeatureSwitch (fake)

-(NSData*) generateFakeData{
    static uint16_t ts=0;
    NSMutableData *data = [NSMutableData dataWithCapacity:4];
    
    int8_t temp = FEATURE_MIN + rand()%((FEATURE_MAX-FEATURE_MIN));
    [data appendBytes:&ts length:2];
    [data appendBytes:&temp length:1];
    ts++;
    return data;
}

@end

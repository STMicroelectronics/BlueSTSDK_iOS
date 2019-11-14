/*******************************************************************************
 * COPYRIGHT(c) 2017 STMicroelectronics
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

#import <Foundation/Foundation.h>

#import "BlueSTSDK/BlueSTSDK-Swift.h"
#import "BlueSTSDKNode.h"
#import "BlueSTSDKFeature_prv.h"
#import "BlueSTSDKFeatureSDLogging.h"


#import "BlueSTSDK_LocalizeUtil.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"SDLogging",nil)

static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureSDLogging {
    
}
+(void)initialize{
    if(self == [BlueSTSDKFeatureSDLogging class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:@"isEnabled"
                                                        unit:NULL
                                                        type:BlueSTSDKFeatureFieldTypeUInt8
                                                         min:@0
                                                         max:@1],
                       [BlueSTSDKFeatureField createWithName:@"loggedFeature"
                                                        unit:NULL
                                                        type:BlueSTSDKFeatureFieldTypeUInt32
                                                         min:@0
                                                         max:@0xFFFFFFFF],
                       [BlueSTSDKFeatureField createWithName:@"logInterval"
                                                        unit:@"s"
                                                        type:BlueSTSDKFeatureFieldTypeUInt32
                                                         min:@0
                                                         max:@0xFFFFFFFF]];
    }//if
}//initialize

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

+(BlueSTSDKFeatureSDLoggingStatus) getStatus:(BlueSTSDKFeatureSample *)data{
    if(data.data.count>=1)
        return (BlueSTSDKFeatureSDLoggingStatus)
            data.data[0].unsignedCharValue;
    return BlueSTSDKFeatureSDLoggingStatusIO_ERROR;
}

+(BOOL)isLogging:(BlueSTSDKFeatureSample*)data{
    return [BlueSTSDKFeatureSDLogging getStatus:data] == BlueSTSDKFeatureSDLoggingStatusSTARTED;
}

+(uint32_t)getLogInterval:(BlueSTSDKFeatureSample*)data{
    if(data.data.count>=3)
        return data.data[2].unsignedIntValue;
    return -1;
}

+(NSSet<BlueSTSDKFeature*>*)getLoggedFeature:(BlueSTSDKNode*)node data:(BlueSTSDKFeatureSample*)data{
    if(data.data.count>=2){
        return [BlueSTSDKFeatureSDLogging buildFeatureSetFor:node featureMask:data.data[1].unsignedIntValue];
    }
    return [NSSet init];
    
}

/**
 * get the list of feature selected by the bitmask
 *
 * @param node node where the feature are
 * @param featureMask bit mask that select the feature
 * @return list of feature selected
 */
+(NSSet<BlueSTSDKFeature*>*)buildFeatureSetFor:(BlueSTSDKNode*)node featureMask:(uint32_t)featureMask{
    uint32_t nBit = 8*sizeof(uint32_t);
    NSDictionary *maskFeatureMap = [[BlueSTSDKManager sharedInstance] getFeaturesForNode: node.typeId];
    NSMutableSet *featureSet = [NSMutableSet setWithCapacity:32];
    for (uint32_t i=0; i<nBit; i++) {
        uint32_t test = 1<<i;
        if((featureMask & test)!=0){ //we select a bit in the mask
            Class featureClass = maskFeatureMap[@(test)];
            if(featureClass!=nil){ //if exist a feature link to that bit
                BlueSTSDKFeature *f = [node getFeatureOfType:featureClass];
                if(f!=nil)
                    [featureSet addObject:f];
            }// if featureClass
        }//if mask
    }//for
    return featureSet;
}


/**
 * utility function for write some data to a characteristics
 *
 * @param data data to write into the feature
 */
-(void)writeData:(NSData*)data{
    [self.parentNode writeDataToFeature:self data:data];
}

-(void)stopLogging{
    uint8_t message[] = {0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00,0x00};
    NSData *messageData = [NSData dataWithBytes:message length:sizeof(message)];
    [self writeData:messageData];
}


/**
 * create a feature mask that select the feature
 * @param featureToLog feature to select
 * @return bit mask that select the feature passed by parameters
 */
-(uint32_t) buildFeatureMaskFor:(NSSet<BlueSTSDKFeature*>*) featureToLog{
    NSDictionary *maskFeatureMap = [[BlueSTSDKManager sharedInstance] getFeaturesForNode: self.parentNode.typeId];
    uint32_t logMask=0;
    for( BlueSTSDKFeature *f in featureToLog){
        NSArray<NSNumber*>* featureMask = [maskFeatureMap allKeysForObject:[f class]];
        if(featureMask.count>=1){
            logMask |= featureMask[0].unsignedIntValue;
        }
    }
    return logMask;
}

-(void)sartLoggingFeature:(NSSet<BlueSTSDKFeature*>*)featureToLog evrey:(uint32_t)seconds{
    uint32_t logMask = [self buildFeatureMaskFor:featureToLog];
    NSMutableData *message = [NSMutableData dataWithCapacity:9];
    uint8_t enableLog=1;
    [message appendBytes:&enableLog length:1];
    [message appendBytes:&logMask length:sizeof(logMask)];
    [message appendBytes:&seconds length:sizeof(seconds)];
    [self writeData:message];
}

/**
 *  read current log status, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no 9 bytes available in the rawdata array
 *  @return pressure information + number of read bytes (9)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 9){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid SD Logging data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 9 bytes to extract the data",nil)
                userInfo:nil];
    }//if
    
    uint8_t isLogEnable;
    [rawData getBytes:&isLogEnable range:NSMakeRange(offset, 1)];
    uint32_t featureMask;
    [rawData getBytes:&featureMask range:NSMakeRange(offset+1, 4)];
    uint32_t logInterval;
    [rawData getBytes:&logInterval range:NSMakeRange(offset+5, 4)];
    NSArray *data = @[@(isLogEnable),@(featureMask),@(logInterval)];
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:9];
}
@end

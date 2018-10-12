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

#import "BlueSTSDKFeatureBeamForming.h"
#import "BlueSTSDKFeature_prv.h"

#import "BlueSTSDK_LocalizeUtil.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"BeamForming",nil)
#define FEATURE_DATA_NAME BLUESTSDK_LOCALIZE(@"BeamForming",nil)

#define FEATURE_UNIT nil
#define FEATURE_MIN 0
#define FEATURE_MAX 7
#define FEATURE_TYPE BlueSTSDKFeatureFieldTypeInt8

static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;

@implementation BlueSTSDKFeatureBeamForming {

}

+(void)initialize{
    if(self == [BlueSTSDKFeatureBeamForming class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:FEATURE_DATA_NAME
                                                        unit:FEATURE_UNIT
                                                        type:FEATURE_TYPE
                                                         min:@FEATURE_MIN
                                                         max:@FEATURE_MAX]];
    }//if
}//initialize


+(BlueSTSDKFeatureBeamFormingDirection)getDirection:(BlueSTSDKFeatureSample *)sample{
    if(sample.data.count==0)
        return BlueSTSDKFeatureBeamFormingDirection_UNKNOWN;
    return (BlueSTSDKFeatureBeamFormingDirection) [sample.data[0] unsignedCharValue];

}

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

/**
 *  read a byte for build the beamforming direction, create the new sample and
 * and notify it to the delegate
 *
 *  @param timestamp data time stamp
 *  @param rawData   array of byte send by the node
 *  @param offset    offset where we have to start reading the data
 *
 *  @throw exception if there are no bytes available in the rawdata array
 *  @return pressure information + number of read bytes (1)
 */
-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp data:(NSData*)rawData dataOffset:(uint32_t)offset{

    if(rawData.length-offset < 1){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid Beam Forming data",nil)
                           reason:BLUESTSDK_LOCALIZE(@"The feature need almost 1 byte to extract the data",nil)
                         userInfo:nil];
    }//if

    uint8_t temp;
    [rawData getBytes:&temp range:NSMakeRange(offset, 1)];

    NSArray *data = @[@(temp)];
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:1];
}


#define ENABLE_BEAMFORMING_COMMAND (0xAA)
#define ENABLE_BEAMFORMING_ON (0x01)
#define ENABLE_BEAMFORMING_OFF (0x00)

- (void)enablebeamForming:(BOOL)enabled {
    uint8_t commandData;
    if(enabled){
        commandData = ENABLE_BEAMFORMING_ON;
    }else{
        commandData = ENABLE_BEAMFORMING_OFF;
    }
    [self sendCommand:ENABLE_BEAMFORMING_COMMAND data:[NSData dataWithBytes:&commandData length:1]];
}


#define BF_COMMAND_TYPE_CHANGE_TYPE (0xCC)
#define COMMAND_STRONG_BF (0x01)
#define COMMAND_ASR_READY_BF (0x00)

- (void)useStrongbeamFormingAlgorithm:(BOOL)enabled {
    uint8_t commandData;
    if(enabled){
        commandData = COMMAND_STRONG_BF;
    }else{
        commandData = COMMAND_ASR_READY_BF;
    }
    [self sendCommand:BF_COMMAND_TYPE_CHANGE_TYPE data:[NSData dataWithBytes:&commandData length:1]];
}


#define CHANGE_DIRECTION_COMMAND (0xBB)

-(void) setDirection:(BlueSTSDKFeatureBeamFormingDirection)direction{
    NSData *temp = [NSData dataWithBytes:&direction length:1];
    [self sendCommand:CHANGE_DIRECTION_COMMAND data:temp];
}
@end

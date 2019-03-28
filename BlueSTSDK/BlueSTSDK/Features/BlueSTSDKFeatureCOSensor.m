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
#import "BlueSTSDKFeature_pro.h"
#import "BlueSTSDKFeatureCOSensor.h"
#import "../Util/NSData+NumberConversion.h"


#import "BlueSTSDK_LocalizeUtil.h"

#define FEATURE_NAME BLUESTSDK_LOCALIZE(@"CO Sensor",nil)
#define SET_SENSITIVITY_CMD (1)
#define GET_SENSITIVITY_CMD (0)

static NSArray<BlueSTSDKFeatureField*> *sFieldDesc;
static dispatch_queue_t sNotificationQueue;

@implementation BlueSTSDKFeatureCOSensor

+(void)initialize{
    if(self == [BlueSTSDKFeatureCOSensor class]){
        sFieldDesc = @[[BlueSTSDKFeatureField createWithName:@"CO Concentration"
                                                        unit:@"ppm"
                                                        type:BlueSTSDKFeatureFieldTypeFloat
                                                         min:@1000000
                                                         max:@1]];
    }//if
}//initialize

-(instancetype) initWhitNode:(BlueSTSDKNode *)node{
    self = [super initWhitNode:node name:FEATURE_NAME];
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sNotificationQueue = dispatch_queue_create("BlueSTSDKFeatureAutoConfigurable",
                                                   DISPATCH_QUEUE_CONCURRENT);
    });
    
    return self;
}

-(NSArray<BlueSTSDKFeatureField*>*) getFieldsDesc{
    return sFieldDesc;
}

+(float)getGasPresence:(BlueSTSDKFeatureSample*)data{
    if(data.data.count>=1)
        return data.data[0].floatValue;
    return NAN;
}

-(void)setSensorSensitivity:(float) newSensitivity{
    NSData *data = [NSData dataWithBytes:&newSensitivity length:sizeof(newSensitivity)];
    [super sendCommand:SET_SENSITIVITY_CMD data:data];
}

-(void) requestSensitivity{
    [super sendCommand:GET_SENSITIVITY_CMD data:nil];
}

-(BlueSTSDKExtractResult*) extractData:(uint64_t)timestamp
                                  data:(NSData*)rawData
                            dataOffset:(uint32_t)offset{
    
    if(rawData.length-offset < 4){
        @throw [NSException
                exceptionWithName:BLUESTSDK_LOCALIZE(@"Invalid CO Sensor data",nil)
                reason:BLUESTSDK_LOCALIZE(@"The feature need almost 4 bytes to extract the data",nil)
                userInfo:nil];
    }//if
    
    float coValue = [rawData extractLeUInt32FromOffset:offset]/100.0f;
    NSArray *data = @[@(coValue)];
    BlueSTSDKFeatureSample *sample = [BlueSTSDKFeatureSample sampleWithTimestamp:timestamp data:data ];
    return [BlueSTSDKExtractResult resutlWithSample:sample nReadData:4];
}

-(void) parseCommandResponseWithTimestamp:(uint64_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data{
    if(commandType == GET_SENSITIVITY_CMD){
        float sensitivity = [data extractLeFloatFromOffset:0];
        [self notifySensitivityRead:sensitivity];
    }
}

-(void) notifySensitivityRead:(float)newSensitivity{
    for (id<BlueSTSDKFeatureDelegate> delegate in self.featureDelegates) {
        //check if the delegate is a co de
        if ([delegate.class conformsToProtocol:@protocol(BlueSTSDKCOSensorFeatureDelegate)]){
            const id<BlueSTSDKCOSensorFeatureDelegate> CODelegate = (id<BlueSTSDKCOSensorFeatureDelegate>) delegate;
            if( [CODelegate respondsToSelector:@selector(didUpdateFeature:sensitivity:)]){
                dispatch_async(sNotificationQueue, ^(){
                    [CODelegate didUpdateFeature:self sensitivity:newSensitivity];
                });
            }//if
        }
    }//for*/
}

@end

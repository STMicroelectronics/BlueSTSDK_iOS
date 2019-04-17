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

#import <Foundation/Foundation.h>

#import "../Features/BlueSTSDKFeatureAcceleration.h"
#import "../Features/BlueSTSDKFeatureGyroscope.h"
#import "../Features/BlueSTSDKFeatureMagnetometer.h"
#import "../Features/BlueSTSDKFeatureMemsSensorFusion.h"
#import "../Features/BlueSTSDKFeatureHumidity.h"
#import "../Features/BlueSTSDKFeatureTemperature.h"
#import "../Features/BlueSTSDKFeaturePressure.h"
#import "../Features/BlueSTSDKFeatureMemsSensorFusionCompact.h"
#import "../Features/BlueSTSDKFeatureLuminosity.h"
#import "../Features/BlueSTSDKFeatureProximity.h"
#import "../Features/BlueSTSDKFeatureBattery.h"
#import "../Features/BlueSTSDKFeatureFreeFall.h"
#import "../Features/BlueSTSDKFeatureCarryPosition.h"
#import "../Features/BlueSTSDKFeatureMicLevel.h"
#import "../Features/BlueSTSDKFeatureProximityGesture.h"
#import "../Features/BlueSTSDKFeatureMemsGesture.h"
#import "../Features/BlueSTSDKFeaturePedometer.h"
#import "../Features/BlueSTSDKFeatureAccelerometerEvent.h"
#import "../Features/BlueSTSDKFeatureDirectionOfArrival.h"
#import "../Features/BlueSTSDKFeatureSwitch.h"
#import "../Features/BlueSTSDKFeatureCompass.h"
#import "../Features/Remote/BlueSTSDKRemoteFeatureSwitch.h"
#import "../Features/Remote/BlueSTSDKRemoteFeatureTemperature.h"
#import "../Features/Remote/BlueSTSDKRemoteFeaturePressure.h"
#import "../Features/Remote/BlueSTSDKRemoteFeatureHumidity.h"
#import "../Features/BlueSTSDKFeatureAudioADPCM.h"
#import "../Features/BlueSTSDKFeatureAudioADPCMSync.h"
#import "../Features/BlueSTSDKFeatureMotionIntensity.h"
#import "../Features/BlueSTSDKFeatureSDLogging.h"
#import "../Features/BlueSTSDKFeatureCOSensor.h"
#import "BlueSTSDK/BlueSTSDK-Swift.h"

#import "BlueSTSDKBleNodeDefines.h"
#import "NSData+NumberConversion.h"
#import "BlueSTSDKFeatureBeamForming.h"

//all the sdk characteristics will end with this string
#define COMMON_CHAR_UUID @"-11E1-AC36-0002A5D5C51B"
//all the features characteristics exported in the advertise feature mask will end with this string
#define BASE_FEATURE_COMMON_UUID @"-0001" COMMON_CHAR_UUID
//all the features characteristics not exported will end with this string
#define EXTENDED_FEATURE_COMMON_UUID @"-0002" COMMON_CHAR_UUID
//all the general purpose characteristics will end with this string
#define COMMON_GP_FEATURE_UUID @"-0003" COMMON_CHAR_UUID
//all the sdk service will end with this string
#define COMMON_SERVICE_UUID "-11E1-9AB4-0002A5D5C51B"

static NSDictionary<CBUUID*,NSArray<Class>*> *EXTENDED_FEATURE_MAP = nil;


@implementation BlueSTSDKFeatureCharacteristics

+(CBUUID*) buildExtendedFeatureCharacteristicsWithPrefix:(uint32_t) prefix{
    NSString *uuidString = [NSString stringWithFormat:@"%08X%@",prefix,EXTENDED_FEATURE_COMMON_UUID];
    return [CBUUID UUIDWithString: uuidString];
}
/*
 EXTENDED_FEATURE_MAP.put(buildExtendedFeatureCharacteristics(0x07), asList(FeaturePredictiveSpeedStatus.class));
 EXTENDED_FEATURE_MAP.put(buildExtendedFeatureCharacteristics(0x08), asList(FeaturePredictiveAccelerationStatus.class));
 EXTENDED_FEATURE_MAP.put(buildExtendedFeatureCharacteristics(0x09), asList(FeaturePredictiveFrequencyDomainStatus.class));
 */
+(void)initialize{
    if(self == [BlueSTSDKFeatureCharacteristics class]){
        EXTENDED_FEATURE_MAP = @{
                                 [BlueSTSDKFeatureCharacteristics buildExtendedFeatureCharacteristicsWithPrefix: 0x3]:@[[BlueSTSDKFeatureAudioSceneCalssification class]],
                                 [BlueSTSDKFeatureCharacteristics buildExtendedFeatureCharacteristicsWithPrefix: 0x4]:@[[BlueSTSDKFeatureAILogging class]],
                                 [BlueSTSDKFeatureCharacteristics buildExtendedFeatureCharacteristicsWithPrefix: 0x5]:@[[BlueSTSDKFeatureFFTAmplitude class]],
                                 [BlueSTSDKFeatureCharacteristics buildExtendedFeatureCharacteristicsWithPrefix: 0x6]:@[[BlueSTSDKFeatureMotorTimeParameters class]],
                                 [BlueSTSDKFeatureCharacteristics buildExtendedFeatureCharacteristicsWithPrefix: 0x7]:@[[BlueSTSDKFeaturePredictiveSpeedStatus class]],
                                 [BlueSTSDKFeatureCharacteristics buildExtendedFeatureCharacteristicsWithPrefix: 0x8]:@[[BlueSTSDKFeaturePredictiveAccelerationStatus class]],
                                 [BlueSTSDKFeatureCharacteristics buildExtendedFeatureCharacteristicsWithPrefix: 0x9]:@[[BlueSTSDKFeaturePredictiveFrequencyDomainStatus class]],
                                 };
    }
    
}

+(featureMask_t)extractFeatureMask:(CBUUID *)uuid{
    return [uuid.data extractBeUInt32FromOffset:0];
}//extractFeatureMask

+(bool) isFeatureCharacteristics:(CBCharacteristic*) c{
    return [ c.UUID.UUIDString hasSuffix:BASE_FEATURE_COMMON_UUID];
}//isFeatureCharacteristics

+(bool) isFeatureGeneralPurposeCharacteristics:(CBCharacteristic*) c{
    return [ c.UUID.UUIDString hasSuffix:COMMON_GP_FEATURE_UUID];
}//isFeatureGeneralPurposeCharacteristics

+(nullable NSArray<Class>*)getExtendedFeatureInCharacteristics:(CBCharacteristic*) c{
    return EXTENDED_FEATURE_MAP[c.UUID];
}

@end

#define CONFIG_SERVICE_ID "000F"
#define CONFIG_SERVICE_UUID @"00000000-"CONFIG_SERVICE_ID COMMON_SERVICE_UUID
#define CONFIG_CONTROL_CHAR_UUID @"00000001-"CONFIG_SERVICE_ID COMMON_CHAR_UUID
#define COMMAND_CONFIG_CHAR_UUID @"00000002-"CONFIG_SERVICE_ID COMMON_CHAR_UUID

@implementation BlueSTSDKServiceConfig
+(CBUUID*) serviceUuid{
    static CBUUID *service = nil;
    if(service==nil)
        service=[CBUUID UUIDWithString:CONFIG_SERVICE_UUID ];
    return service;
}//serviceUuid

+(CBUUID*) configControlUuid{
    static CBUUID *configControl =nil;
    if(configControl ==nil)
        configControl = [CBUUID UUIDWithString: CONFIG_CONTROL_CHAR_UUID];
    return configControl;
}//configControlUuid

+(CBUUID*) featureCommandUuid{
    static CBUUID *commandFeature =nil;
    if(commandFeature ==nil)
        commandFeature = [CBUUID UUIDWithString: COMMAND_CONFIG_CHAR_UUID];
    return commandFeature;
}//featureCommandUuid

+(bool) isConfigCharacteristics:(CBCharacteristic*) c {
    return [c.UUID isEqual: BlueSTSDKServiceConfig.configControlUuid] ||
    [c.UUID isEqual: BlueSTSDKServiceConfig.featureCommandUuid];
}//isConfigCharacteristics

+(bool) isConfigControlCharacteristic:(CBCharacteristic*) c {
    return [c.UUID isEqual: BlueSTSDKServiceConfig.configControlUuid];
}//isConfigControlCharacteristic

+(bool) isConfigFeatureCommandCharacteristic:(CBCharacteristic*) c {
    return [c.UUID isEqual: BlueSTSDKServiceConfig.featureCommandUuid];
}//isConfigFeatureCommandCharacteristic

@end

#define DEBUG_SERVICE_ID "000E"
#define DEBUG_SERVICE_UUID @"00000000-"DEBUG_SERVICE_ID COMMON_SERVICE_UUID
#define TEMR_DEBUG_CHAR_UUID @"00000001-"DEBUG_SERVICE_ID COMMON_CHAR_UUID
#define STDERR_DEBUG_CHAR_UUID @"00000002-"DEBUG_SERVICE_ID COMMON_CHAR_UUID

@implementation BlueSTSDKServiceDebug
+(CBUUID*) serviceUuid{
    static CBUUID *service = nil;
    if(service==nil)
        service=[CBUUID UUIDWithString:DEBUG_SERVICE_UUID ];
    return service;
}//serviceUuid

+(CBUUID*) stdErrUuid{
    static CBUUID *stdErr =nil;
    if(stdErr ==nil)
        stdErr = [CBUUID UUIDWithString: STDERR_DEBUG_CHAR_UUID];
    return stdErr;
}//stdErrUuid

+(CBUUID*) termUuid{
    static CBUUID *term =nil;
    if(term ==nil)
        term = [CBUUID UUIDWithString: TEMR_DEBUG_CHAR_UUID];
    return term;
}//termUuid

+(bool) isDebugCharacteristics:(CBCharacteristic*) c{
    return [c.UUID isEqual: BlueSTSDKServiceDebug.termUuid] ||
    [c.UUID isEqual: BlueSTSDKServiceDebug.stdErrUuid];
}//isDebugCharacteristics

@end

@implementation BlueSTSDKServices

+(BlueSTSDKServiceDebug*) debugService{
    static BlueSTSDKServiceDebug *service = nil;
    if(service==nil)
        service=[BlueSTSDKServiceDebug alloc];
    return service;
}//debugService

+(BlueSTSDKServiceConfig*) configService{
    static BlueSTSDKServiceConfig *service = nil;
    if(service==nil)
        service=[BlueSTSDKServiceConfig alloc];
    return service;
}//configService

@end

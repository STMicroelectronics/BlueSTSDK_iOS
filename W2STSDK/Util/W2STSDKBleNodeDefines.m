//
//  W2STSDKBleNodeDefines.m
//  W2STApp
//
//  Created by Giovanni Visentini on 27/03/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "../Features/W2STSDKFeatureAcceleration.h"
#import "../Features/W2STSDKFeatureGyroscope.h"
#import "../Features/W2STSDKFeatureMagnetometer.h"
#import "../Features/W2STSDKFeatureMemsSensorFusion.h"
#import "../Features/W2STSDKFeatureHumidity.h"
#import "../Features/W2STSDKFeatureTemperature.h"
#import "../Features/W2STSDKFEaturePressure.h"
#import "../Features/W2STSDKFeatureMemsSensorFusionCompact.h"
#import "../Features/W2STSDKFeatureLuminosity.h"
#import "../Features/W2STSDKFeatureProximity.h"
#import "../Features/W2STSDKFeatureBattery.h"

#import "W2STSDKBleNodeDefines.h"
#import "NSData+NumberConversion.h"

#define COMMON_CHAR_UUID @"-11E1-AC36-0002A5D5C51B"
#define COMMON_FEATURE_UUID @"-0001" COMMON_CHAR_UUID
#define COMMON_GP_FEATURE_UUID @"-0003" COMMON_CHAR_UUID
#define COMMON_SERVICE_UUID "-11E1-9AB4-0002A5D5C51B"

@implementation W2STSDKFeatureCharacteristics

+(featureMask_t)extractFeatureMask:(CBUUID *)uuid{
    return [uuid.data extractBeUInt32FromOffset:0];
}

+(bool) isFeatureCharacteristics:(CBCharacteristic*) c{
    return [ c.UUID.UUIDString hasSuffix:COMMON_FEATURE_UUID];
}

+(bool) isFeatureGeneralPurposeCharacteristics:(CBCharacteristic*) c{
    return [ c.UUID.UUIDString hasSuffix:COMMON_GP_FEATURE_UUID];
}

@end

#define CONFIG_SERVICE_ID "000F"
#define CONFIG_SERVICE_UUID @"00000000-"CONFIG_SERVICE_ID COMMON_SERVICE_UUID
#define CONFIG_CONTROL_CHAR_UUID @"00000001-"CONFIG_SERVICE_ID COMMON_CHAR_UUID
#define COMMAND_CONFIG_CHAR_UUID @"00000002-"CONFIG_SERVICE_ID COMMON_CHAR_UUID

@implementation W2STSDKServiceConfig
+(CBUUID*) serviceUuid{
    static CBUUID *service = nil;
    if(service==nil)
        service=[CBUUID UUIDWithString:CONFIG_SERVICE_UUID ];
    return service;
}
+(CBUUID*) configControlUuid{
    static CBUUID *configControl =nil;
    if(configControl ==nil)
        configControl = [CBUUID UUIDWithString: CONFIG_CONTROL_CHAR_UUID];
    return configControl;
}
+(CBUUID*) featureCommandUuid{
    static CBUUID *commandFeature =nil;
    if(commandFeature ==nil)
        commandFeature = [CBUUID UUIDWithString: COMMAND_CONFIG_CHAR_UUID];
    return commandFeature;
}
+(bool) isConfigCharacteristics:(CBCharacteristic*) c {
    return [c.UUID isEqual: W2STSDKServiceConfig.configControlUuid] ||
        [c.UUID isEqual: W2STSDKServiceConfig.featureCommandUuid];
}
@end

#define DEBUG_SERVICE_ID "000E"
#define DEBUG_SERICE_UUID @"00000000-"DEBUG_SERVICE_ID COMMON_SERVICE_UUID
#define TEMR_DEBUG_CHAR_UUID @"00000001-"DEBUG_SERVICE_ID COMMON_CHAR_UUID
#define STDERR_DEBUG_CHAR_UUID @"00000002-"DEBUG_SERVICE_ID COMMON_CHAR_UUID

@implementation W2STSDKServiceDebug
+(CBUUID*) serviceUuid{
    static CBUUID *service = nil;
    if(service==nil)
        service=[CBUUID UUIDWithString:DEBUG_SERICE_UUID ];
    return service;
}
+(CBUUID*) stdErrUuid{
    static CBUUID *stdErr =nil;
    if(stdErr ==nil)
        stdErr = [CBUUID UUIDWithString: STDERR_DEBUG_CHAR_UUID];
    return stdErr;
}

+(CBUUID*) termUuid{
    static CBUUID *term =nil;
    if(term ==nil)
        term = [CBUUID UUIDWithString: TEMR_DEBUG_CHAR_UUID];
    return term;
}

+(bool) isDebugCharacteristics:(CBCharacteristic*) c{
    return [c.UUID isEqual: W2STSDKServiceDebug.termUuid] ||
        [c.UUID isEqual: W2STSDKServiceDebug.stdErrUuid];
}

@end

@implementation W2STSDKServices
+(W2STSDKServiceDebug*) debugService{
    static W2STSDKServiceDebug *service = nil;
    if(service==nil)
        service=[W2STSDKServiceDebug alloc];
    return service;
}
+(W2STSDKServiceConfig*) configService{
    static W2STSDKServiceConfig *service = nil;
    if(service==nil)
        service=[W2STSDKServiceConfig alloc];
    return service;
}
@end

@implementation W2STSDKBoardFeatureMap
static NSDictionary *nucleoFeatureMap = nil;
static NSDictionary *wesuFeatureMap = nil;
static NSDictionary *boardFeatureMap = nil;
+(void)initialize{
    if(self == [W2STSDKBoardFeatureMap class]){
    nucleoFeatureMap = @{
                         @0x00200000: [W2STSDKFeatureMagnetometer class], //mag
                         @0x00400000: [W2STSDKFeatureGyroscope class], //gyo
                         @0x00800000: [W2STSDKFeatureAcceleration class], //acc
                         @0x00080000: [W2STSDKFeatureHumidity class], //humidity
                         @0x00040000: [W2STSDKFeatureTemperature class], //temperature
                         @0x00100000: [W2STSDKFeaturePressure class], //pressure
                         @0x00000080: [W2STSDKFeatureMemsSensorFusion class], //Mems sensor fusion
                         @0x00000100: [W2STSDKFeatureMemsSensorFusionCompact class], //Mems sensor fusion compact
                         @0x01000000: [W2STSDKFeatureLuminosity class], //luminosity
                         @0x02000000: [W2STSDKFeatureProximity class], //proximity
                         @0x00020000: [W2STSDKFeatureBattery class] //battery

                         };

    wesuFeatureMap = @{
                       @0x00200000: [W2STSDKFeatureMagnetometer class], //mag
                       @0x00400000: [W2STSDKFeatureGyroscope class], //gyo
                       @0x00800000: [W2STSDKFeatureAcceleration class], //acc
                       @0x00000080: [W2STSDKFeatureMemsSensorFusion class] //mems sensor fusion
                       };
        
    boardFeatureMap = @{
                        @0x01:wesuFeatureMap,
                        @0x80:nucleoFeatureMap
                        };
    }
}
+(NSDictionary*) boardFeatureMap{
    return boardFeatureMap;
}


@end

//
//  W2STSDKBleNodeDefines.m
//  W2STApp
//
//  Created by Giovanni Visentini on 27/03/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "../W2STSDKFeature.h"
#import "W2STSDKBleNodeDefines.h"

#define COMMON_FEATURE_UUID @"-0001-11E1-AC36-0002A5D5C51B"

#define COMMON_SERVICE_UUID "-11E1-9AB4-0002A5D5C51B"

@implementation W2STSDKFeatureCharacteristics

+(featureMask_t)extractFeatureMask:(CBUUID *)uuid{
    featureMask_t featureMask;
    unsigned char *pointer =(unsigned char*) &featureMask;
    [uuid.data getBytes:(pointer+0) range:NSMakeRange(3,1)];
    [uuid.data getBytes:(pointer+1) range:NSMakeRange(2,1)];
    [uuid.data getBytes:(pointer+2) range:NSMakeRange(1,1)];
    [uuid.data getBytes:(pointer+3) range:NSMakeRange(0,1)];
    return featureMask;
}

+(bool) isFeatureCharacteristics:(CBUUID*)uuid{
    return [ uuid.UUIDString hasSuffix:COMMON_FEATURE_UUID];
}
@end

#define CONFIG_SERVICE_ID "000E"
#define CONFIG_SERICE_UUID @"00000000-"CONFIG_SERVICE_ID COMMON_SERVICE_UUID
#define COMMAND_CONFIG_CHAR_UUID @"00000001-"CONFIG_SERVICE_ID COMMON_FEATURE_UUID

@implementation W2STSDKServiceConfig
+(CBUUID*) serviceUuid{
    static CBUUID *service = nil;
    if(service==nil)
        service=[CBUUID UUIDWithString:CONFIG_SERICE_UUID ];
    return service;
}
+(CBUUID*) featureCommandUuid{
    static CBUUID *commandFeature =nil;
    if(commandFeature ==nil)
        commandFeature = [CBUUID UUIDWithString: COMMAND_CONFIG_CHAR_UUID];
    return commandFeature;
}
@end

#define DEBUG_SERVICE_ID "000F"
#define DEBUG_SERICE_UUID @"00000000-"DEBUG_SERVICE_ID COMMON_SERVICE_UUID
#define TEMR_DEBUG_CHAR_UUID @"00000001-"DEBUG_SERVICE_ID COMMON_FEATURE_UUID
#define STDERR_DEBUG_CHAR_UUID @"00000002-"DEBUG_SERVICE_ID COMMON_FEATURE_UUID

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
        term = [CBUUID UUIDWithString: STDERR_DEBUG_CHAR_UUID];
    return term;
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
static NSDictionary *boardFeatureMap = nil;
+(void)initialize{
    if(self == [W2STSDKBoardFeatureMap class]){
    nucleoFeatureMap = @{
                         @0x00200000: [W2STSDKFeature class], //gyo
                         @0x00400000: [W2STSDKFeature class], //gyo
                         @0x00800000: [W2STSDKFeature class] //acc
                         };
    
    boardFeatureMap = @{
                        @0x80:nucleoFeatureMap
                        };
    }
}
+(NSDictionary*) boardFeatureMap{
    return boardFeatureMap;
}


@end

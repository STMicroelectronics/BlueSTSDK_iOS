//
//  W2STSDKBleDefines.h
//  W2STApp
//
//  Created by Giovanni Visentini on 27/03/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef W2STApp_W2STSDKBleNodeDefines_h
#define W2STApp_W2STSDKBleNodeDefines_h

#import <CoreBluetooth/CoreBluetooth.h>

typedef uint32_t featureMask_t;

@interface W2STSDKFeatureCharacteristics : NSObject

    +(featureMask_t)extractFeatureMask:(CBUUID *)uuid;
    +(bool) isFeatureCharacteristics:(CBUUID*)uuid;
@end

@interface W2STSDKServiceDebug: NSObject
+(CBUUID*) serviceUuid;
+(CBUUID*) stdErrUuid;
+(CBUUID*) termUuid;
+(bool) isDebugCharacteristics:(CBCharacteristic*) c;
@end

@interface W2STSDKServiceConfig: NSObject
+(CBUUID*) serviceUuid;
+(CBUUID*) featureCommandUuid;
@end

@interface W2STSDKServices : NSObject

+(W2STSDKServiceDebug*) debugService;
+(W2STSDKServiceConfig*) configService;

@end

@interface W2STSDKBoardFeatureMap : NSObject

+(NSDictionary*) boardFeatureMap;
+(void)initialize;
@end


#endif

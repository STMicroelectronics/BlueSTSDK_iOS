//
//  W2STSDKTools.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 06/06/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "W2STSDKDefine.h"

W2STSDK_EXTERN NSString * const W2STSDKNodeChangeGenericKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeAddedKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeUpdatedKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeDeadKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeResumedKey;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeDeletedKey;

W2STSDK_EXTERN NSString * const W2STSDKNodeChangeRSSIVal;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeDataVal;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeConfigVal;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeAdvertisementVal;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeAllVal;
W2STSDK_EXTERN NSString * const W2STSDKNodeChangeTxPowerVal;

@interface W2STSDKTools : NSObject

+(NSString *)nodeChangeComponentsStr:(NSString *)str field:(NSString *)field;
+(NSString *)nodeChangeMakeStr:(NSString *)key val:(NSString *)val;

//tools
+(void) trace:(CBPeripheral *)peripheral text:(NSString *)text;
+(void) tracePeripherals:(NSArray *)peripherals text:(NSString *)text;

@end

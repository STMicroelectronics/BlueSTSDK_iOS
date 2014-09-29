//
//  W2STSDKDefine.h
//  W2STSDK-CB
//
//  Created by Antonino Raucea on 14/04/14.
//  Copyright (c) 2014 STMicroelectronics. All rights reserved.
//

//internal defines

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>



#ifndef W2STSDK_EXTERN
#ifdef __cplusplus
#define W2STSDK_EXTERN extern "C" __attribute__((visibility ("default")))
#else
#define W2STSDK_EXTERN extern __attribute__((visibility ("default")))
#endif
#endif

#define W2STSDK_EXTERN_CLASS __attribute__((visibility("default")))

typedef NS_ENUM(NSUInteger, W2STSDKParamType) {
    W2STSDKNodeParamTypeUnknown,
    W2STSDKNodeParamTypeInt8,
    W2STSDKNodeParamTypeInt16,
    W2STSDKNodeParamTypeInt32,
    W2STSDKNodeParamTypeUInt8,
    W2STSDKNodeParamTypeUInt16,
    W2STSDKNodeParamTypeUInt32,
    W2STSDKNodeParamTypeFloat,
    W2STSDKNodeParamTypeDouble,
    //W2STSDKNodeParamTypeLpszChar,
    //W2STSDKNodeParamTypeBuffer,
};

#define W2STSDKNodeParamTypeNumber(type)     [NSNumber numberWithInt:(int)(type)]
#define W2STSDKNodeParamTypeIntValue(num)    ((W2STSDKParamType)[num intValue])

#define W2STSDKNodeParamTypeUnknownNumber    W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeUnknown)
#define W2STSDKNodeParamTypeInt8Number       W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeInt8)
#define W2STSDKNodeParamTypeInt16Number      W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeInt16)
#define W2STSDKNodeParamTypeInt32Number      W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeInt32)
#define W2STSDKNodeParamTypeUInt8Number      W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeUInt8)
#define W2STSDKNodeParamTypeUInt16Number     W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeUInt16)
#define W2STSDKNodeParamTypeUInt32Number     W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeUInt32)
#define W2STSDKNodeParamTypeFloatNumber      W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeFloat)
#define W2STSDKNodeParamTypeDoubleNumber     W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeDouble)
//#define W2STSDKNodeParamTypeLpszCharNumber   W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeLpszChar)
//#define W2STSDKNodeParamTypeBufferNumber     W2STSDKNodeParamTypeNumber((int)W2STSDKNodeParamTypeBuffer)

#define DEAD_TIME 2.0 //sec
#define BUFFER_SIZE 16

#import "W2STSDK.h"
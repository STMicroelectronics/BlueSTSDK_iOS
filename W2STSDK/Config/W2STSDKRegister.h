//
//  W2STSDKRegister.h
//
//  Created by Antonino Raucea on 06/15/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef W2STSDKRegister_h
#define W2STSDKRegister_h

#import <Foundation/Foundation.h>

@interface W2STSDKRegister : NSObject

#define W2STSDK_REGISTER_HEADER_Empty {0xFF,0xFF,0xFF,0xFF}
#define W2STSDK_REGISTER_HEADER_Init(pheader) memset(pheader, sizeof(W2STSDKRegisterHeader_t), 0xFF)
#define W2STSDK_REGISTER_HEADER_IsEmpty(pheader) (*((unsigned char *)pheader) == 0xFF)
typedef struct {
    unsigned char ctrl;
    unsigned char addr;
    unsigned char err;
    unsigned char len;
} W2STSDKRegisterHeader_t;

#define W2STSDK_REGISTER_ACCESS_Is(value, access) (((value) & (access)) == (access))
#define W2STSDK_REGISTER_ACCESS_IsReadable(value) W2STSDK_REGISTER_ACCESS_Is(value, W2STSDK_REGISTER_ACCESS_R)
#define W2STSDK_REGISTER_ACCESS_IsWritable(value) W2STSDK_REGISTER_ACCESS_Is(value, W2STSDK_REGISTER_ACCESS_W)

typedef NS_ENUM(NSInteger, W2STSDKRegisterAccess_e) {
    W2STSDK_REGISTER_ACCESS_R = 0x1,
    W2STSDK_REGISTER_ACCESS_W = 0x2,
    W2STSDK_REGISTER_ACCESS_RW = W2STSDK_REGISTER_ACCESS_R | W2STSDK_REGISTER_ACCESS_W,
};

#define W2STSDK_REGISTER_TARGET_Is(value, target) (((value) & (target)) == (target))
#define W2STSDK_REGISTER_TARGET_IsPersistent(value) W2STSDK_REGISTER_TARGET_Is(value, W2STSDK_REGISTER_TARGET_PERSISTENT)
#define W2STSDK_REGISTER_TARGET_IsSession(value) W2STSDK_REGISTER_TARGET_Is(value, W2STSDK_REGISTER_TARGET_SESSION)
typedef NS_ENUM(NSInteger,  W2STSDKRegisterTarget_e) {
    W2STSDK_REGISTER_TARGET_PERSISTENT = 0x01,
    W2STSDK_REGISTER_TARGET_SESSION = 0x02,
    W2STSDK_REGISTER_TARGET_BOTH = W2STSDK_REGISTER_TARGET_PERSISTENT | W2STSDK_REGISTER_TARGET_SESSION,
};

@property (assign, nonatomic) NSInteger address;
@property (assign, nonatomic) W2STSDKRegisterAccess_e access;
@property (assign, nonatomic) W2STSDKRegisterTarget_e target;
@property (assign, nonatomic) NSInteger size;

/**
 * Constructors for Register class
 */
+(id)registerWithAddress:(NSInteger)address size:(NSInteger)size access:(W2STSDKRegisterAccess_e)access target:(W2STSDKRegisterTarget_e)target;
+(id)registerWithAddress:(NSInteger)address size:(NSInteger)size;
+(id)registerWithAddress:(NSInteger)address size:(NSInteger)size access:(W2STSDKRegisterAccess_e)access;
+(id)registerWithAddress:(NSInteger)address size:(NSInteger)size target:(W2STSDKRegisterTarget_e)target;
-(id)initWithAddress:(NSInteger)address size:(NSInteger)size access:(W2STSDKRegisterAccess_e)access target:(W2STSDKRegisterTarget_e)target;

+(id)registerWithData:(NSData *)data;
-(id)initWithData:(NSData *)data;

-(void)setHeader:(W2STSDKRegisterHeader_t *)pheader target:(W2STSDKRegisterTarget_e)target  write:(BOOL)write ack:(BOOL)ack;
-(NSData *)toReadPacketWithTarget:(W2STSDKRegisterTarget_e)target;
-(NSData *)toWritePacketWithTarget:(W2STSDKRegisterTarget_e)target payloadData:(NSData *)payloadData;

+(NSData *)getPayloadFromData:(NSData *)data;
+(BOOL)getHeaderFromData:(NSData *)data header:(W2STSDKRegisterHeader_t *)pheader;

+(W2STSDKRegisterTarget_e)getTargetFromData:(NSData *)data;
+(BOOL)isWriteOperationFromData:(NSData *)data;
+(BOOL)isReadOperationFromData:(NSData *)data;
+(NSInteger)getAddressFromData:(NSData *)data;
+(NSInteger)getErrorFromData:(NSData *)data;
+(NSInteger)getSizeFromData:(NSData *)data;
@end

#endif //W2STSDKRegister_h
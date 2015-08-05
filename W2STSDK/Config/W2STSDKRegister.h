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

/**
 * Type used for register access type
 */
typedef NS_ENUM(NSInteger, W2STSDKRegisterAccess_e) {
    W2STSDK_REGISTER_ACCESS_R = 0x1,
    W2STSDK_REGISTER_ACCESS_W = 0x2,
    W2STSDK_REGISTER_ACCESS_RW = W2STSDK_REGISTER_ACCESS_R | W2STSDK_REGISTER_ACCESS_W,
};

#define W2STSDK_REGISTER_ACCESS_Is(value, access) (((value) & (access)) == (access))
#define W2STSDK_REGISTER_ACCESS_IsReadable(value) W2STSDK_REGISTER_ACCESS_Is(value, W2STSDK_REGISTER_ACCESS_R)
#define W2STSDK_REGISTER_ACCESS_IsWritable(value) W2STSDK_REGISTER_ACCESS_Is(value, W2STSDK_REGISTER_ACCESS_W)

/**
 * Type used for register store target
 */
typedef NS_ENUM(NSInteger,  W2STSDKRegisterTarget_e) {
    W2STSDK_REGISTER_TARGET_PERSISTENT = 0x01,
    W2STSDK_REGISTER_TARGET_SESSION = 0x02,
    W2STSDK_REGISTER_TARGET_BOTH = W2STSDK_REGISTER_TARGET_PERSISTENT | W2STSDK_REGISTER_TARGET_SESSION,
};
#define W2STSDK_REGISTER_TARGET_Is(value, target) (((value) & (target)) == (target))
#define W2STSDK_REGISTER_TARGET_IsPersistent(value) W2STSDK_REGISTER_TARGET_Is(value, W2STSDK_REGISTER_TARGET_PERSISTENT)
#define W2STSDK_REGISTER_TARGET_IsSession(value) W2STSDK_REGISTER_TARGET_Is(value, W2STSDK_REGISTER_TARGET_SESSION)

/**
 * Register address
 */
@property (assign, nonatomic) NSInteger address;
/**
 * Access type
 */
@property (assign, nonatomic) W2STSDKRegisterAccess_e access;
/**
 * Target operation
 */
@property (assign, nonatomic) W2STSDKRegisterTarget_e target;
/**
 * Register size (short)
 */
@property (assign, nonatomic) NSInteger size;

/**
 * Create an instance of the Register class
 * @param address filed unit
 * @param size field size
 * @param access register mode access
 * @param target register target
 */
+(instancetype)registerWithAddress:(NSInteger)address size:(NSInteger)size
                            access:(W2STSDKRegisterAccess_e)access
                            target:(W2STSDKRegisterTarget_e)target;
/**
 * Create an instance of the Register class
 * @param address field unit
 * @param size field size
 */
+(instancetype)registerWithAddress:(NSInteger)address size:(NSInteger)size;
/**
 * Create an instance of the Register class
 * @param address filed unit
 * @param size field size
 * @param access register mode access
 */
+(instancetype)registerWithAddress:(NSInteger)address size:(NSInteger)size
                            access:(W2STSDKRegisterAccess_e)access;
/**
 * Create an instance of the Register class
 * @param address filed unit
 * @param size field size
 * @param target register target
 */
+(instancetype)registerWithAddress:(NSInteger)address size:(NSInteger)size
                            target:(W2STSDKRegisterTarget_e)target;

/**
 * Basic constructor of the Register class
 * @param address filed unit
 * @param size field size
 * @param access register mode access
 * @param target register target
 */
-(instancetype)initWithAddress:(NSInteger)address size:(NSInteger)size
                        access:(W2STSDKRegisterAccess_e)access
                        target:(W2STSDKRegisterTarget_e)target;
/**
 * Instance creation for Register class from a buffer of data
 * @param data buffer of data with all the information
 * @return instance of Register class
 */
+(instancetype)registerWithData:(NSData *)data;

/**
 * Constructor for Register class from a buffer of data
 * @param data array of byte with all the information
 * @return instance of Register class
 */
-(instancetype)initWithData:(NSData *)data;

/**
 * fill buffer header for the mode with proper write/read options and ack
 * @param pHeader buffer to fill
 * @param target Target memory Persistent/Session
 * @param write write or read
 * @param ack ack required
 */
-(void)setHeader:(W2STSDKRegisterHeader_t *)pHeader
          target:(W2STSDKRegisterTarget_e)target
           write:(BOOL)write
             ack:(BOOL)ack;
/**
 * Get the data for read the register
 * @param target Mode Persistent/Session
 *
 * @return the packet (buffer) to send to the device to read the register
 */
-(NSData *)toReadPacketWithTarget:(W2STSDKRegisterTarget_e)target;

/**
 * Get the data for write the register
 * @param target Mode Persistent/Session
 * @param payloadData data to write in the device register
 *
 * @return the packet (buffer) to send to the device to write the register with the value
 * defined in the payload
 */
-(NSData *)toWritePacketWithTarget:(W2STSDKRegisterTarget_e)target payloadData:(NSData *)payloadData;
/**
 * Get the payload of the read register
 * @param data packet received from the device
 *
 * @return the value(s) of the read registers
 */
+(NSData *)getPayloadFromData:(NSData *)data;
/**
 * Get the header of the read command
 * @param data packet received from the device
 * @param pheader pointer to packet received from the device
 *
 * @return the value(s) of the read registers
 */
+(BOOL)getHeaderFromData:(NSData *)data header:(W2STSDKRegisterHeader_t *)pheader;

/**
 * Get the Target of the received register
 * @param data packet received from the device
 *
 * @return the Target of the read registers
 */
+(W2STSDKRegisterTarget_e)getTargetFromData:(NSData *)data;
/**
 * Check if the data is for a write operation
 * @param data packet received from the device
 *
 * @return true if write bit is set
 */
+(BOOL)isWriteOperationFromData:(NSData *)data;
/**
 * Check if the data is for a write operation
 * @param data packet received from the device
 *
 * @return true if Read bit is set
 */
+(BOOL)isReadOperationFromData:(NSData *)data;
/**
 * Get the address of the received register
 * @param data packet received from the device
 *
 * @return the address of the register read or write operation
 */
+(NSInteger)getAddressFromData:(NSData *)data;
/**
 * Get the error of the received register
 * @param data packet received from the device
 *
 * @return the error code of the register read or write operation
 */
+(NSInteger)getErrorFromData:(NSData *)data;
/**
 * Get the size of the received register
 * @param data packet received from the device
 *
 * @return the size of the register read or write operation
 */
+(NSInteger)getSizeFromData:(NSData *)data;
@end

#endif //W2STSDKRegister_h
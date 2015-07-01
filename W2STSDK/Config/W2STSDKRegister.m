//
//  W2STSDKRegister.c
//
//  Created by Antonino Raucea on 06/15/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#import "W2STSDKRegister.h"

@implementation W2STSDKRegister

/**
 * Instance creation for Register class
 * @param address field
 * @param size field
 * @param access field
 * @param target field
 * @return instance of Register class
 */
+(id)registerWithAddress:(NSInteger)address size:(NSInteger)size access:(W2STSDKRegisterAccess_e)access target:(W2STSDKRegisterTarget_e)target {
    return [[W2STSDKRegister alloc] initWithAddress:address size:size access:access target:target];
}

/**
 * Instance creation for Register class (access and target are set to default values RW and PS)
 * @param address filed unit
 * @param size field size
 * @return instance of Register class
 */
+(id)registerWithAddress:(NSInteger)address size:(NSInteger)size {
    return [[W2STSDKRegister alloc] initWithAddress:address size:size access:W2STSDK_REGISTER_ACCESS_RW target:W2STSDK_REGISTER_TARGET_BOTH];
}

/**
 * Instance creation for Register class (target is set to default value PS)
 * @param address field
 * @param size field
 * @param access field
 * @return instance of Register class
 */
+(id)registerWithAddress:(NSInteger)address size:(NSInteger)size access:(W2STSDKRegisterAccess_e)access {
    return [[W2STSDKRegister alloc] initWithAddress:address size:size access:access target:W2STSDK_REGISTER_TARGET_BOTH];
}

/**
 * Instance creation for Register class (access is set to default value RW)
 * @param address field
 * @param size field
 * @param target field
 * @return instance of Register class
 */
+(id)registerWithAddress:(NSInteger)address size:(NSInteger)size target:(W2STSDKRegisterTarget_e)target {
    return [[W2STSDKRegister alloc] initWithAddress:address size:size access:W2STSDK_REGISTER_ACCESS_RW target:target];
}

/**
 * Constructor for Register class
 * @param address field
 * @param size field
 * @param access field
 * @param target field
 * @return instance of Register class
 */
-(id)initWithAddress:(NSInteger)address size:(NSInteger)size access:(W2STSDKRegisterAccess_e)access target:(W2STSDKRegisterTarget_e)target {
    self = [[W2STSDKRegister alloc] init];
    self.address = address;
    self.access = access;
    self.size = size;
    
    return self;
}

/**
 * Instance creation for Register class from a buffer of data
 * @param data
 * @return instance of Register class
 */
+(id)registerWithData:(NSData *)data {
    return [[W2STSDKRegister alloc] initWithData:data];
}

/**
 * Constructor for Register class from a buffer of data
 * @param data
 * @return instance of Register class
 */
-(id)initWithData:(NSData *)data {
    return [W2STSDKRegister registerWithAddress:[W2STSDKRegister getAddressFromData:data]
                                           size:[W2STSDKRegister getSizeFromData:data]
                                         access:W2STSDK_REGISTER_ACCESS_RW
                                         target:[W2STSDKRegister getTargetFromData:data]];
}


/**
 * fill buffer header for the mode with proper write/read options and ack
 * @param header buffer to fill
 * @param target Target memory Persistent/Session
 * @param write write or read
 * @param ack ack required
 */
-(void)setHeader:(W2STSDKRegisterHeader_t *)pheader target:(W2STSDKRegisterTarget_e)target  write:(BOOL)write ack:(BOOL)ack {
    
    if (!pheader) {
        return;
    }

    pheader->ctrl = (unsigned char) (0x80 |                          //Exec op -- forced
                        ((target == W2STSDK_REGISTER_TARGET_PERSISTENT) ? 0x40 : 0x00) | //target register session vs persistent
                        (write ? 0x20 : 0x00) |                     //Write or Read operation
                        (ack ? 0x08 : 0x00));                       //Ack required
    pheader->addr = (unsigned char) self.address;
    pheader->len  = (unsigned char) 0;
    pheader->len  = (unsigned char) self.size;
}

/**
 * Get the buffer for read the register
 * @param target Mode Persistent/Session
 *
 * @return the packet (buffer) to send to the device to read the register
 */
-(NSData *)toReadPacketWithTarget:(W2STSDKRegisterTarget_e)target {
    NSData * data = [NSData data];
    if (W2STSDK_REGISTER_ACCESS_IsReadable(self.access)) {
        unsigned char buffer[sizeof(W2STSDKRegisterHeader_t)];
        W2STSDKRegisterHeader_t * pheader = (W2STSDKRegisterHeader_t *)buffer;
        [self setHeader:pheader target:target write:NO ack:NO];
        data = [NSData dataWithBytes:buffer length:sizeof(buffer)];
    }
    return data;
}

/**
 * Get the buffer for write the register
 * @param target Mode Persistent/Session
 * @param payload data to write in the device register
 *
 * @return the packet (buffer) to send to the device to write the register with the value
 * defined in the payload
 */
-(NSData *)toWritePacketWithTarget:(W2STSDKRegisterTarget_e)target payloadData:(NSData *)payloadData {
    
    NSData * data = [NSData data];
    if (payloadData) {
        size_t plen = payloadData.length;
        if ((W2STSDK_REGISTER_ACCESS_IsWritable(self.access)) &&
            plen <= self.size * 2) {
            size_t len = sizeof(W2STSDKRegisterHeader_t) + plen;
            unsigned char buffer[len];
            W2STSDKRegisterHeader_t * pheader = (W2STSDKRegisterHeader_t *)buffer;
            unsigned char * ppayload = (unsigned char *)(buffer + sizeof(W2STSDKRegisterHeader_t));
            
            [self setHeader:pheader target:target write:YES ack:YES];
            [payloadData getBytes:ppayload length:plen];
            data = [NSData dataWithBytes:buffer length:sizeof(buffer)];
        }
    }
    return data;
}

/**
 * Get the payload of the read register
 * @param data received from the device
 *
 * @return the data of the read registers
 */
+(NSData *)getPayloadFromData:(NSData *)data {
    NSData *payloadData = [NSData data];
    if (data.length > 4) {
        payloadData = [data subdataWithRange:NSMakeRange(4, data.length - 4)];
    }
    
    return  payloadData;
}

/**
 * Get the Header of the received register
 * @param data received from the device
 *
 * @return the Header of the read registers
 */
+(BOOL)getHeaderFromData:(NSData *)data header:(W2STSDKRegisterHeader_t *)pheader {
    BOOL ret = NO;
    if (pheader) {
        W2STSDK_REGISTER_HEADER_Init(pheader);
        if (data && data.length >= 4) {
            [data getBytes:(void *)pheader length:sizeof(W2STSDKRegisterHeader_t)];
            ret = YES;
        }
    }
    return ret;
}
/**
 * Get the Target of the received register
 * @param data received from the device
 *
 * @return the Mode of the read registers
 */
+(W2STSDKRegisterTarget_e)getTargetFromData:(NSData *)data {
    W2STSDKRegisterHeader_t header = W2STSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    W2STSDKRegisterTarget_e ret = W2STSDK_REGISTER_TARGET_SESSION;
    if (res) ret = (header.ctrl & 0x40) == 0x40 ? W2STSDK_REGISTER_TARGET_PERSISTENT : W2STSDK_REGISTER_TARGET_SESSION;
    return ret;
}

/**
 * Check if the buffer is for a write operation
 * @param data received from the device
 *
 * @return true if write bit is set
 */
+(BOOL)isWriteOperationFromData:(NSData *)data {
    W2STSDKRegisterHeader_t header = W2STSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    return res && ((header.ctrl & 0x20) == 0x20 );
}

/**
 * Check if the buffer is for a write operation
 * @param data received from the device
 *
 * @return true if Read bit is set
 */
+(BOOL)isReadOperationFromData:(NSData *)data {
    return ![self isWriteOperationFromData:data];
}


/**
 * Get the address of the received register
 * @param data received from the device
 *
 * @return the address of the register read or write operation
 */
+(NSInteger)getAddressFromData:(NSData *)data {
    W2STSDKRegisterHeader_t header = W2STSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    return res ? header.addr : -1;
}

/**
 * Get the error of the received register
 * @param data received from the device
 *
 * @return the error code of the register read or write operation
 */
+(NSInteger)getErrorFromData:(NSData *)data {
    W2STSDKRegisterHeader_t header = W2STSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    return res ? header.err : -1;
}

/**
 * Get the size of the received register
 * @param data received from the device
 *
 * @return the size of the register read or write operation
 */
+(NSInteger)getSizeFromData:(NSData *)data {
    W2STSDKRegisterHeader_t header = W2STSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    return res ? header.len : -1;
}

@end
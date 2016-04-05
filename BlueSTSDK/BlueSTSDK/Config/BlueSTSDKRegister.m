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

#import "BlueSTSDKRegister.h"

@implementation BlueSTSDKRegister

/**
 * Instance creation for Register class
 * @param address field
 * @param size field
 * @param access field
 * @param target field
 * @return instance of Register class
 */
+(instancetype)registerWithAddress:(NSInteger)address size:(NSInteger)size
                            access:(BlueSTSDKRegisterAccess_e)access
                            target:(BlueSTSDKRegisterTarget_e)target {
    return [[BlueSTSDKRegister alloc] initWithAddress:address size:size access:access target:target];
}

/**
 * Instance creation for Register class (access and target are set to default values RW and PS)
 * @param address filed unit
 * @param size field size
 * @return instance of Register class
 */
+(instancetype)registerWithAddress:(NSInteger)address size:(NSInteger)size {
    return [[BlueSTSDKRegister alloc] initWithAddress:address
                                               size:size
                                             access:BlueSTSDK_REGISTER_ACCESS_RW
                                             target:BlueSTSDK_REGISTER_TARGET_BOTH];
}

/**
 * Instance creation for Register class (target is set to default value PS)
 * @param address field
 * @param size field
 * @param access field
 * @return instance of Register class
 */
+(instancetype)registerWithAddress:(NSInteger)address size:(NSInteger)size
                            access:(BlueSTSDKRegisterAccess_e)access {
    return [[BlueSTSDKRegister alloc] initWithAddress:address size:size
                                             access:access
                                             target:BlueSTSDK_REGISTER_TARGET_BOTH];
}

/**
 * Instance creation for Register class (access is set to default value RW)
 * @param address field
 * @param size field
 * @param target field
 * @return instance of Register class
 */
+(instancetype)registerWithAddress:(NSInteger)address size:(NSInteger)size
                            target:(BlueSTSDKRegisterTarget_e)target {
    return [[BlueSTSDKRegister alloc] initWithAddress:address size:size
                                             access:BlueSTSDK_REGISTER_ACCESS_RW
                                             target:target];
}

/**
 * Constructor for Register class
 * @param address field
 * @param size field
 * @param access field
 * @param target field
 * @return instance of Register class
 */
-(instancetype)initWithAddress:(NSInteger)address size:(NSInteger)size
                        access:(BlueSTSDKRegisterAccess_e)access
                        target:(BlueSTSDKRegisterTarget_e)target {
    self = [[BlueSTSDKRegister alloc] init];
    self.address = address;
    self.access = access;
    self.size = size;
    self.target = target;
    
    return self;
}

/**
 * Instance creation for Register class from a buffer of data
 * @param data buffer of data with all the information
 * @return instance of Register class
 */
+(instancetype)registerWithData:(NSData *)data {
    return [[BlueSTSDKRegister alloc] initWithData:data];
}

/**
 * Constructor for Register class from a buffer of data
 * @param data array of byte with all the information
 * @return instance of Register class
 */
-(instancetype)initWithData:(NSData *)data {
    return [BlueSTSDKRegister registerWithAddress:[BlueSTSDKRegister getAddressFromData:data]
                                           size:[BlueSTSDKRegister getSizeFromData:data]
                                         access:BlueSTSDK_REGISTER_ACCESS_RW
                                         target:[BlueSTSDKRegister getTargetFromData:data]];
}


/**
 * fill buffer header for the mode with proper write/read options and ack
 * @param pHeader buffer to fill
 * @param target Target memory Persistent/Session
 * @param write write or read
 * @param ack ack required
 */
-(void)setHeader:(BlueSTSDKRegisterHeader_t *)pHeader
          target:(BlueSTSDKRegisterTarget_e)target
           write:(BOOL)write ack:(BOOL)ack {
    
    if (!pHeader) {
        return;
    }
    
    pHeader->ctrl = (unsigned char) (0x80 |                          //Exec op -- forced
                                     ((target == BlueSTSDK_REGISTER_TARGET_PERSISTENT) ? 0x40 : 0x00) | //target register session vs persistent
                                     (write ? 0x20 : 0x00) |                     //Write or Read operation
                                     (ack ? 0x08 : 0x00));                       //Ack required
    pHeader->addr = (unsigned char) self.address;
    pHeader->err  = (unsigned char) 0;
    pHeader->len  = (unsigned char) self.size;
}

/**
 * Get the buffer for read the register
 * @param target Mode Persistent/Session
 *
 * @return the packet (buffer) to send to the node to read the register
 */
-(NSData *)toReadPacketWithTarget:(BlueSTSDKRegisterTarget_e)target {
    NSData * data = [NSData data];
    if (BlueSTSDK_REGISTER_ACCESS_IsReadable(self.access)) {
        unsigned char buffer[sizeof(BlueSTSDKRegisterHeader_t)];
        BlueSTSDKRegisterHeader_t * pheader = (BlueSTSDKRegisterHeader_t *)buffer;
        [self setHeader:pheader target:target write:NO ack:YES];
        data = [NSData dataWithBytes:buffer length:sizeof(buffer)];
    }
    return data;
}

/**
 * Get the buffer for write the register
 * @param target Mode Persistent/Session
 * @param payloadData data to write in the node register
 *
 * @return the packet (buffer) to send to the node to write the register with the value
 * defined in the payload
 */
-(NSData *)toWritePacketWithTarget:(BlueSTSDKRegisterTarget_e)target
                       payloadData:(NSData *)payloadData {
    
    NSData * data = [NSData data];
    if (payloadData) {
        size_t plen = payloadData.length;
        if ((BlueSTSDK_REGISTER_ACCESS_IsWritable(self.access)) &&
            plen <= self.size * 2) {
            size_t len = sizeof(BlueSTSDKRegisterHeader_t) + plen;
            unsigned char buffer[len];
            BlueSTSDKRegisterHeader_t * pheader = (BlueSTSDKRegisterHeader_t *)buffer;
            unsigned char * ppayload = (unsigned char *)(buffer + sizeof(BlueSTSDKRegisterHeader_t));
            
            [self setHeader:pheader target:target write:YES ack:YES];
            [payloadData getBytes:ppayload length:plen];
            data = [NSData dataWithBytes:buffer length:sizeof(buffer)];
        }
    }
    return data;
}

/**
 * Get the payload of the read register
 * @param data received from the node
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
 * @param data received from the node
 *
 * @return the Header of the read registers
 */
+(BOOL)getHeaderFromData:(NSData *)data header:(BlueSTSDKRegisterHeader_t *)pheader {
    BOOL ret = NO;
    if (pheader) {
        //BlueSTSDK_REGISTER_HEADER_Init(pheader);
        if (data && data.length >= 4) {
            unsigned char buffer[data.length];
            [data getBytes:(void *)buffer length:4];
            
            pheader->ctrl = buffer[0];
            pheader->addr = buffer[1];
            pheader->err = buffer[2];
            pheader->len = buffer[3];
            
            ret = YES;
        }
    }
    return ret;
}

/**
 * Get the Target of the received register
 * @param data received from the node
 *
 * @return the Mode of the read registers
 */
+(BlueSTSDKRegisterTarget_e)getTargetFromData:(NSData *)data {
    BlueSTSDKRegisterHeader_t header = BlueSTSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    BlueSTSDKRegisterTarget_e ret = BlueSTSDK_REGISTER_TARGET_SESSION;
    if (res) ret = (header.ctrl & 0x40) == 0x40 ? BlueSTSDK_REGISTER_TARGET_PERSISTENT : BlueSTSDK_REGISTER_TARGET_SESSION;
    return ret;
}

/**
 * Check if the buffer is for a write operation
 * @param data received from the node
 *
 * @return true if write bit is set
 */
+(BOOL)isWriteOperationFromData:(NSData *)data {
    BlueSTSDKRegisterHeader_t header = BlueSTSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    return res && ((header.ctrl & 0x20) == 0x20 );
}

/**
 * Check if the buffer is for a write operation
 * @param data received from the node
 *
 * @return true if Read bit is set
 */
+(BOOL)isReadOperationFromData:(NSData *)data {
    return ![self isWriteOperationFromData:data];
}


/**
 * Get the address of the received register
 * @param data received from the node
 *
 * @return the address of the register read or write operation
 */
+(NSInteger)getAddressFromData:(NSData *)data {
    BlueSTSDKRegisterHeader_t header = BlueSTSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    return res ? header.addr : -1;
}

/**
 * Get the error of the received register
 * @param data received from the node
 *
 * @return the error code of the register read or write operation
 */
+(NSInteger)getErrorFromData:(NSData *)data {
    BlueSTSDKRegisterHeader_t header = BlueSTSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    return res ? header.err : -1;
}

/**
 * Get the size of the received register
 * @param data received from the node
 *
 * @return the size of the register read or write operation
 */
+(NSInteger)getSizeFromData:(NSData *)data {
    BlueSTSDKRegisterHeader_t header = BlueSTSDK_REGISTER_HEADER_Empty;
    BOOL res = [self getHeaderFromData:data header:&header];
    return res ? header.len : -1;
}

-(NSString *)description {
    NSString *accessstr = @"NN";
    switch(self.access)
    {
        case BlueSTSDK_REGISTER_ACCESS_R:
            accessstr = @"R ";
            break;
        case BlueSTSDK_REGISTER_ACCESS_W:
            accessstr = @"W ";
            break;
        case BlueSTSDK_REGISTER_ACCESS_RW:
            accessstr = @"RW";
            break;
    }
    NSString *targetstr = @"-";
    switch(self.target)
    {
        case BlueSTSDK_REGISTER_TARGET_PERSISTENT:
            targetstr = @"P";
            break;
        case BlueSTSDK_REGISTER_TARGET_SESSION:
            targetstr = @"S";
            break;
        case BlueSTSDK_REGISTER_TARGET_BOTH:
            targetstr = @"B";
            break;
    }
    return [NSString stringWithFormat:@"Addr:%0.2X A:%@ T:%@ S:%d",(unsigned char)self.address, accessstr, targetstr, (unsigned char)self.size];
}
@end

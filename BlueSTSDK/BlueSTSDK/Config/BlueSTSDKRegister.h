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

#ifndef BlueSTSDKRegister_h
#define BlueSTSDKRegister_h

#import <Foundation/Foundation.h>

@interface BlueSTSDKRegister : NSObject

#define BlueSTSDK_REGISTER_HEADER_Empty {0xFF,0xFF,0xFF,0xFF}
#define BlueSTSDK_REGISTER_HEADER_Init(pheader) memset(pheader, sizeof(BlueSTSDKRegisterHeader_t), 0xFF)
#define BlueSTSDK_REGISTER_HEADER_IsEmpty(pheader) (*((unsigned char *)pheader) == 0xFF)
typedef struct {
    unsigned char ctrl;
    unsigned char addr;
    unsigned char err;
    unsigned char len;
} BlueSTSDKRegisterHeader_t;

/**
 * Type used for register access type
 */
typedef NS_ENUM(NSInteger, BlueSTSDKRegisterAccess_e) {
    BlueSTSDK_REGISTER_ACCESS_R = 0x1,
    BlueSTSDK_REGISTER_ACCESS_W = 0x2,
    BlueSTSDK_REGISTER_ACCESS_RW = BlueSTSDK_REGISTER_ACCESS_R | BlueSTSDK_REGISTER_ACCESS_W,
};

#define BlueSTSDK_REGISTER_ACCESS_Is(value, access) (((value) & (access)) == (access))
#define BlueSTSDK_REGISTER_ACCESS_IsReadable(value) BlueSTSDK_REGISTER_ACCESS_Is(value, BlueSTSDK_REGISTER_ACCESS_R)
#define BlueSTSDK_REGISTER_ACCESS_IsWritable(value) BlueSTSDK_REGISTER_ACCESS_Is(value, BlueSTSDK_REGISTER_ACCESS_W)

/**
 * Type used for register store target
 */
typedef NS_ENUM(NSInteger,  BlueSTSDKRegisterTarget_e) {
    BlueSTSDK_REGISTER_TARGET_PERSISTENT = 0x01,
    BlueSTSDK_REGISTER_TARGET_SESSION = 0x02,
    BlueSTSDK_REGISTER_TARGET_BOTH = 0x03
};

#define BlueSTSDK_REGISTER_TARGET_Is(value, target) (((value) & (target)) == (target))
#define BlueSTSDK_REGISTER_TARGET_IsPersistent(value) BlueSTSDK_REGISTER_TARGET_Is(value, BlueSTSDK_REGISTER_TARGET_PERSISTENT)
#define BlueSTSDK_REGISTER_TARGET_IsSession(value) BlueSTSDK_REGISTER_TARGET_Is(value, BlueSTSDK_REGISTER_TARGET_SESSION)

/**
 * Register address
 */
@property (assign, nonatomic) NSInteger address;
/**
 * Access type
 */
@property (assign, nonatomic) BlueSTSDKRegisterAccess_e access;
/**
 * Target operation
 */
@property (assign, nonatomic) BlueSTSDKRegisterTarget_e target;
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
                            access:(BlueSTSDKRegisterAccess_e)access
                            target:(BlueSTSDKRegisterTarget_e)target;
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
                            access:(BlueSTSDKRegisterAccess_e)access;
/**
 * Create an instance of the Register class
 * @param address filed unit
 * @param size field size
 * @param target register target
 */
+(instancetype)registerWithAddress:(NSInteger)address size:(NSInteger)size
                            target:(BlueSTSDKRegisterTarget_e)target;


/**
 * Basic constructor of the Register class
 * @param address filed unit
 * @param size field size
 * @param access register mode access
 * @param target register target
 */
-(instancetype)initWithAddress:(NSInteger)address size:(NSInteger)size
                        access:(BlueSTSDKRegisterAccess_e)access
                        target:(BlueSTSDKRegisterTarget_e)target;
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
-(void)setHeader:(BlueSTSDKRegisterHeader_t *)pHeader
          target:(BlueSTSDKRegisterTarget_e)target
           write:(BOOL)write
             ack:(BOOL)ack;

/**
 * Get the data for read the register
 * @param target Mode Persistent/Session
 *
 * @return the packet (buffer) to send to the node to read the register
 */
-(NSData *)toReadPacketWithTarget:(BlueSTSDKRegisterTarget_e)target;

/**
 * Get the data for write the register
 * @param target Mode Persistent/Session
 * @param payloadData data to write in the node register
 *
 * @return the packet (buffer) to send to the node to write the register with the value
 * defined in the payload
 */
-(NSData *)toWritePacketWithTarget:(BlueSTSDKRegisterTarget_e)target payloadData:(NSData *)payloadData;
/**
 * Get the payload of the read register
 * @param data packet received from the node
 *
 * @return the value(s) of the read registers
 */
+(NSData *)getPayloadFromData:(NSData *)data;
/**
 * Get the header of the read command
 * @param data packet received from the node
 * @param pheader pointer to packet received from the node
 *
 * @return the value(s) of the read registers
 */
+(BOOL)getHeaderFromData:(NSData *)data header:(BlueSTSDKRegisterHeader_t *)pheader;

/**
 * Get the Target of the received register
 * @param data packet received from the node
 *
 * @return the Target of the read registers
 */
+(BlueSTSDKRegisterTarget_e)getTargetFromData:(NSData *)data;
/**
 * Check if the data is for a write operation
 * @param data packet received from the node
 *
 * @return true if write bit is set
 */
+(BOOL)isWriteOperationFromData:(NSData *)data;
/**
 * Check if the data is for a write operation
 * @param data packet received from the node
 *
 * @return true if Read bit is set
 */
+(BOOL)isReadOperationFromData:(NSData *)data;
/**
 * Get the address of the received register
 * @param data packet received from the node
 *
 * @return the address of the register read or write operation
 */
+(NSInteger)getAddressFromData:(NSData *)data;
/**
 * Get the error of the received register
 * @param data packet received from the node
 *
 * @return the error code of the register read or write operation
 */
+(NSInteger)getErrorFromData:(NSData *)data;
/**
 * Get the size of the received register
 * @param data packet received from the node
 *
 * @return the size of the register read or write operation
 */
+(NSInteger)getSizeFromData:(NSData *)data;
@end

#endif //BlueSTSDKRegister_h

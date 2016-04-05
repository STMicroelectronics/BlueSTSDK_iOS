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

#ifndef BlueSTSDKCommand_h
#define BlueSTSDKCommand_h

#import <Foundation/Foundation.h>
#import "BlueSTSDKRegister.h"
//#import "BlueSTSDKRegisterDefines.h"

/**
 * class that represent an abstraction of the node command to set/get the proper register
 * <p>
 * The class maintain the information  of the register, the target and the payload to
 * write or just read to/from the node
 * </p>
 *
 * @author STMicroelectronics - Central Labs.
 */

@interface BlueSTSDKCommand : NSObject

/**
 *  register to apply the command
 */
@property (retain, nonatomic) BlueSTSDKRegister * registerField;
/**
 *  target memory of the command (persistent or session)
 */
@property (assign, nonatomic) BlueSTSDKRegisterTarget_e target;
/**
 *  raw data of the command
 */
@property (retain, nonatomic) NSData * data;

/**
 * Basic constructor for Command class
 * @param reg Register to manage with this command
 * @param target Memory target for the register
 * @param data value as byte array to set
 */
-(instancetype)initWithRegister:(BlueSTSDKRegister *)reg
                         target:(BlueSTSDKRegisterTarget_e)target
                           data:(NSData *)data;

/**
 * Instance for Command class
 * @param reg Register to manage with this command
 * @param target Memory target for the register
 * @param data value as byte array to set
 */
+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                              data:(NSData *)data;

/**
 * Instance for Command class
 * @param reg Register to manage with this command
 * @param target Memory target for the register
 */
+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target;

/**
 * Instance for Command class
 * @param reg Register to manage with this command
 * @param target Memory target for the register
 * @param value value to set
 * @param byteSize the type of the val parameter
 */
+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                             value:(NSInteger)value
                          byteSize:(NSInteger)byteSize;

/**
 * Instance for Command class
 * @param reg Register to manage with this command
 * @param target Memory target for the register
 * @param value float value to set
 */
+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                        valueFloat:(float)value;


/**
 * Instance for Command class
 * @param reg Register to manage with this command
 * @param target Memory target for the register
 * @param str String value to set
 */
+(instancetype)commandWithRegister:(BlueSTSDKRegister *)reg
                            target:(BlueSTSDKRegisterTarget_e)target
                       valueString:(NSString *)str;


/**
 * Instance for Command class
 * @param dataReceived buffer received from control registers access characteristic
 */
+(instancetype)commandWithData:(NSData *)dataReceived;

/**
 * Get the packet to write the data payload to the target register of this command
 *
 * @return the data packet to sent through the config control characteristic
 */
-(NSData *)toWritePacket;

/**
 * Get the packet to read target register of this command
 *
 * @return the data packet to sent through the config control characteristic
 */
-(NSData *)toReadPacket;

@end

#endif //BlueSTSDKCommand_h

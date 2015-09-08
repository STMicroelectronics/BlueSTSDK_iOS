//
//  BlueSTSDKCommand.h
//
//  Created by Antonino Raucea on 06/15/15.
//  Copyright (c) 2015 STMicroelectronics. All rights reserved.
//

#ifndef BlueSTSDKCommand_h
#define BlueSTSDKCommand_h

#import <Foundation/Foundation.h>
#import "BlueSTSDKRegister.h"
#import "BlueSTSDKRegisterDefines.h"

/**
 * class that represent an abstraction of the device command to set/get the proper register
 * <p>
 * The class maintain the information  of the register, the target and the payload to
 * write or just read to/from the device
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
 * @param name RegisterName to manage with this command
 * @param target Memory target for the register
 * @param data value as byte array to set
 */
+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
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
 * @param name Register to manage with this command
 * @param target Memory target for the register
 */
+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
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
 * @param name RegisterName to manage with this command
 * @param target Memory target for the register
 * @param value value to set
 * @param byteSize the type of the val parameter
 */
+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
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
 * @param name Register name to manage with this command
 * @param target Memory target for the register
 * @param value float value to set
 */
+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
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
 * @param name Register to manage with this command
 * @param target Memory target for the register
 * @param str String value to set
 */
+(instancetype)commandWithRegisterName:(BlueSTSDKRegisterName_e)name
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

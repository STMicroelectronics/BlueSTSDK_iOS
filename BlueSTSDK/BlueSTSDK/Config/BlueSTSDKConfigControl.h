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

#ifndef BlueSTSDKConfigControl_h
#define BlueSTSDKConfigControl_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBCharacteristic.h>

#import "BlueSTSDKCommand.h"
#import "BlueSTSDKNode.h"

@protocol BlueSTSDKConfigControlDelegate;

/**
 * Class that manage the Config characteristics
 * @par
 * The class provides the read and write functions
 * to access the registers throws the {@link BlueSTSDKCommand} class
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKConfigControl : NSObject

/**
 * node that will send the data to this class
 */
@property (readonly,strong) BlueSTSDKNode *node;


/**
 * Instance for Config Control class
 * @param node node that will be configurate
 * @param periph CBPeripheral connection with the node
 * @param configControlChar CBCharacteristic used for access to the register
 */
+(instancetype)configControlWithNode:(BlueSTSDKNode *)node periph:(CBPeripheral *)periph
                  configControlChart:(CBCharacteristic*)configControlChar;

/**
 * Initialize for Config Control class
 * @param node node that will be configurate
 * @param periph CBPeripheral connection with the node
 * @param configControlChar CBCharacteristic used for access to the register */
-(instancetype)initWithNode:(BlueSTSDKNode *)node periph:(CBPeripheral *)periph
         configControlChart:(CBCharacteristic*)configControlChar;

/**
 * Perfome a read operation
 *
 * @param cmd read command
 */
-(void)read:(BlueSTSDKCommand *)cmd;
/**
 * Perfome a write operation
 *
 * @param cmd write command
 */
-(void)write:(BlueSTSDKCommand *)cmd;

/**
 * add a new delegate for the update of this feature
 *
 * @param delegate delegate class
 */
-(void) addConfigDelegate:(id<BlueSTSDKConfigControlDelegate>)delegate;
/**
 * remove a delegate for the update of this feature
 *
 * @param delegate delegate to remove
 */
-(void) removeConfigDelegate:(id<BlueSTSDKConfigControlDelegate>)delegate;

@end

/** Protocol used for notification */
@protocol BlueSTSDKConfigControlDelegate
@required
/**
 *  called when it's received a command that contains a Read result
 *
 *  @param configControl instance that receive the command
 *  @param cmd   command
 *  @param error error condition
 */
-(void) configControl:(BlueSTSDKConfigControl *)configControl didRegisterReadResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error;
/**
 *  called when it's received a command that contains a Write result
 *
 *  @param configControl instance that receive the command
 *  @param cmd   command
 *  @param error error condition
 */
-(void) configControl:(BlueSTSDKConfigControl *)configControl didRegisterWriteResult:(BlueSTSDKCommand *)cmd error:(NSInteger)error;
/**
 *  called when a request is done, to get the result
 *
 *  @param configControl instance that receive the command
 *  @param cmd   command
 *  @param success YES if the request is sent
 */
-(void) configControl:(BlueSTSDKConfigControl *)configControl didRequestResult:(BlueSTSDKCommand *)cmd success:(bool)success;
@end

#endif //BlueSTSDKConfigControl_h

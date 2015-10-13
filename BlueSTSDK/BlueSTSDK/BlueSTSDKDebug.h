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

#ifndef W2STApp_BlueSTSDKDebug_h
#define W2STApp_BlueSTSDKDebug_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBCharacteristic.h>

#import "BlueSTSDKNode.h"

@protocol BlueSTSDKDebugOutputDelegate;

/**
 *  Class that permit to read and write from the debug node console
 * @author STMicroelectronics - Central Labs.
 */
NS_CLASS_AVAILABLE(10_7, 5_0)
@interface BlueSTSDKDebug : NSObject

/**
 *  node that export this console
 */
@property (readonly,strong) BlueSTSDKNode* node;

/**
 *  delegate used for notify new message in the console, when you set a delegate
 * we will automatically enable the notification for the out/error message
 * for disable the notification set it to nil
 */
@property (nonatomic,weak,setter=setDelegate:,getter=getDelegate) id<BlueSTSDKDebugOutputDelegate> delegate;

/**
 *  create a debug console
 *
 *  @param node     node that export the debug console
 *  @param device   device associated to the node
 *  @param termChar characteristic where write and read the console message
 *  @param errChar  characteristic where receive the error messages
 *
 *  @return pointer to a BlueSTSDKDebug class
 */
-(instancetype) initWithNode:(BlueSTSDKNode *)node device:(CBPeripheral *)device
         termChart:(CBCharacteristic*)termChar
          errChart:(CBCharacteristic*)errChar;

/**
 *  send a message to the debug console, the message longher than the maximun size will
 * be splitted in several ble packages
 *
 *  @param msg message to write in the node debug console
 *  @return number of byte send
 */
-(NSUInteger) writeMessage:(NSString*)msg;

@end

/** Protocol used for notify an console update */
@protocol BlueSTSDKDebugOutputDelegate
@required
/**
 *  called when we receive a message that the node write in the stdout stream
 *
 *  @param debug class that receive the message
 *  @param msg   message
 */
-(void) debug:(BlueSTSDKDebug*)debug didStdOutReceived:(NSString*) msg;

/**
 *  called when we receive a message that the node write in the stderr stream
 *
 *  @param debug class that receive the message
 *  @param msg   message
 */
-(void) debug:(BlueSTSDKDebug*)debug didStdErrReceived:(NSString*) msg;

/**
 *  called when we successfully send a message to the node stdin
 *
 *  @param debug class that send the message
 *  @param msg   message send
 *  @param error if present, it is the reason why message was not send */
-(void) debug:(BlueSTSDKDebug*)debug didStdInSend:(NSString*) msg error:(NSError*)error;
@end

#endif

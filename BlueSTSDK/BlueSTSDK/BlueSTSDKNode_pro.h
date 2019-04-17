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

#ifndef BlueSTSDK_BlueSTSDKNode_pro_h
#define BlueSTSDK_BlueSTSDKNode_pro_h

#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBCharacteristic.h>
#import "BlueSTSDKNode.h"

/**
 * package method of the {@link BlueSTSDKNode} class
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKNode()

/**
 * @protected
 *  create a new node, if the node doesn't has a correct advertise this method will
 * throw an exception
 *
 *  @param peripheral        ble peripheral that
 *  @param rssi              advertise rssi
 *  @param advertisementData data in the advertise
 *
 *  @return class BlueSTSDKNode
 */
-(instancetype __nonnull) init :(CBPeripheral * _Nonnull)peripheral rssi:(NSNumber* _Nonnull)rssi
                       advertiseInfo:(id<BleAdvertiseInfo> _Nonnull) advertiseInfo;

/**
 *@protected
 *  initialize the node without a peripheral
 * \note the node intialized with this method will not working properly, this method
 * must when you extend this class and you want continue to use the notification
 * system provided by this class
 *
 *  @return partialy functional node pointer
 */
-(instancetype __nullable) init;

/**
 * @protected
 *  this method will update the rssi node value and notify the update to
 * the delegates
 *
 *  @param rssi new rssi values
 */
-(void)updateRssi:(NSNumber* _Nonnull)rssi;

/**
 * @protected
 *  this method will update the txPower of the node and notify the update to
 * the delegates
 *
 *  @param txPower new tx power
 */
-(void)updateTxPower:(NSNumber* _Nonnull)txPower;

/**
 * @protected
 *  change the node status and notify the event to the delegates
 *
 *  @param newState new node status
 */
-(void)updateNodeStatus:(BlueSTSDKNodeState)newState;

/**
 * @protected
 *  send a command to the command service in the node
 *
 *  @param f           feature that will receive the command
 *  @param commandType command id
 *  @param commandData optional command data
 *
 *  @return true if the command is correctly send
 */
-(BOOL)sendCommandMessageToFeature:(BlueSTSDKFeature* _Nonnull)f type:(uint8_t)commandType
                              data:(NSData* _Nonnull) commandData;

@end


#endif

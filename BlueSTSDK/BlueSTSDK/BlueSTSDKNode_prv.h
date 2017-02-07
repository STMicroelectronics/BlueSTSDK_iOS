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

#ifndef BlueSTSDK_BlueSTSDKNode_prv_h
#define BlueSTSDK_BlueSTSDKNode_prv_h

#import <CoreBluetooth/CBPeripheral.h>
#import <CoreBluetooth/CBCharacteristic.h>
#import "BlueSTSDKNode_pro.h"

/**
 * package method of the {@link BlueSTSDKNode} class
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKNode()

/**
 * @private
 *  this method is called by the BlueSTSDKManager when the CBCentralManager
 * complete the connection with the peripheral, this method will start to request
 * the node service and characteristics
 */
-(void)completeConnection;

/**
 * @private
 *  this method is called by  BlueSTSDKManager when the CBCentralManager is not able
 *  to complete a connection because some error happen
 *
 *  @param error error occurred during the disconnection
 */
-(void)connectionError:(NSError*)error;

/**
 * @private
 *  this method is called by the BlueSTSDKManager when the CBCentralManager complete the
 * peripheral disconnection.
 *
 *  @param error optional error occurred during the disconnection
 */
-(void)completeDisconnection:(NSError*)error;

/**
 * @private
 *  called by the CBPeripheralDelegate when a characteristics is read or notify
 *
 *  @param characteristics characteristics that has new data to be parsed
 */
-(void)characteristicUpdate:(CBCharacteristic*)characteristics;


@end


#endif

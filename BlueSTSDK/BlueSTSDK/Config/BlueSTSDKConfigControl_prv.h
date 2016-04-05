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

#ifndef BlueSTSDKConfigControl_prv_h
#define BlueSTSDKConfigControl_prv_h

#import <Foundation/Foundation.h>

#import "BlueSTSDKConfigControl.h"

@interface BlueSTSDKConfigControl(prv)

/**
 * @private
 * call the method onRegisterReadResult or  onRegisterWriteResult for
 * each delegate that subscribe to this feature.
 * @par
 * if you extend the method update you have to call this method after that you update the data
 *
 * @param characteristic byte read from the register
 */
-(void)characteristicsUpdate:(CBCharacteristic *)characteristic;

/**
 * @private
 * call the method onRequestResult for
 * each listener that subscribe to this feature.
 * @par
 * if you extend the method update you have to call this method after that you update the data
 * 
 * @param characteristic that contains the data command sent to the node
 * @param success true if the wrote command is send correctly
 */
-(void)characteristicsWriteUpdate:(CBCharacteristic *)characteristic success:(bool)success;

@end

#endif //BlueSTSDKConfigControl_prv_h

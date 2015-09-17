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

#ifndef BlueSTSDK_BlueSTSDKFeature_prv_h
#define BlueSTSDK_BlueSTSDKFeature_prv_h

#include "BlueSTSDKFeature.h"

/**
 * This interface contains the protected and packages method that can be used
 * inside the sdk
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeature(Prv)

//we redefine the property for be read write, when the user see it in read only
@property (readwrite,atomic) BlueSTSDKFeatureSample *lastSample;

/**
 * @protected
 *  initialize a feature
 *  @par protected function
 *  @param node node that export the feature
 *  @param name name of the feature
 *
 *  @return pointer to the feature
 */
-(instancetype) initWhitNode: (BlueSTSDKNode*)node name:(NSString*)name;

/**
 *  @protected
 * notify to all the registered delegate that the feature has update its data
 
 *  @par protected function
 *  @param sample new sample data that we want notify
 */
-(void) notifyUpdateWithSample:(BlueSTSDKFeatureSample*)sample;

/**
 * @protected
 *  notify to all the register delegate that a feature has been
 *  updated using some data
 
 *  @par protected function
 *  @param rawData raw data used for extract the new data
 *  @param data array of NSNumber extracted by raw data
 */
-(void) logFeatureUpdate:(NSData*)rawData sample:(BlueSTSDKFeatureSample*)sample;

/**
 *  @protected
 * send a command to this feature using the command characteristics
 *
 *  @par protected function
 *  @param commandType id of the command
 *  @param commandData optional data for the command
 *
 *  @return true if the command is correctly send to the node
 */
-(bool) sendCommand:(uint8_t)commandType data:(NSData*)commandData;

/**
 * @protected
 *  parse a command response, the default
 *  implementation is an empty method 
 *
 *  @par protected abstract function
 *  @param timestamp   response id
 *  @param commandType id of the command that generate the answer
 *  @param data        response data
 */
-(void) parseCommandResponseWithTimestamp:(uint32_t)timestamp
                              commandType:(uint8_t)commandType
                                     data:(NSData*)data;

/**
 *  @protected
 * write a data into the feature
 *
 *  @par protected function
 *  @param data data to write into the feature
 */
-(void)writeData:(NSData*)data;

///////package method////////////

/**
 * @package
 *  change the feature status
 *  @par package function
 *  @param enabled true if the node has this feature
 */
-(void) setEnabled:(bool)enabled;

/**
 *  This method is called by the CBPeriferal to notify an update
 *  @par package function
 *
 *  @param timestamp  package id
 *  @param data      raw data received by the node
 *  @param offset    offset where start to read the raw data
 *
 *  @return number of read byte
 */
-(uint32_t) update:(uint32_t)timestamp data:(NSData*)data dataOffset:(uint32_t)offset;

@end

#endif

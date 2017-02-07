/*******************************************************************************
 * COPYRIGHT(c) 2016 STMicroelectronics
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

#ifndef BlueSTSDK_BlueSTSDKFeatureCarryPosition_h
#define BlueSTSDK_BlueSTSDKFeatureCarryPosition_h

#import <Foundation/Foundation.h>
#import "BlueSTSDKFeature.h"
#import "BlueSTSDKFeatureField.h"

/**
 *  protocol used by the remote feature for extract the data
 *
 * @author STMicroelectronics - Central Labs.
 */
@protocol BlueSTSDKRemoteFeature <NSObject>

/**
 *  extract the data from a remote feature
 *
 *  @param timestamp data timestamp
 *  @param data      bytes to use for extract the data
 *  @param offset    number of bytes already read
 *
 *  @return data sample + number of byte read
 */
-(BlueSTSDKExtractResult*) extractRemoteData:(uint64_t)timestamp
                                        data:(NSData*)data
                                  dataOffset:(uint32_t)offset;

@end

/**
 *  Extend the BlueSTSDKFeature adding utitility method used for handle RemoteFeatures
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeature(Remote)

/**
 *  extract the node id from a sample
 *
 *  @param sample sample with the data and the node id
 *  @param idPos  positition when the node id is stored
 *
 *  @return nodeId of the node that produced this sample
 */
+(uint16_t) getNodeId:(BlueSTSDKFeatureSample*)sample idPos:(uint32_t)idPos;

/**
 *  return the description for the nodeId field
 *
 *  @return description for the node id field
 */
+(BlueSTSDKFeatureField*) getNodeIdFieldDesc;

/**
 *  add a remoteId after the standard feature samples
 *
 *  @param remoteId id of the node that generate this sample
 *  @param sample   sample with the data
 *
 *  @return a new sample that contains also the node id
 */
+(BlueSTSDKFeatureSample*) appendRemoteId:(uint16_t)remoteId
                                   sample:(BlueSTSDKFeatureSample*)sample;

/**
 *
 *
 *  @param feature       feature that will extract the data
 *  @param nodeUnWrapper dictionary that contains the object fro unwrap the timestamp for each remote node
 *  @param timestamp     timestamp received from the node
 *  @param rawData       data recived from the node
 *  @param offset        number of byte already read
 *
 *  @return the sample and the number of byte read
 */
+(BlueSTSDKExtractResult*) extractRemoteData:(id<BlueSTSDKRemoteFeature>)feature
                                 unTsWrapper:(NSMutableDictionary *) nodeUnWrapper
                                   timestamp:(uint64_t)timestamp
                                        data:(NSData*)rawData
                                  dataOffset:(uint32_t)offset;
@end

#endif


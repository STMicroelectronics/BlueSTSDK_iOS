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

#ifndef BlueSTSDK_BlueSTSDKFeatureGenPurpose_h
#define BlueSTSDK_BlueSTSDKFeatureGenPurpose_h


#import <CoreBluetooth/CBCharacteristic.h>
#import "BlueSTSDKFeature.h"

/**
 * this is a special feature where the data are not parsed, since the format is 
 * unknow
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureGenPurpose : BlueSTSDKFeature

/**
 *  characteristic that update this feature
 */
@property(readonly,weak) CBCharacteristic* characteristics;

/**
 *  extract the array of byte transmitted by the feature
 *
 *  @param data feature sample
 *
 *  @return array of byte that are send by the feature
 */
+(NSData*) getRawData:(BlueSTSDKFeatureSample*)data;

/**
 *  initialize a general puprpose feature
 *
 *  @param node node that will update the data
 *  @param c    characteristics that will update the data
 *
 *  @return a genaral purpose feature initialize with the node and hte characteristics
 */
-(instancetype)initWhitNode:(BlueSTSDKNode *)node
            characteristics:(CBCharacteristic*)c;

@end

#endif

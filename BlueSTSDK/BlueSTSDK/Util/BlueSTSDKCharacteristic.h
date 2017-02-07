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

#ifndef BlueSTSDK_BlueSTSDKCharacteristic_h
#define BlueSTSDK_BlueSTSDKCharacteristic_h

#import <Foundation/Foundation.h>
#import <CoreBluetooth/CoreBluetooth.h>

#import "../BlueSTSDKFeature.h"

/**
 *  A single ble characteristic can contains more than one feature, 
 * this class help to map a ble characteristic with its features
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKCharacteristic : NSObject

/**
 *  ble characteristic associated with this object
 */
@property(strong,nonatomic,readonly) CBCharacteristic* characteristic;

/**
 *  array of class that extend {@link BlueSTSDKFeature} that the characteristic export
 */
@property(strong,nonatomic,readonly) NSArray* features;

/**
 *  create a new characteristic manage by the sdk
 *
 *  @param charac   ble characteristic
 *  @param features array of BlueSTSDKFeature that are exported by this characteristic
 *
 *  @return object of type BlueSTSDKCharacteristic
 */
-(instancetype) initWithChar:(CBCharacteristic*)charac features:(NSArray*)features;

/**
 *  find the features manage by a ble characteristic
 *
 *  @param characteristic   characteristic that we are searching
 *  @param CharFeatureArray array of BlueSTSDKCharacteristic where search
 *
 *  @return array BlueSTSDKFeature exported by that characteristic
 */
+(NSArray*) getFeaturesFromChar:(CBCharacteristic const*)characteristic
                             in:(NSArray*)CharFeatureArray;

/**
 *  find the characteristic that export a particular feature, if the feature is
 * exported by multiple characteristic we will return the characteristic that export
 * more features
 *
 *  @param feature          feature to search
 *  @param CharFeatureArray array of BlueSTSDKCharacteristic where search
 *
 *  @return ble characteristic that export that feature
 */
+(CBCharacteristic*) getCharFromFeature:(BlueSTSDKFeature*)feature
                                     in:(NSArray*)CharFeatureArray;
@end

#endif

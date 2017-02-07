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

#ifndef BlueSTSDK_BlueSTSDKFeatureAcceleration_h
#define BlueSTSDK_BlueSTSDKFeatureAcceleration_h

#import "BlueSTSDKFeature.h"

/**
 * Feature that contains the data of an accelerometer.
 * \par
 * The data exported are an array of 3 float component (x,y,z) with the acceleration
 * on that axis
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureAcceleration : BlueSTSDKFeature

/**
 *  return the x component of the acceleration
 *
 *  @param data sample read from the node
 *  @return acceleration in the x axis
 */
+(float)getAccX:(BlueSTSDKFeatureSample*)data;

/**
 *  return the y component of the acceleration
 *
 *  @param data sample read from the node
 *
 *  @return acceleration in the y axis
 */
+(float)getAccY:(BlueSTSDKFeatureSample*)data;

/**
 *  return the z component of the acceleration
 *
 *  @param data sample read from the node
 *
 *  @return acceleration in the z axis
 */
+(float)getAccZ:(BlueSTSDKFeatureSample*)data;

@end
#endif

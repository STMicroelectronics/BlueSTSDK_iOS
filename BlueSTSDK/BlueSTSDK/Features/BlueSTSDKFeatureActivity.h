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

#ifndef BlueSTSDK_BlueSTSDKFeatureActivity_h
#define BlueSTSDK_BlueSTSDKFeatureActivity_h

#import "BlueSTSDKFeature.h"

/**
 * Export the data from the activiy recognition algorithm
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureActivity : BlueSTSDKFeature

/**
 *  different type of activity recognized by the node
 */
typedef NS_ENUM(NSInteger, BlueSTSDKFeatureActivityType){
    /**
     *  we don't have enough data for select an activity
     */
    BlueSTSDKFeatureActivityTypeNoActivity =0x00,
    /**
     *  the person is standing
     */
    BlueSTSDKFeatureActivityTypeStanding =0x01,
    /**
     *  the person is walking
     */
    BlueSTSDKFeatureActivityTypeWalking =0x02,
    /**
     *  the person is fast walking
     */
    BlueSTSDKFeatureActivityTypeFastWalking =0x03,
    /**
     *  the person is jogging
     */
    BlueSTSDKFeatureActivityTypeJogging =0x04,
    /**
     *  the person is biking
     */
    BlueSTSDKFeatureActivityTypeBiking =0x05,
    /**
     *  the person is driving
     */
    BlueSTSDKFeatureActivityTypeDriving =0x06,
    /**
     *  unknown activity
     */
    BlueSTSDKFeatureActivityTypeError =0xFF
};

/**
 *  extract the activity value
 *
 *  @param sample sample read from the node
 *
 *  @return activity value
 */
+(BlueSTSDKFeatureActivityType)getActivityType:(BlueSTSDKFeatureSample*)sample;

/**
 *  return the data when we receive the notification
 *
 *  @param sample data read from the node
 *
 *  @return data when we receive the data
 */
+(NSDate*)getActivityDate:(BlueSTSDKFeatureSample*)sample;

@end
#endif

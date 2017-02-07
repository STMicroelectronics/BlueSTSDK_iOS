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
#ifndef BlueSTSDK_BlueSTSDKFeatureCarryPosition_h
#define BlueSTSDK_BlueSTSDKFeatureCarryPosition_h

#import "BlueSTSDKFeature.h"

/**
 * Export the data from the carry position recognition algorithm
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureCarryPosition : BlueSTSDKFeature

/**
 *  different type of position recognized by the node
 */
typedef NS_ENUM(NSInteger, BlueSTSDKFeatureCarryPositionType){
    /**
     *  we don't have enough data for select a position
     */
    BlueSTSDKFeatureCarryPositionUnknown =0x00,
    /**
     *  the node is on the desk
     */
    BlueSTSDKFeatureCarryPositionOnDesk =0x01,
    /**
     *  the node is in the user hand
     */
    BlueSTSDKFeatureCarryPositionInHand =0x02,
    /**
     *  the node is in near the user head
     */
    BlueSTSDKFeatureCarryPositionNearHead =0x03,
    /**
     *  the node is in the shirt pocket
     */
    BlueSTSDKFeatureCarryPositionShirtPocket =0x04,
    /**
     *  the node is in the trousers pocket
     */
    BlueSTSDKFeatureCarryPositionTrousersPocket =0x05,
    /**
     *  the node is attached to an arm that is swinging
     */
    BlueSTSDKFeatureCarryPositionArmSwing =0x06,
    /**
     *  invalid code
     */
    BlueSTSDKFeatureCarryPositionError =0xFF
};

/**
 *  extract the position value
 *
 *  @param sample sample read from the node
 *
 *  @return activity value
 */
+(BlueSTSDKFeatureCarryPositionType)getPositionType:(BlueSTSDKFeatureSample*)sample;

@end

#endif

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

#ifndef BlueSTSDK_BlueSTSDKFeatureAudioADPCM_h
#define BlueSTSDK_BlueSTSDKFeatureAudioADPCM_h


#import "BlueSTSDKFeature.h"
#import "BlueSTSDKDeviceTimestampFeature.h"

/**
 * Class that contains the information needed for decode a stream of ADPCM encoded data
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface ADPCMAudioSyncManager : NSObject
    @property BOOL intra_flag;
    @property int16_t adpcm_index_in;
    @property int32_t adpcm_predsample_in;

    /**
     * create a new class instance
     * @return  new class instance
     */
    +(instancetype)audioManager;

    /**
     * extract the sync data form a sample from the class BlueSTSDKFeatureAudioADPCMSync
     * @param sample sample with the sync data
     */
    -(void)setSyncParam:(BlueSTSDKFeatureSample *)sample;

@end

/**
 * Feature that export the audio data, encoded with an ADPCM algorithm
 *
 * @author STMicroelectronics - Central Labs.
 */
@interface BlueSTSDKFeatureAudioADPCM : BlueSTSDKDeviceTimestampFeature

/**
 * Object where read the sync information needed for decode the stream
 */
@property (retain, atomic, readonly) ADPCMAudioSyncManager *audioManager;


/**
 * Extract the last audio sample
 * @param sample sample that contains the aduio data
 * @return array of 40 16bit audio sample
 */
+(NSData *)getLinearPCMAudio:(BlueSTSDKFeatureSample *)sample;

@end
#endif

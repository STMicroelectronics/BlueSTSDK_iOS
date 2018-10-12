/*******************************************************************************
 * COPYRIGHT(c) 2017 STMicroelectronics
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

#import <Foundation/Foundation.h>

#import "BlueSTSDKFeature.h"

typedef NS_ENUM(UInt8,BlueSTSDKFeatureBeamFormingDirection){
    BlueSTSDKFeatureBeamFormingDirection_TOP=1,
    BlueSTSDKFeatureBeamFormingDirection_TOP_RIGHT=2,
    BlueSTSDKFeatureBeamFormingDirection_RIGHT=3,
    BlueSTSDKFeatureBeamFormingDirection_BOTTOM_RIGHT=4,
    BlueSTSDKFeatureBeamFormingDirection_BOTTOM=5,
    BlueSTSDKFeatureBeamFormingDirection_BOTTOM_LEFT=6,
    BlueSTSDKFeatureBeamFormingDirection_LEFT=7,
    BlueSTSDKFeatureBeamFormingDirection_TOP_LEFT=8,
    BlueSTSDKFeatureBeamFormingDirection_UNKNOWN=0xFF
};

@interface BlueSTSDKFeatureBeamForming : BlueSTSDKFeature

+(BlueSTSDKFeatureBeamFormingDirection)getDirection:(BlueSTSDKFeatureSample *)sample;

-(void) enablebeamForming:(BOOL)enabled;
-(void)useStrongbeamFormingAlgorithm:(BOOL)enabled;

-(void) setDirection:(BlueSTSDKFeatureBeamFormingDirection)direction;

@end

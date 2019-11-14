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


#import "BlueSTSDKFeature.h"
#import "BlueSTSDKFeature_pro.h"

#import "BlueSTSDKNode.h"
#import "BlueSTSDKNode_pro.h"
#import "BlueSTSDKDebug.h"

#import "BlueSTSDKFeatureAcceleration.h"
#import "BlueSTSDKFeatureAutoConfigurable.h"
#import "BlueSTSDKFeatureBattery.h"
#import "BlueSTSDKFeatureCarryPosition.h"
#import "BlueSTSDKFeatureField.h"
#import "BlueSTSDKFeatureFreeFall.h"
#import "BlueSTSDKFeatureGyroscope.h"
#import "BlueSTSDKFeatureHumidity.h"
#import "BlueSTSDKFeatureLuminosity.h"
#import "BlueSTSDKFeatureMagnetometer.h"
#import "BlueSTSDKFeatureMemsSensorFusion.h"
#import "BlueSTSDKFeatureMemsSensorFusionCompact.h"
#import "BlueSTSDKFeaturePressure.h"
#import "BlueSTSDKFeatureProximity.h"
#import "BlueSTSDKFeatureMicLevel.h"
#import "BlueSTSDKFeatureTemperature.h"
#import "BlueSTSDKFeatureProximityGesture.h"
#import "BlueSTSDKFeatureMemsGesture.h"
#import "BlueSTSDKFeaturePedometer.h"
#import "BlueSTSDKFeatureAccelerometerEvent.h"
#import "BlueSTSDKFeatureDirectionOfArrival.h"
#import "BlueSTSDKFeatureSwitch.h"
#import "BlueSTSDKRemoteFeatureHumidity.h"
#import "BlueSTSDKRemoteFeatureTemperature.h"
#import "BlueSTSDKRemoteFeatureSwitch.h"
#import "BlueSTSDKRemoteFeaturePressure.h"
#import "BlueSTSDKFeatureCompass.h"
#import "BlueSTSDKFeatureBeamForming.h"
#import "BlueSTSDKFeatureMotionIntensity.h"
#import "BlueSTSDKFeatureSDLogging.h"
#import "BlueSTSDKFeatureCOSensor.h"

#import "BlueSTSDKStdCharToFeatureMap.h"
#import "BlueSTSDKFeatureHeartRate.h"

#import "BlueSTSDKFeatureGenPurpose.h"

#import "BlueSTSDKFeatureLogCSV.h"
#import "BlueSTSDKFeatureLogNSLog.h"
#import "BlueSTSDKNodeStatusNSLog.h"

#import "BlueSTSDKConfigControl.h"
#import "BlueSTSDKRegister.h"

#import "BlueSTSDKCommand.h"

#import "BlueSTSDKWeSURegisterDefines.h"
#import "BlueSTSDKWeSUFeatureConfig.h"

#import "BlueSTSDKFwVersion.h"
#import "BlueSTSDK_LocalizeUtil.h"
#import "NSMutableDictionary+BlueSTSDKFeature.h"
#import "NSData+NumberConversion.h"

//private header added to enable swit interaction
#import "BlueSTSDKNodeFake.h"
#import "BlueSTSDKNode_prv.h"

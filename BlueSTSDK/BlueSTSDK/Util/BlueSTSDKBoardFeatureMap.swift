/*******************************************************************************
 * COPYRIGHT(c) 2019 STMicroelectronics
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

import Foundation

/**
 *  For each board type contains a map for of pair ( {@link featureMask_t},
 *  {@link BlueSTSDKFeature } class )
 */
internal struct BlueSTSDKBoardFeatureMap{
    
    /**
     * if the board doesn't have a specific device id the map returned by this feature will be used
     *
     * @return the default map used to convert the bit in the advertise mask into feature.
     */
    static let defaultMaskToFeatureMap = [
        //NSNumber(0x80000000:
        NSNumber(0x40000000) : BlueSTSDKFeatureAudioADPCMSync.self,
        NSNumber(0x20000000) : BlueSTSDKFeatureSwitch.self,
        NSNumber(0x10000000) : BlueSTSDKFeatureDirectionOfArrival.self, //Sound source of arrival
        NSNumber(0x08000000) : BlueSTSDKFeatureAudioADPCM.self,
        NSNumber(0x04000000) : BlueSTSDKFeatureMicLevel.self, //Mic Level
        NSNumber(0x02000000) : BlueSTSDKFeatureProximity.self, //proximity
        NSNumber(0x01000000) : BlueSTSDKFeatureLuminosity.self, //luminosity
        NSNumber(0x00800000) : BlueSTSDKFeatureAcceleration.self, //acc
        NSNumber(0x00400000) : BlueSTSDKFeatureGyroscope.self, //gyo
        NSNumber(0x00200000) : BlueSTSDKFeatureMagnetometer.self, //mag
        NSNumber(0x00100000) : BlueSTSDKFeaturePressure.self, //pressure
        NSNumber(0x00080000) : BlueSTSDKFeatureHumidity.self, //humidity
        NSNumber(0x00040000) : BlueSTSDKFeatureTemperature.self, //temperature
        NSNumber(0x00020000) : BlueSTSDKFeatureBattery.self,
        NSNumber(0x00010000) : BlueSTSDKFeatureTemperature.self, //temperature
        NSNumber(0x00008000) : BlueSTSDKFeatureCOSensor.self,
        //NSNumber(0x00004000:
        //NSNumber(0x00002000:
        NSNumber(0x00001000) : BlueSTSDKFeatureSDLogging.self,
        NSNumber(0x00000800) : BlueSTSDKFeatureBeamForming.self,
        NSNumber(0x00000400) : BlueSTSDKFeatureAccelerometerEvent.self, //Free fall detection
        NSNumber(0x00000200) : BlueSTSDKFeatureFreeFall.self, //Free fall detection
        NSNumber(0x00000100) : BlueSTSDKFeatureMemsSensorFusionCompact.self, //Mems sensor fusion compact
        NSNumber(0x00000080) : BlueSTSDKFeatureMemsSensorFusion.self, //Mems sensor fusion
        NSNumber(0x00000040) : BlueSTSDKFeatureCompass.self,
        NSNumber(0x00000020) : BlueSTSDKFeatureMotionIntensity.self,
        NSNumber(0x00000010) : BlueSTSDKFeatureActivity.self, //Actvity
        NSNumber(0x00000008) : BlueSTSDKFeatureCarryPosition.self, //carry position recognition
        NSNumber(0x00000004) : BlueSTSDKFeatureProximityGesture.self, //Proximity Gesture
        NSNumber(0x00000002) : BlueSTSDKFeatureMemsGesture.self, //mems Gesture
        NSNumber(0x00000001) : BlueSTSDKFeaturePedometer.self, //Pedometer
    ];
    
    
    private static let SENSOR_TILE_BOX_FEATURE_MASK = [
        NSNumber(value: UInt32(0x80000000)) : BlueSTSDKFeatureFFTAmplitude.self,
        NSNumber(0x40000000) : BlueSTSDKFeatureAudioADPCMSync.self,
        NSNumber(0x20000000) : BlueSTSDKFeatureSwitch.self,
        NSNumber(0x10000000) : BlueSTSDKFeatureMemsNorm.self,
        NSNumber(0x08000000) : BlueSTSDKFeatureAudioADPCM.self,
        NSNumber(0x04000000) : BlueSTSDKFeatureMicLevel.self, //Mic Level
        NSNumber(0x02000000) : BlueSTSDKFeatureAudioCalssification.self, //audio scene classification
        NSNumber(0x01000000) : BlueSTSDKFeatureLuminosity.self, //luminosity
        NSNumber(0x00800000) : BlueSTSDKFeatureAcceleration.self, //acc
        NSNumber(0x00400000) : BlueSTSDKFeatureGyroscope.self, //gyo
        NSNumber(0x00200000) : BlueSTSDKFeatureMagnetometer.self, //mag
        NSNumber(0x00100000) : BlueSTSDKFeaturePressure.self, //pressure
        NSNumber(0x00080000) : BlueSTSDKFeatureHumidity.self, //humidity
        NSNumber(0x00040000) : BlueSTSDKFeatureTemperature.self, //temperature
        NSNumber(0x00020000) : BlueSTSDKFeatureBattery.self,
        NSNumber(0x00010000) : BlueSTSDKFeatureTemperature.self, //temperature
        // NSNumber(0x00008000) :
        NSNumber(0x00004000) : BlueSTSDKFeatureEulerAngle.self,
        //NSNumber(0x00002000:
        NSNumber(0x00001000) : BlueSTSDKFeatureSDLogging.self,
        // NSNumber(0x00000800) :
        NSNumber(0x00000400) : BlueSTSDKFeatureAccelerometerEvent.self,
        NSNumber(0x00000200) : BlueSTSDKFeatureEventCounter.self,
        NSNumber(0x00000100) : BlueSTSDKFeatureMemsSensorFusionCompact.self, //Mems sensor fusion compact
        NSNumber(0x00000080) : BlueSTSDKFeatureMemsSensorFusion.self, //Mems sensor fusion
        NSNumber(0x00000040) : BlueSTSDKFeatureCompass.self,
        NSNumber(0x00000020) : BlueSTSDKFeatureMotionIntensity.self,
        NSNumber(0x00000010) : BlueSTSDKFeatureActivity.self, //Actvity
        NSNumber(0x00000008) : BlueSTSDKFeatureCarryPosition.self, //carry position recognition
        NSNumber(0x00000004) : BlueSTSDKFeatureProximityGesture.self, //Proximity Gesture
        NSNumber(0x00000002) : BlueSTSDKFeatureMemsGesture.self, //mems Gesture
        NSNumber(0x00000001) : BlueSTSDKFeaturePedometer.self, //Pedometer
    ];
    
    private static let  bleStarNucleoFeatureMap = [
        NSNumber(0x20000000): BlueSTSDKRemoteFeatureSwitch.self,
        NSNumber(0x00100000): BlueSTSDKRemoteFeaturePressure.self, //pressure
        NSNumber(0x00080000): BlueSTSDKRemoteFeatureHumidity.self, //humidity
        NSNumber(0x00040000): BlueSTSDKRemoteFeatureTemperature.self, //temperature
    ];
    
    
    /**
     *  return a map of type <boardId, map<{@link featureMask_t}, {@link BlueSTSDKFeature }> >
     *  from this data you can understand what class will be manage a specific characteristics
     *
     *  @return map needed for build a feature class that manage a specific characteristics
     */
    static var boardFeatureMap = [
        NSNumber(0x06): SENSOR_TILE_BOX_FEATURE_MASK,
        NSNumber(0x81): bleStarNucleoFeatureMap
    ];
    
}

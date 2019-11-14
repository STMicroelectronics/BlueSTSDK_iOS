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
import CoreBluetooth

public typealias featureMask_t = UInt32

@objc public //todo add internal visibity when remove the objc annotation
extension CBUUID {
    /**
     *  extract the feature mask from an uuid value, tell to the user witch feature
     *  are exported by this characteristics
     *
     *  @return characteristics feature mask
     */
    var featureMask:featureMask_t{
        get{
            return (self.data as NSData).extractBeUInt32(fromOffset: 0)
        }
    }
}

@objc public //todo add internal visibity when remove the objc annotation
extension CBCharacteristic {
    
    //all the sdk characteristics will end with this string
    fileprivate static let COMMON_CHAR_UUID = "-11E1-AC36-0002A5D5C51B"
    //all the features characteristics exported in the advertise feature mask will end with this string
    private static  let BASE_FEATURE_COMMON_UUID = "-0001"+COMMON_CHAR_UUID
    //all the features characteristics not exported will end with this string
    private static  let  EXTENDED_FEATURE_COMMON_UUID = "-0002"+COMMON_CHAR_UUID
    //all the general purpose characteristics will end with this string
    private static  let COMMON_GP_FEATURE_UUID = "-0003"+COMMON_CHAR_UUID
    //all the sdk service will end with this string
    private static  let COMMON_SERVICE_UUID = "-11E1-9AB4-0002A5D5C51B"
    
    /**
     *  tell if a characteristics has a valid uuid for be manage by this sdk
     *
     *  @param c characteristic to test
     *
     *  @return true if the characteristics can be manage by this sdk
     */
    var isFeatureCaracteristics:Bool{
        get {
            return self.uuid.uuidString.hasSuffix(CBCharacteristic.BASE_FEATURE_COMMON_UUID)
        }
    }
    
    /**
     *  tell if a characteristics has a valid uudi for be manage by this sdk as a
     *  general pourpose characteristics
     *
     *  @param c characteristic to test
     *
     *  @return true if the characteristics can be manage by this sdk as general purpose characteristics
     */
    var isFeatureGeneralPurposeCharacteristics:Bool{
        get{
            return self.uuid.uuidString.hasSuffix(CBCharacteristic.COMMON_GP_FEATURE_UUID)
        }
    }
    
    private static func buildExtendedFeatureCharacteristics( prefix:UInt32 )->CBUUID{
        let uuidString = String(format: "%08X%@", prefix,CBCharacteristic.EXTENDED_FEATURE_COMMON_UUID)
        return CBUUID(string: uuidString)
    }
    
    private static let EXTENDED_FEATURE_MAP = [
        buildExtendedFeatureCharacteristics(prefix: 0x01) : [BlueSTSDKFeatureAudioOpus.self],
        buildExtendedFeatureCharacteristics(prefix: 0x02) : [BlueSTSDKFeatureAudioOpusConf.self],
        buildExtendedFeatureCharacteristics(prefix: 0x03) : [BlueSTSDKFeatureAudioCalssification.self],
        buildExtendedFeatureCharacteristics(prefix: 0x04) : [BlueSTSDKFeatureAILogging.self],
        buildExtendedFeatureCharacteristics(prefix: 0x05) : [BlueSTSDKFeatureFFTAmplitude.self],
        buildExtendedFeatureCharacteristics(prefix: 0x06) : [BlueSTSDKFeatureMotorTimeParameters.self],
        buildExtendedFeatureCharacteristics(prefix: 0x07) : [BlueSTSDKFeaturePredictiveSpeedStatus.self],
        buildExtendedFeatureCharacteristics(prefix: 0x08) : [BlueSTSDKFeaturePredictiveAccelerationStatus.self],
        buildExtendedFeatureCharacteristics(prefix: 0x09) : [BlueSTSDKFeaturePredictiveFrequencyDomainStatus.self],
        buildExtendedFeatureCharacteristics(prefix: 0x0A) : [BlueSTSDKFeatureMotionAlogrithm.self],
        //buildExtendedFeatureCharacteristics(prefix: 0x0B) : [],
        //buildExtendedFeatureCharacteristics(prefix: 0x0C) : [],
        buildExtendedFeatureCharacteristics(prefix: 0x0D) : [BlueSTSDKFeatureEulerAngle.self],
        buildExtendedFeatureCharacteristics(prefix: 0x0E) : [BlueSTSDKFeatureFitnessActivity.self],
    ]
    
    var extendedFeature:[BlueSTSDKFeature.Type]?{
        get{
            return CBCharacteristic.EXTENDED_FEATURE_MAP[self.uuid]
        }
    }
}

fileprivate //todo add internal visibity when remove the objc annotation, and made it a struct
struct BlueSTSDKService {
    //all the sdk service will end with this string
    private static let COMMON_SERVICE_UUID = "-11E1-9AB4-0002A5D5C51B"
    
    /**
     *  class with the utility function for the debug service
     */
    struct BlueSTSDKDebugService {
        private static let SERVICE_ID  = "000E"
        let uuid = CBUUID(string: "00000000-\(BlueSTSDKDebugService.SERVICE_ID)\(BlueSTSDKService.COMMON_SERVICE_UUID)")
        let termUuid = CBUUID(string: "00000001-\(BlueSTSDKDebugService.SERVICE_ID)\(CBCharacteristic.COMMON_CHAR_UUID)")
        let stdErrUuid = CBUUID(string: "00000002-\(BlueSTSDKDebugService.SERVICE_ID)\(CBCharacteristic.COMMON_CHAR_UUID)")
    }
    
    struct BlueSTSDKConfigService {
        private static let SERVICE_ID  = "000F"
        let uuid = CBUUID(string: "00000000-\(BlueSTSDKConfigService.SERVICE_ID)\(BlueSTSDKService.COMMON_SERVICE_UUID)")
        let configControlUuid = CBUUID(string: "00000001-\(BlueSTSDKConfigService.SERVICE_ID)\(CBCharacteristic.COMMON_CHAR_UUID)")
        let featureCommandUuid = CBUUID(string: "00000002-\(BlueSTSDKConfigService.SERVICE_ID)\(CBCharacteristic.COMMON_CHAR_UUID)")

        
    }
    
    static let debugService = BlueSTSDKDebugService()
    static let configService = BlueSTSDKConfigService()
}

@objc public //todo add internal visibity when remove the objc annotation
extension CBService {
    
    var isDebugService:Bool{
        get{
            return self.uuid == BlueSTSDKService.debugService.uuid
        }
    }
    
    var isConfigService:Bool{
        get{
            return self.uuid == BlueSTSDKService.configService.uuid
        }
    }
}

@objc public //todo add internal visibity when remove the objc annotation
extension CBCharacteristic {
    var isDebugCharacteristic:Bool{
        get{
            return isDebugTermCharacteristic || isDebugErrorCharacteristic
        }
    }
    var isDebugTermCharacteristic:Bool{
        get{
            return self.uuid == BlueSTSDKService.debugService.termUuid
        }
    }
    
    var isDebugErrorCharacteristic:Bool{
        get{
            return self.uuid == BlueSTSDKService.debugService.stdErrUuid
        }
    }
}

@objc public //todo add internal visibity when remove the objc annotation
extension CBCharacteristic {
    var isConfigCharacteristics:Bool{
        get{
            return isConfigControlCharacteristic || isConfigFeatureCommandCharacteristic
        }
    }
    
    var isConfigControlCharacteristic:Bool{
        get{
            return self.uuid == BlueSTSDKService.configService.configControlUuid
        }
    }
    
    var isConfigFeatureCommandCharacteristic:Bool{
        get{
            return self.uuid == BlueSTSDKService.configService.featureCommandUuid
        }
    }
}

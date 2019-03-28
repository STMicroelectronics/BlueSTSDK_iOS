/*******************************************************************************
 * COPYRIGHT(c) 2018 STMicroelectronics
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


@objc
public class BlueSTSDKFeatureMotorTimeParameters : BlueSTSDKFeature {
    
    public static let FEATURE_NAME = "MotorTimeParameter"
    public static let FEATURE_ACC_UNIT = "m/s^2"
    public static let FEATURE_SPEED_UNIT = "mm/s"
 
    private static let FEATURE_DATA_NAME = ["Acc X Peak", "Acc Y Peak", "Acc Z Peak"
    ,"RMS Speed X","RMS Speed Y","RMS Speed Z"];
    public static let DATA_ACC_MAX = 2000.0;
    public static let DATA_ACC_MIN = -2000.0;
    
    public static let DATA_SPEED_MAX = 2000.0;
    public static let DATA_SPEED_MIN = 0.0;
 
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: BlueSTSDKFeatureMotorTimeParameters.FEATURE_DATA_NAME[0],
                              unit: BlueSTSDKFeatureMotorTimeParameters.FEATURE_ACC_UNIT,
                              type: .float,
                              min: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_ACC_MIN),
                              max: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_ACC_MAX)),
        BlueSTSDKFeatureField(name: BlueSTSDKFeatureMotorTimeParameters.FEATURE_DATA_NAME[1],
                              unit: BlueSTSDKFeatureMotorTimeParameters.FEATURE_ACC_UNIT,
                              type: .float,
                              min: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_ACC_MIN),
                              max: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_ACC_MAX)),
        BlueSTSDKFeatureField(name: BlueSTSDKFeatureMotorTimeParameters.FEATURE_DATA_NAME[2],
                              unit: BlueSTSDKFeatureMotorTimeParameters.FEATURE_ACC_UNIT,
                              type: .float,
                              min: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_ACC_MIN),
                              max: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_ACC_MAX)),
        BlueSTSDKFeatureField(name: BlueSTSDKFeatureMotorTimeParameters.FEATURE_DATA_NAME[3],
                              unit: BlueSTSDKFeatureMotorTimeParameters.FEATURE_SPEED_UNIT,
                              type: .float,
                              min: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_SPEED_MIN),
                              max: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_SPEED_MAX)),
        BlueSTSDKFeatureField(name: BlueSTSDKFeatureMotorTimeParameters.FEATURE_DATA_NAME[4],
                              unit: BlueSTSDKFeatureMotorTimeParameters.FEATURE_SPEED_UNIT,
                              type: .float,
                              min: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_SPEED_MIN),
                              max: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_SPEED_MAX)),
        BlueSTSDKFeatureField(name: BlueSTSDKFeatureMotorTimeParameters.FEATURE_DATA_NAME[5],
                              unit: BlueSTSDKFeatureMotorTimeParameters.FEATURE_SPEED_UNIT,
                              type: .float,
                              min: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_SPEED_MIN),
                              max: NSNumber(value: BlueSTSDKFeatureMotorTimeParameters.DATA_SPEED_MAX)),
        ];
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureMotorTimeParameters.FEATURE_NAME)
    }

    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureMotorTimeParameters.FIELDS;
    }

    private static func extractFloatOrNan(_ sample:BlueSTSDKFeatureSample,_ index:Int)->Float{
        guard sample.data.count>index else{
            return Float.nan
        }
        return sample.data[index].floatValue
    }
    
    public static func getAccPeackX(_ sample:BlueSTSDKFeatureSample)->Float{
        return extractFloatOrNan(sample,0)
    }
    
    public static func getAccPeackY(_ sample:BlueSTSDKFeatureSample)->Float{
        return extractFloatOrNan(sample,1)
    }
    
    public static func getAccPeackZ(_ sample:BlueSTSDKFeatureSample)->Float{
        return extractFloatOrNan(sample,2)
    }
  
    public static func getRMSSpeedX(_ sample:BlueSTSDKFeatureSample)->Float{
        return extractFloatOrNan(sample,3)
    }
    
    public static func getRMSSpeedY(_ sample:BlueSTSDKFeatureSample)->Float{
        return extractFloatOrNan(sample,4)
    }
    
    public static func getRMSSpeedZ(_ sample:BlueSTSDKFeatureSample)->Float{
        return extractFloatOrNan(sample,5)
    }

    
    public override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < 18){
            NSException(name: NSExceptionName(rawValue: "Invalid data "),
                        reason: "There are no 18 bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let nsData = data as NSData
        let uintOffset = UInt(offset)
        let maxAccX = Float(nsData.extractLeInt16(fromOffset: uintOffset + 0))/100.0
        let maxAccY = Float(nsData.extractLeInt16(fromOffset: uintOffset + 2))/100.0
        let maxAccZ = Float(nsData.extractLeInt16(fromOffset: uintOffset + 4))/100.0
        
        let speedX = nsData.extractLeFloat(fromOffset: uintOffset + 6)
        let speedY = nsData.extractLeFloat(fromOffset: uintOffset + 10)
        let speedZ = nsData.extractLeFloat(fromOffset: uintOffset + 14)
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp,
                                            data: [NSNumber(value: maxAccX),
                                                   NSNumber(value: maxAccY),
                                                   NSNumber(value: maxAccZ),
                                                   NSNumber(value: speedX),
                                                   NSNumber(value: speedY),
                                                   NSNumber(value: speedZ)])
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 18)
    }
}

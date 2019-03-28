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

public class BlueSTSDKFeaturePredictiveSpeedStatus : BlueSTSDKFeaturePredictiveStatus{
    public typealias Status = BlueSTSDKFeaturePredictiveStatus.Status

    private static let FEATURE_NAME = "PredictiveSpeedStatus"
    
    private static func buildSpeedField(name:String)->BlueSTSDKFeatureField{
        return BlueSTSDKFeatureField(name: name, unit: "mm/s", type: .float,
                                     min: NSNumber(value:0.0),
                                     max: NSNumber(value:Float.greatestFiniteMagnitude))
    }
    
    private static let FIELDS:[BlueSTSDKFeatureField] = [
         BlueSTSDKFeaturePredictiveStatus.buildStatusField(name: "StatusAcc_X"),
         BlueSTSDKFeaturePredictiveStatus.buildStatusField(name: "StatusAcc_Y"),
         BlueSTSDKFeaturePredictiveStatus.buildStatusField(name: "StatusAcc_Z"),
         BlueSTSDKFeaturePredictiveSpeedStatus.buildSpeedField(name: "RMSSpeed_X"),
         BlueSTSDKFeaturePredictiveSpeedStatus.buildSpeedField(name: "RMSSpeed_Y"),
         BlueSTSDKFeaturePredictiveSpeedStatus.buildSpeedField(name: "RMSSpeed_Z")
    ]
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return  BlueSTSDKFeaturePredictiveSpeedStatus.FIELDS
    }
    
    public static func getStatusX(_ sample:BlueSTSDKFeatureSample)->Status{
        return sample.extractStatus(index: 0)
    }
    
    public static func getStatusY(_ sample:BlueSTSDKFeatureSample)->Status{
        return sample.extractStatus(index: 1)
    }
    
    public static func getStatusZ(_ sample:BlueSTSDKFeatureSample)->Status{
        return sample.extractStatus(index: 2)
    }
    
    public static func getSpeedX(_ sample:BlueSTSDKFeatureSample)->Float{
        return sample.extractFloat(index: 3)
    }
    
    public static func getSpeedY(_ sample:BlueSTSDKFeatureSample)->Float{
        return sample.extractFloat(index: 4)
    }
    
    public static func getSpeedZ(_ sample:BlueSTSDKFeatureSample)->Float{
        return sample.extractFloat(index: 5)
    }
    
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name:  BlueSTSDKFeaturePredictiveSpeedStatus.FEATURE_NAME)
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < 12){
            NSException(name: NSExceptionName(rawValue: "Invalid data"),
                        reason: "There are no 12 bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let uintOffset = UInt(offset)
        let status = data[intOffset]
        let accX = (data as NSData).extractLeFloat(fromOffset: uintOffset+1)
        let accY = (data as NSData).extractLeFloat(fromOffset: uintOffset+5)
        let accZ = (data as NSData).extractLeFloat(fromOffset: uintOffset+9)
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp,
                                            data: [
                                                 BlueSTSDKFeaturePredictiveStatus.extractXStatus(status).toNumber(),
                                                 BlueSTSDKFeaturePredictiveStatus.extractYStatus(status).toNumber(),
                                                 BlueSTSDKFeaturePredictiveStatus.extractZStatus(status).toNumber(),
                                                NSNumber(value: accX),
                                                NSNumber(value: accY),
                                                NSNumber(value: accZ) ])
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 12)
    }
}


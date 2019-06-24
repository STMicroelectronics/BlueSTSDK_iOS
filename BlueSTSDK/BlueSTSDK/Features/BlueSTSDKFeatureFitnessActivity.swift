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

public class BlueSTSDKFeatureFitnessActivity : BlueSTSDKFeature{
    private static let FEATURE_NAME = "Fitness Activity";
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "Activity", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt8.max)),
        BlueSTSDKFeatureField(name: "Activity counter", unit: nil, type: .uInt16,
                              min: NSNumber(value: 0), max: NSNumber(value:UInt16.max)),
    ];
    
    public enum ActivityType : UInt8, CaseIterable {
        public typealias RawValue = UInt8
        case noActivity = 0x00
        case bicep_curl = 0x01
        case squat = 0x02
        case push_up = 0x03
    }
    
    public static func getActivityType( _ sample:BlueSTSDKFeatureSample) -> ActivityType?{
        guard sample.data.count > 0 else{
                return nil
        }
        return ActivityType(rawValue: sample.data[0].uint8Value)
    }
    
    public static func getActivityCount(_ sample:BlueSTSDKFeatureSample) -> UInt16?{
        guard sample.data.count > 1 else{
            return nil
        }
        return sample.data[1].uint16Value
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureFitnessActivity.FIELDS;
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureFitnessActivity.FEATURE_NAME)
    }
    
    public func enableActivity(_ activity:ActivityType){
        write(Data([activity.rawValue]))
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < 3){
            NSException(name: NSExceptionName(rawValue: "Invalid data"),
                        reason: "There are no 3 bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let activity = data[intOffset]
        let counter = (data as NSData).extractLeUInt16(fromOffset: UInt(intOffset+1))
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp,
                                            data: [
                                                NSNumber(value: activity),
                                                NSNumber(value: counter)])
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 3)
    }
    
}

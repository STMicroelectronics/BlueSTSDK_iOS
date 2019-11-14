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
public class BlueSTSDKFeatureActivity : BlueSTSDKFeature {
    private static let FEATURE_NAME = "Activity Recognition";
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "Activity", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value:7)),
        BlueSTSDKFeatureField(name: "Date", unit: nil, type: .double,
                              min: NSNumber(value: 0),
                              max: NSNumber(value: Double.infinity)),
        BlueSTSDKFeatureField(name: "AlgorithmId", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0),
                              max: NSNumber(value: UInt8.max)),
    ];
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureActivity.FIELDS;
    }
    
    public static func getAlgorithmId(_ sample: BlueSTSDKFeatureSample) -> UInt8{
        guard sample.data.count > 2 else{
            return 0;
        }
        return sample.data[2].uint8Value
    }
    
    public static func getType(_ sample:BlueSTSDKFeatureSample)->ActivityType{
        guard sample.data.count > 0 else {
            return ActivityType.error
        }
        let rawValue = sample.data[0].uint8Value
        return ActivityType.init(rawValue: rawValue) ?? ActivityType.error
    }
    
    public static func getDate( _ sample:BlueSTSDKFeatureSample)->Date?{
        guard sample.data.count > 1 else{
            return nil
        }
        let timeMs = sample.data[1].doubleValue/1000.0
        return Date(timeIntervalSinceReferenceDate: timeMs)
    }
    
    public enum ActivityType : UInt8{
        public typealias RawValue = UInt8
        /**
         *  we don't have enough data for select an activity
         */
        case noActivity = 0x0
        /**
         *  the person is standing
         */
        case standing = 0x01
        /**
         *  the person is walking
         */
        case walking = 0x02
        /**
         *  the person is fast walking
         */
        case fastWalking = 0x03
        /**
         *  the person is jogging
         */
        case jogging = 0x04
        /**
         *  the person is biking
         */
        case biking = 0x05
        /**
         *  the person is driving
         */
        case driving = 0x06
        /**
         * the person is doing the stairs
         */
        case stairs = 0x07
        /**
         *  unknown activity
         */
        case error = 0xFF
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureActivity.FEATURE_NAME)
    }
    
    
    private func extractActivityDataAndAlgorithm(_ timestamp: UInt64, data: Data,
        dataOffset offset: Int) -> BlueSTSDKExtractResult {
        let data = [
            NSNumber(value: data[offset]),
            NSNumber(value: Date.timeIntervalSinceReferenceDate*1000.0),
            NSNumber(value: data[offset+1]),
        ]
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp,
                                            data: data)
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 2)
    }
    
    private func extractActivityData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: Int) -> BlueSTSDKExtractResult {
        let data = [
            NSNumber(value: data[offset]),
            NSNumber(value: Date.timeIntervalSinceReferenceDate*1000.0)
        ]
        
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp,
                                            data: data)
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 1)
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        let packageSize = data.count-intOffset
        
        switch packageSize {
            case Int.min..<1 :
                NSException(name: NSExceptionName(rawValue: "Invalid Activity data "),
                            reason: "There are no bytes available to read",
                            userInfo: nil).raise()
                return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
            case 1 :
                return extractActivityData(timestamp, data: data, dataOffset: intOffset)
            default: // else
                return extractActivityDataAndAlgorithm(timestamp, data: data, dataOffset: intOffset)
        }
        
    }
}

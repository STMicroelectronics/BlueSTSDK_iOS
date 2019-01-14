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
public class BlueSTSDKFeatureAudioSceneCalssification : BlueSTSDKFeature {
    private static let FEATURE_NAME = "Audio Scene Classification";
    private static let FIELDS:[BlueSTSDKFeatureField] = [
        BlueSTSDKFeatureField(name: "SceneType", unit: nil, type: .uInt8,
                              min: NSNumber(value: 0), max: NSNumber(value:3))
        ];
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return BlueSTSDKFeatureAudioSceneCalssification.FIELDS;
    }
    
    public static func getScene(_ sample:BlueSTSDKFeatureSample)->Scene{
        guard sample.data.count > 0 else {
            return Scene.Unknown
        }
        let rawValue = sample.data[0].uint8Value
        return Scene.init(rawValue: rawValue) ?? Scene.Unknown
    }
    
    public enum Scene : UInt8{
        public typealias RawValue = UInt8
        case Unknown = 0xFF
        case Indoor = 0x00
        case Outdoor = 0x01
        case InVehicle = 0x02
    }
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: BlueSTSDKFeatureAudioSceneCalssification.FEATURE_NAME)
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        if((data.count-intOffset) < 1){
            NSException(name: NSExceptionName(rawValue: "Invalid Audio Scene Classification data "),
                        reason: "There are no bytes available to read",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp,
                                            data: [NSNumber(value: data[intOffset])])
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 1)
    }
}

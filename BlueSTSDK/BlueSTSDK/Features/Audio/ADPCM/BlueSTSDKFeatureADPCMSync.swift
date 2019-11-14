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
* Feature that export the information needed for decode an ADPCM stream
*
* @author STMicroelectronics - Central Labs.
*/
public class BlueSTSDKFeatureAudioADPCMSync : BlueSTSDKFeatureGenericAudio {
    
    private static let INDEX_INDEX = 0
    private static let PREDSAMPLE_INDEX = 1
    private static let FEATURE_NAME = "Audio Sync";
    private static let FIELDS:[BlueSTSDKFeatureField] = [
       BlueSTSDKFeatureField(name: "ADPCM_index", unit: nil, type: .int16,
                             min: NSNumber(value: Int16.min), max: NSNumber(value:Int16.max)),
       BlueSTSDKFeatureField(name: "ADPCM_predSample", unit: nil, type: .int32,
                             min: NSNumber(value: Int32.min), max: NSNumber(value:Int32.max)),
    ];
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: Self.FEATURE_NAME)
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return Self.FIELDS
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        
        if((data.count-intOffset) < 6){
            NSException(name: NSExceptionName(rawValue: "Invalid Audio ADPCM Sync data"),
                        reason: "The feature need almost 6 byte for extract the data",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let index = (data as NSData).extractLeUInt16(fromOffset: UInt(offset+0))
        let prevSampleIdx = (data as NSData).extractLeInt32(fromOffset: UInt(offset+2))
       
        let sample = BlueSTSDKFeatureSample(timestamp: timestamp, data: [
            NSNumber(value: index),
            NSNumber(value: prevSampleIdx)
        ])
    
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 6)
    }
    
    static func getIndex( sample: BlueSTSDKFeatureSample)->Int16{
        if sample.data.count > Self.INDEX_INDEX {
            return sample.data[Self.INDEX_INDEX].int16Value
        }else{
            return 0
        }
    }
    
    static func getPredictedSample( sample:BlueSTSDKFeatureSample) -> Int32{
        if sample.data.count > Self.PREDSAMPLE_INDEX {
            return sample.data[Self.PREDSAMPLE_INDEX].int32Value
        }else{
            return -1
        }
    }
    
}

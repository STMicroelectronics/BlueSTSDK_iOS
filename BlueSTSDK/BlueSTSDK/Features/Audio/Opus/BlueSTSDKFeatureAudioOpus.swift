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

public class BlueSTSDKFeatureAudioOpus : BlueSTSDKFeatureGenericAudio, BlueSTSDKAudioDecoder {
    public func getAudio(from sample:BlueSTSDKFeatureSample) -> Data? {
        return Self.getAudio(from:sample)
    }
    
    public var codecManager: BlueSTSDKAudioCodecManager {
        return mOpusManager
    }
    
    private let mOpusManager = BlueSTSDKOpusManager()
    private let mOpusDecoder = OpusDecoderStatus()
    
    private static let FEATURE_NAME = "Audio Opus"
    private static let FIELDS = [
        BlueSTSDKFeatureField(name: "OpusStrem", unit: nil, type: .int16Array,
                              min: NSNumber(value: Int16.min),
                              max: NSNumber(value: Int16.max))
    ]
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: Self.FEATURE_NAME)
    }
    
    public override func extractData(_ timestamp: UInt64, data: Data, dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let decodedData = mOpusDecoder.decode(rawData: data, codecSettings: mOpusManager)
        let sample = decodedData != nil ? BlueSTSDKFeatureSample(data: decodedData!) : nil
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: UInt32(data.count))
    }
    
    public static func getAudio(from sample:BlueSTSDKFeatureSample) -> Data?{
        var outData = Data(capacity: sample.data.count*2)
        sample.data.forEach{ value in
            var shortValue = value.int16Value
            let valueBuffer = UnsafeBufferPointer(start: &shortValue, count: 1)
            outData.append(valueBuffer)
        }
        return outData
    }
    
}

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

public class BlueSTSDKFeatureAudioOpusConf : BlueSTSDKFeatureGenericAudio {
    private static let FEATURE_NAME = "Audio Opus Conf";
    private static let FIELDS:[BlueSTSDKFeatureField] = [
       BlueSTSDKFeatureField(name: "OpusCommandId", unit: nil, type: .int8,
                             min: NSNumber(value: Int8.min), max: NSNumber(value:Int8.max)),
       BlueSTSDKFeatureField(name: "OpusCommandPayload", unit: nil, type: .uInt8Array,
                             min: NSNumber(value: UInt8.min), max: NSNumber(value:UInt8.max)),
    ];
    
    static let DEFAULT_FRAME_SIZE = Float(20)
    static let DEFAULT_SAMPLING_FREQ = 16000
    static let DEFAULT_NUM_CHANNEL = 1
    //static let DEFAULT_DECODED_FRAME_SIZE = (DEFAULT_SAMPLING_FREQ/1000)*DEFAULT_FRAME_SIZE
    
    private static let COMMAND_INDEX = 0
    private static let COMMAND_INDEX_ONOFF = 1
    private static let COMMAND_ON_VALUE = 0x10
    
    private static let CONTROL_FRAME_SIZE_INDEX = 1
    private static let CONTROL_SAMPLING_FREQ_INDEX = 2
    private static let CONTROL_CHANNEL_INDEX = 3
    
    private static let OPUS_CMD_CONF = UInt8(0x0B)
    private static let OPUS_CMD_CONTROL = UInt8(0x0A)
    
    public override init(whitNode node: BlueSTSDKNode) {
        super.init(whitNode: node, name: Self.FEATURE_NAME)
    }
    
    public override func getFieldsDesc() -> [BlueSTSDKFeatureField] {
        return Self.FIELDS
    }
        
    public override func extractData(_ timestamp: UInt64, data: Data,
                                     dataOffset offset: UInt32) -> BlueSTSDKExtractResult {
        let intOffset = Int(offset)
        
        guard ((data.count-intOffset) == 2 || (data.count-intOffset) == 4 ) else {
            NSException(name: NSExceptionName(rawValue: "Invalid Audio Opus Conf data"),
                        reason: "Received command not recognized (nor 2 or 4 bytes length)",
                        userInfo: nil).raise()
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
        
        let commandId = data[Self.COMMAND_INDEX]
        switch commandId {
        case Self.OPUS_CMD_CONF:
            return extractConfigurationData(data)
        case Self.OPUS_CMD_CONTROL:
            return extractControlData(data)
        default:
            return BlueSTSDKExtractResult(whitSample: nil, nReadData: 0)
        }
    }
        
    private func extractControlData(_ rawData:Data) -> BlueSTSDKExtractResult{
        let command = rawData[Self.COMMAND_INDEX]
        let onOff = rawData[Self.COMMAND_INDEX_ONOFF] == Self.COMMAND_ON_VALUE
        let sample = BlueSTSDKFeatureSample(whitData: [
            NSNumber(value:command),
            NSNumber(value:onOff)
        ])
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 2)
    }
    
    private static let FRAME_SIZE_MAP:[UInt8:Float] = [
        0x20 : 2.5,
        0x21 : 5.0,
        0x22 : 10.0,
        0x23 : 20.0,
        0x24 : 40.0,
        0x25 : 60.0
    ]
    
    private func extractFrameSize(_ rawValue:UInt8) -> Float{
        let frameSize = Self.FRAME_SIZE_MAP[rawValue]
        return frameSize ?? Float(Self.DEFAULT_FRAME_SIZE)
    }
    
    private static let SAMPLING_FREQ_MAP:[UInt8:Int] = [
        0x30 : 8000,
        0x31 : 16000,
        0x32 : 32000,
        0x33 : 48000
    ]
    
    private func extractSamplingFreq(_ rawValue:UInt8) -> Int{
        let samplingFreq = Self.SAMPLING_FREQ_MAP[rawValue]
        return samplingFreq ?? Self.DEFAULT_SAMPLING_FREQ
    }
    
    private static let CHANNEL_MAP:[UInt8:Int] = [
        0x40 : 1,
        0x41 : 2
    ]
    
    private func extractChannel( _ rawValue:UInt8) -> Int {
        let channel = Self.CHANNEL_MAP[rawValue]
        return channel ?? Self.DEFAULT_NUM_CHANNEL
    }
    
    private func extractConfigurationData(_ rawData:Data) -> BlueSTSDKExtractResult{
        let command = rawData[Self.COMMAND_INDEX]
        let frameSize = extractFrameSize(rawData[Self.CONTROL_FRAME_SIZE_INDEX])
        let samplingFreq = extractSamplingFreq(rawData[Self.CONTROL_SAMPLING_FREQ_INDEX])
        let channel = extractChannel(rawData[Self.CONTROL_CHANNEL_INDEX])
        
        let sample = BlueSTSDKFeatureSample(whitData: [
            NSNumber(value:command),
            NSNumber(value:frameSize),
            NSNumber(value:samplingFreq),
            NSNumber(value:channel),
        ])
        
        return BlueSTSDKExtractResult(whitSample: sample, nReadData: 4)
        
    }
    
    public static func getFrameSize(_ sample:BlueSTSDKFeatureSample) -> Float{
        if( sample.data.count > CONTROL_FRAME_SIZE_INDEX && isConfigurationPackage(sample)){
            return sample.data[CONTROL_FRAME_SIZE_INDEX].floatValue
        }
        return DEFAULT_FRAME_SIZE
    }
    
    public static func getSamplingFrequency(_ sample:BlueSTSDKFeatureSample) -> Int{
        if( sample.data.count > CONTROL_SAMPLING_FREQ_INDEX && isConfigurationPackage(sample) ){
            return sample.data[CONTROL_SAMPLING_FREQ_INDEX].intValue
        }
        return DEFAULT_SAMPLING_FREQ
    }
    
    public static func getChannel(_ sample:BlueSTSDKFeatureSample) -> Int{
        if( sample.data.count > CONTROL_CHANNEL_INDEX && isConfigurationPackage(sample)){
            return sample.data[CONTROL_CHANNEL_INDEX].intValue
        }
        return DEFAULT_NUM_CHANNEL
    }
    
    public static func isControlPackage(_ sample:BlueSTSDKFeatureSample) -> Bool {
        if (sample.data.count > COMMAND_INDEX){
            return sample.data[COMMAND_INDEX].uint8Value == Self.OPUS_CMD_CONTROL
        }
        return false
    }
 
    public static func isConfigurationPackage(_ sample:BlueSTSDKFeatureSample) -> Bool {
        if (sample.data.count > COMMAND_INDEX){
            return sample.data[COMMAND_INDEX].uint8Value == Self.OPUS_CMD_CONF
        }
        return false
    }
    
    public static func requestEnableStream(_ sample:BlueSTSDKFeatureSample) -> Bool{
        if( sample.data.count > COMMAND_INDEX_ONOFF && isControlPackage(sample) ){
            return sample.data[COMMAND_INDEX_ONOFF].boolValue
        }
        return false
    }
    
}

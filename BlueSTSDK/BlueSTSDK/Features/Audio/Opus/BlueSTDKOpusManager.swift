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

class BlueSTSDKOpusManager: BlueSTSDKAudioCodecManager{
    
    public let codecName = "Opus"
    public private(set) var samplingFequency = BlueSTSDKFeatureAudioOpusConf.DEFAULT_SAMPLING_FREQ
    public private(set) var channels = BlueSTSDKFeatureAudioOpusConf.DEFAULT_NUM_CHANNEL
    public private(set) var bytesPerSample = 2
    public var isAudioEnabled = true
    
    private(set) var frameSize = BlueSTSDKFeatureAudioOpusConf.DEFAULT_FRAME_SIZE
    
    public var samplePerBlock:Int{
        return Int(Float(samplingFequency)*frameSize)/1000
    }
    
    func reinit() {
        
    }
    
    func updateParameters(from sample: BlueSTSDKFeatureSample) {
        if BlueSTSDKFeatureAudioOpusConf.isControlPackage(sample){
            self.isAudioEnabled = BlueSTSDKFeatureAudioOpusConf.requestEnableStream(sample)
        } else if BlueSTSDKFeatureAudioOpusConf.isConfigurationPackage(sample){
            samplingFequency = BlueSTSDKFeatureAudioOpusConf.getSamplingFrequency(sample)
            channels = BlueSTSDKFeatureAudioOpusConf.getChannel(sample)
            frameSize = BlueSTSDKFeatureAudioOpusConf.getFrameSize(sample)
            
        }
    }
}

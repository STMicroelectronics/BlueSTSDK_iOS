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

class BlueSTSDKADPCMManager: BlueSTSDKAudioCodecManager {
    
    
    public let codecName = "ADPCM"
    public let samplingFequency = 8000
    public let channels = 1
    public let bytesPerSample = 2
    public let samplePerBlock = 40
    public var isAudioEnabled = true
    
    private(set) var adpcm_index_in:Int16=0;
    private(set) var adpcm_predsample_in:Int32=0;
    private(set) var intra_flag=false;
    
    public func reinit() {
        intra_flag = false
    }
    
    public func updateParameters(from sample:BlueSTSDKFeatureSample) {
        intra_flag = true
        adpcm_index_in = BlueSTSDKFeatureAudioADPCMSync.getIndex(sample: sample)
        adpcm_predsample_in = BlueSTSDKFeatureAudioADPCMSync.getPredictedSample(sample: sample)
    }
    
}

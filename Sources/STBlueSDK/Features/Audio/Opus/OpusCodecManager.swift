//
//  OpusCodecManager.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class OpusCodecManager: AudioCodecManager {
    
    public let codecName = "Opus"
    public private(set) var samplingFequency = OpusConstants.defaultSamplingFreq
    public private(set) var channels = OpusConstants.defaultNumberOfChannel
    public private(set) var bytesPerSample = 2
    public var isAudioEnabled = true

    private(set) var frameSize = OpusConstants.defaultFrameSize
    
    public var samplePerBlock: Int {
        Int(Float(samplingFequency) * frameSize) / 1000
    }
    
    func reinit() {
        
    }
    
    func updateParameters(from sample: AnyFeatureSample) {
        
        guard let sample = sample as? FeatureSample<OpusConfData>,
              let data = sample.data else { return }
        
        if data.isControlPackage {
            isAudioEnabled = data.isRequestEnableStream
        } else if data.isConfigurationPackage {
            samplingFequency = data.samplingFreq.value ?? OpusConstants.defaultSamplingFreq
            channels = data.channel.value ?? OpusConstants.defaultNumberOfChannel
            frameSize = data.frameSize.value ?? OpusConstants.defaultFrameSize
        }
    }
}

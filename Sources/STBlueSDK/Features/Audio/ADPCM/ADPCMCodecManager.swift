//
//  ADPCMCodecManager.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class ADPCMCodecManager {

    public let codecName = "ADPCM"
    public let samplingFequency = 8000
    public let channels = 1
    public let bytesPerSample = 2
    public let samplePerBlock = 40
    public var isAudioEnabled = true
    
    private(set) var adpcmIndexIn: Int16 = 0
    private(set) var adpcmPredictedSampleIn: Int32 = 0
    private(set) var intraFlag = false
    
}

extension ADPCMCodecManager: AudioCodecManager {
    func reinit() {
        intraFlag = false
    }
    
    func updateParameters(from sample: AnyFeatureSample) {
        
        intraFlag = true
        
        guard let sample = sample as? FeatureSample<AudioSyncData>,
              let data = sample.data,
              let index =  data.index.value,
              let predictedSample = data.predictedSample.value else {
            adpcmIndexIn = 0
            adpcmPredictedSampleIn = -1
            return
        }
        
        adpcmIndexIn = index
        adpcmPredictedSampleIn = predictedSample
    }
}

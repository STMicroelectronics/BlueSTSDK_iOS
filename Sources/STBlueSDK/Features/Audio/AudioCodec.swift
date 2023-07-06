//
//  AudioCodec.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol AudioCodecSettings {
    var codecName: String { get }
    /// codec frequency in hz
    var samplingFequency: Int { get }
    /// number of audio channel into the streaming
    var channels: Int { get }
    /// byte used to rappresent an audio sample
    var bytesPerSample: Int { get }
    /// decoded bytes obtined after each ble ble notification
    var samplePerBlock: Int { get }
}

public protocol AudioCodecManager: AudioCodecSettings {
    var isAudioEnabled: Bool { get }
    func reinit()
    func updateParameters(from sample: AnyFeatureSample)
}

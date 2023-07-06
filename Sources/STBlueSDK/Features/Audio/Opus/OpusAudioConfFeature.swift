//
//  OpusConf.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal struct OpusConf {
    struct Command {
        static let index = 0
        static let indexOnOff = 1
        static let onValue = 0x10
        static let commandId: UInt8 = 0x0B
    }

    struct Control {
        static let frameSizeIndex = 1
        static let sampligFreqIndex = 2
        static let channelIndex = 3
        static let commandId: UInt8 = 0x0A
    }
    
    static let frameSizeMap: [UInt8:Float] = [
        0x20 : 2.5,
        0x21 : 5.0,
        0x22 : 10.0,
        0x23 : 20.0,
        0x24 : 40.0,
        0x25 : 60.0
    ]
    
    static let samplingFreqMap: [UInt8:Int] = [
        0x30 : 8000,
        0x31 : 16000,
        0x32 : 32000,
        0x33 : 48000
    ]
    
    static let channelMap: [UInt8:Int] = [
        0x40 : 1,
        0x41 : 2
    ]
}

public class OpusAudioConfFeature: AudioFeature<OpusConfData> {
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
    
        if data.count - offset != 2 || data.count - offset != 4 {
            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
        }
        
        let commandId = data[OpusConf.Command.index]
        
        if commandId == OpusConf.Command.commandId || commandId == OpusConf.Control.commandId {
            let parsedData = OpusConfData(with: data, offset: offset)
            let size = commandId == OpusConf.Command.commandId ? 2 : 4
            return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), size)
        } else {
            return (FeatureSample(with: nil, rawData: data), 0)
        }
    }

    public override func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse {
        response
    }
}

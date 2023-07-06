//
//  OpusConfData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct OpusConfData {
    
    let commandId: FeatureField<UInt8>
    let onOff: FeatureField<Bool>
    
    let frameSize: FeatureField<Float>
    let samplingFreq: FeatureField<Int>
    let channel: FeatureField<Int>
    
    init(with data: Data, offset: Int) {
    
        let commandId = data[OpusConf.Command.index]
        let onOff = commandId == OpusConf.Command.commandId ? (data[OpusConf.Command.indexOnOff] == OpusConf.Command.onValue) : nil
        
        var framsSize: Float?
        var samplingFreq: Int?
        var channel: Int?
        
        if commandId == OpusConf.Control.commandId {
            framsSize = OpusConf.frameSizeMap[data[OpusConf.Control.frameSizeIndex]]
            samplingFreq = OpusConf.samplingFreqMap[data[OpusConf.Control.sampligFreqIndex]]
            channel = OpusConf.channelMap[data[OpusConf.Control.channelIndex]]
        }
        
        self.commandId = FeatureField<UInt8>(name: "OpusCommandId",
                                             uom: nil,
                                             min: nil,
                                             max: nil,
                                             value: commandId)
        
        self.onOff = FeatureField<Bool>(name: "OpusOnOff",
                                        uom: nil,
                                        min: nil,
                                        max: nil,
                                        value: onOff)
        
        self.frameSize = FeatureField<Float>(name: "OpusFrameSize",
                                             uom: nil,
                                             min: nil,
                                             max: nil,
                                             value: framsSize)
        
        self.samplingFreq = FeatureField<Int>(name: "OpusSampligFreq",
                                              uom: nil,
                                              min: nil,
                                              max: nil,
                                              value: samplingFreq)
        
        self.channel = FeatureField<Int>(name: "OpusChannel",
                                         uom: nil,
                                         min: nil,
                                         max: nil,
                                         value: channel)
    }
}

public extension OpusConfData {
    var isControlPackage: Bool {
        guard let commandId = commandId.value,
              commandId == OpusConf.Control.commandId else { return false }
        
        return true
    }
    
    var isConfigurationPackage: Bool {
        guard let commandId = commandId.value,
              commandId == OpusConf.Command.commandId else { return false }
        
        return true
    }
    
    var isRequestEnableStream: Bool {
        guard let unwrappedOnOff = onOff.value,
              isControlPackage else { return false }

        return unwrappedOnOff
    }

}

extension OpusConfData: CustomStringConvertible {
    public var description: String {
        "n/a"
    }
}

extension OpusConfData: Loggable {
    public var logHeader: String {
        "n/a"
    }
    
    public var logValue: String {
        "n/a"
    }
}

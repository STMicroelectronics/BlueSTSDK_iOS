//
//  MicLevelsData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct MicLevelsData {
    
    public var micLevels: [FeatureField<Int8>]
    
    init(with data: Data, offset: Int) {
        
        var micLevels = [FeatureField<Int8>]()
        
        for index in 0..<data.count - offset {
            let micLevel = Int8(data.extractUInt8(fromOffset: offset + index))
            
            micLevels.append(FeatureField<Int8>(name: "Mic \(index)",
                                                uom: "dB",
                                                min: 0,
                                                max: 127,
                                                value: micLevel))
        }
        
        self.micLevels = micLevels
    }
    
}

extension MicLevelsData: CustomStringConvertible {
    public var description: String {
        
        var descr = ""
        
        for (index, element) in micLevels.enumerated() {
            descr += "\(element.name) level: \(element.value ?? -1)"
            if index != 0 {
                descr += ","
            }
        }
        
        return descr.count > 0 ? descr : "No mic available"
    }
}

extension MicLevelsData: Loggable {
    public var logHeader: String {
        micLevels.logHeader
    }
    
    public var logValue: String {
        micLevels.logValue
    }
    
}

extension Array {
    var logHeader: String {
        var descr = ""
        
        for (index, element) in self.enumerated() {
            if let element = element as? Loggable {
                descr += element.logHeader
                if index != 0 {
                    descr += ","
                }
            }
        }
        
        return descr
    }
    
    var logValue: String {
        var descr = ""
        
        for (index, element) in self.enumerated() {
            if let element = element as? Loggable {
                descr += element.logValue
                if index != 0 {
                    descr += ","
                }
            }
        }
        
        return descr
    }
}

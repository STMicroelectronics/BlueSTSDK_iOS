//
//  AudioClassificationData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum AudioClass: UInt8 {
    case unknown = 0xFF
    case indoor = 0x00
    case outdoor = 0x01
    case inVehicle = 0x02
    case babyIsCrying = 0x03
    case off = 0xF0
    case on = 0xF1
}

extension AudioClass: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .indoor:
            return "Indoor"
        case .outdoor:
            return "Outdoor"
        case .inVehicle:
            return "In Vehicle"
        case .babyIsCrying:
            return "Baby is Crying"
        case .off:
            return "Paused"
        case .on:
            return "Running"
        }
    }
}

public struct AudioClassificationData {
    
    public var algorithm: FeatureField<UInt8>? = nil
    public var audioClass: FeatureField<AudioClass>? = nil
    
    init(with data: Data, offset: Int) {
        
        var algorithm : UInt8? = nil
        var audioClass: AudioClass? = nil
        
        if data.count - offset == 1 {
            audioClass = AudioClass(rawValue: data.extractUInt8(fromOffset: offset))
        } else if data.count - offset > 1 {
            algorithm = data.extractUInt8(fromOffset: offset)
            audioClass = AudioClass(rawValue: data.extractUInt8(fromOffset: offset + 1))
        }
        
        self.algorithm = FeatureField<UInt8>(name: "Algorithm",
                                             uom: nil,
                                             min: 0,
                                             max: 0xFF,
                                             value: algorithm)
        
        self.audioClass = FeatureField<AudioClass>(name: "SceneType",
                                                   uom: nil,
                                                   min: nil,
                                                   max: nil,
                                                   value: audioClass)
    }
    
}

extension AudioClassificationData: CustomStringConvertible {
    public var description: String {
        
        let algorithm = algorithm?.value ?? 0
        let audioClass = audioClass?.value ?? .off
        
        return String(format: "Algorithm: %zd\nAudioClass: %@", algorithm, audioClass.description)
    }
}

extension AudioClassificationData: Loggable {
    public var logHeader: String {
        "\(algorithm?.logHeader ?? ""),\(audioClass?.logHeader ?? "")"
    }
    
    public var logValue: String {
        "\(algorithm?.logValue ?? ""),\(audioClass?.logValue ?? "")"
    }
    
}


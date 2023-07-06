//
//  SDLoggingData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum SDLoggingStatus: UInt8 {
    case stopped = 0x00
    case started = 0x01
    case noSD = 0x02
    case error = 0xFF
}

extension SDLoggingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .stopped:
            return "Stopped"
        case .started:
            return "Started"
        case .noSD:
            return "No SD"
        case .error:
            return "IO Error"
        }
    }
}

public struct SDLoggingData {
    
    public let logStatus: FeatureField<SDLoggingStatus>
    public let loggedFeatureMask: FeatureField<UInt32>
    public let logInterval: FeatureField<UInt32>
    
    init(with data: Data, offset: Int) {
        
        let logStatus = SDLoggingStatus(rawValue: data.extractUInt8(fromOffset: offset))
        let loggedFeature = data.extractUInt32(fromOffset: offset + 1)
        let logInterval = data.extractUInt32(fromOffset: offset + 5)
        
        
        self.logStatus = FeatureField<SDLoggingStatus>(name: "logStatus",
                                                       uom: nil,
                                                       min: nil,
                                                       max: nil,
                                                       value: logStatus)
        
        self.loggedFeatureMask = FeatureField<UInt32>(name: "loggedFeature",
                                                      uom: nil,
                                                      min: 0,
                                                      max: UInt32.max,
                                                      value: loggedFeature)
        
        self.logInterval = FeatureField<UInt32>(name: "logInterval",
                                                uom: "s",
                                                min: 0,
                                                max: UInt32.max,
                                                value: logInterval)
    }
    
}

public extension SDLoggingData {
    func featuresLogged(with node: Node) -> [Feature] {
        guard let loggedFeatureMask = loggedFeatureMask.value else { return [] }
        
        return loggedFeatureMask.features(for: node)
    }
}

extension SDLoggingData: CustomStringConvertible {
    public var description: String {
        
        let logStatus = logStatus.value ?? .error
        let loggedFeature = loggedFeatureMask.value ?? 0
        let logInterval = logInterval.value ?? 0
        
        return String(format: "Log Status: %@, Logged Feature Mask: %zd, Log Interval: %zd", logStatus.description, loggedFeature, logInterval)
    }
}

extension SDLoggingData: Loggable {
    public var logHeader: String {
        "\(logStatus.logHeader),\(loggedFeatureMask.logHeader),\(logInterval.logHeader)"
    }
    
    public var logValue: String {
        "\(logStatus.logValue),\(loggedFeatureMask.logValue),\(logInterval.logValue)"
    }
    
}

//
//  AILoggingCommand.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum AILoggingCommand: FeatureCommandType {
    
    case start(features: [Feature],
               environmentalFrequencyHz: Float,
               inertialFrequencyHz: Float,
               audioVolume: Float)
    case stop
    case updateAnnotation(annotation: String)
    
    public var payload: Data? {
        switch self {
        case .start(let features,
                    let environmentalFrequencyHz,
                    let inertialFrequencyHz,
                    let audioVolume):
            var data = Data()
            var featuresMask: UInt32 = 0
            
            for feature in features {
                featuresMask |= feature.type.mask
            }
            
            withUnsafeBytes(of: featuresMask.bigEndian) { data.append(contentsOf: $0) }
            
            let intEnviromentalFreq = UInt16((environmentalFrequencyHz * 10.0).rounded())
            withUnsafeBytes(of: intEnviromentalFreq.bigEndian) { data.append(contentsOf: $0) }
            
            let intInertialFreq = UInt16((inertialFrequencyHz * 10.0).rounded())
            withUnsafeBytes(of: intInertialFreq.bigEndian) { data.append(contentsOf: $0) }
            
            let volume = UInt8(audioVolume * 32.0)
            withUnsafeBytes(of: volume.bigEndian) { data.append(contentsOf: $0) }
            
            return data
        case .stop:
            return Data([0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00])
        case .updateAnnotation(annotation: let annotation):
            if let rawStr = annotation.data(using: .utf8) {
                // 18 = 20 (max ble length) -1 (status byte) -1 (string terminator)
                let finalLenght = min(18, rawStr.count)
                var data = Data(capacity: finalLenght + 2)
                data.append(rawStr)
                data.append(0)// '\0'
                return data
            }
            
            return nil
        }
    }
    
    public var useMask: Bool {
        false
    }
    
    public func data(with nodeId: UInt8) -> Data {
        switch self {
        case .start:
            return Data([AILoggingStatus.started.rawValue])
        case .stop:
            return Data([AILoggingStatus.stoped.rawValue])
        case .updateAnnotation:
            return Data([AILoggingStatus.update.rawValue])
        }
    }
}

extension AILoggingCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .start:
            return "Start logging"
        case .stop:
            return "Stop logging"
        case .updateAnnotation:
            return "Update annotation"
        }
    }
}

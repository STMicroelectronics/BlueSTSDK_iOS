//
//  BlueNRGOtaAckData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum BlueNRGAckError: Error {
    case writeFail_1
    case writeFail_2
    case wrongCrc
    case wrongSequence
    case none
    case unknown
    
    static func error(with number: UInt8) -> BlueNRGAckError {
        switch number {
        case 0xFF:
            return .writeFail_1
        case 0x4D:
            return .writeFail_2
        case 0x0F:
            return .wrongCrc
        case 0xF0:
            return .wrongSequence
        case 0x00:
            return .none
        default:
            return .unknown
        }
    }
}

public struct BlueNRGOtaAckData {

    public let expetedSequence: FeatureField<UInt16>
    public let error: FeatureField<BlueNRGAckError>
    
    init(with data: Data, offset: Int) {
        
        let nextSequence = data.extractUInt16(fromOffset: offset)
        let error = data.extractUInt8(fromOffset: offset + 2)
        
        self.expetedSequence = FeatureField<UInt16>(name: "ExpetedSequence",
                                                    uom: nil,
                                                    min: 0,
                                                    max: UInt16.max,
                                                    value: nextSequence)
        
        self.error = FeatureField<BlueNRGAckError>(name: "Error",
                                                    uom: nil,
                                                    min: nil,
                                                    max: nil,
                                                   value: BlueNRGAckError.error(with: error))
    }

}

extension BlueNRGOtaAckData: CustomStringConvertible {
    public var description: String {
        
        let error = error.value ?? .unknown
        
        if let expetedSequence = expetedSequence.value {
            return String(format: "ExpetedSequence: %zd\nError: %@", expetedSequence, error.localizedDescription)
        }

        return String(format: "ExpetedSequence: %@\nError: %@", "n/a", error.localizedDescription)
    }
}

extension BlueNRGOtaAckData: Loggable {
    public var logHeader: String {
        "\(expetedSequence.logHeader),\(error.logHeader)"
    }
    
    public var logValue: String {
        "\(expetedSequence.logHeader),\(error.logHeader)"
    }
    
    
}

//
//  AILoggingStatus.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum AILoggingStatus: UInt8 {
    case stoped = 0x00
    case started = 0x01
    case missingSD = 0x02
    case ioError = 0x03
    case update = 0x04
    case unknown = 0xFF
}

extension AILoggingStatus: CustomStringConvertible {
    public var description: String {
        switch self {
        case .stoped:
            return "Stopped"
        case .started:
            return "Started"
        case .missingSD:
            return "Missing SD"
        case .ioError:
            return "IO Error"
        case .update:
            return "Update"
        case .unknown:
            return "Unknown"
        }
    }
}

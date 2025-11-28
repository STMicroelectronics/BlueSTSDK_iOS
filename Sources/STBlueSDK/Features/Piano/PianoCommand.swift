//
//  PianoCommand.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum PianoCommand: FeatureCommandType {
    
    case start(key: Int8)
    case stop
    
    var value: UInt8 {
        switch self {
        case .start:
            return 0x01
        case .stop:
            return 0x00
        }
    }
    
    public var description: String {
        switch self {
        case .stop:
            return "Stop play"
        case .start(let key):
            return "Start Playing: \(key)"
        }
    }
    
    public var payload: Data? {
        switch self {
        case .stop:
            return nil
        case .start(let key):
            var data = Data()
            withUnsafeBytes(of: key) { data.append(contentsOf: $0) }
            return data
        }
    }
    
    public var useMask: Bool {
        true
    }
    
    public func data(with nodeId: UInt8) -> Data {
        Data([value])
    }
}

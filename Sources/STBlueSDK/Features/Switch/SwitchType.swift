//
//  SwitchType.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum SwitchType: UInt8, FeatureCommandType, CaseIterable {
    
    case switchOff = 0x00
    case switchOn = 0x01

    public var payload: Data? {
        return nil
    }
    
    public var useMask: Bool {
        true
    }
    
    public func data(with nodeId: UInt8) -> Data {
        Data([rawValue])
    }
}

extension SwitchType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .switchOff:
            return "Switch OFF"
        case .switchOn:
            return "Switch ON"
        }
    }
}

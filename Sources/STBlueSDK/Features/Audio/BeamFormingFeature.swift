//
//  BeamFormingFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation


public enum BeamFormingDirection: UInt8 {
    case top = 1
    case topRight = 2
    case right = 3
    case bottomRight = 4
    case bottom = 5
    case bottomLeft = 6
    case left = 7
    case topLeft = 8
    case unknown = 255
}

public enum BeamType: UInt8 {
    case strong = 0x01
    case asrReady = 0x00
}

private enum BeamFormingPayload: UInt8 {
    case enable = 0x01
    case disable = 0x00
}

public enum BeamFormingCommand: FeatureCommandType {
    
    case enable(enabled: Bool)
    case setDirection(direction: BeamFormingDirection)
    case setBeamType(beamType: BeamType)
    case none
    
    var value: UInt8 {
        switch self {
        case .enable:
            return 0xAA
        case .setDirection:
            return 0xBB
        case .setBeamType:
            return 0xCC
        case .none:
            return 0x00
        }
    }
    
    public var payload: Data? {
        switch self {
        case .enable(let enabled):
            return enabled ? Data([BeamFormingPayload.enable.rawValue]) :
            Data([BeamFormingPayload.disable.rawValue])
        case .setDirection(let direction):
            return Data([direction.rawValue])
        case .setBeamType(let beamType):
            return Data([beamType.rawValue])
        case .none:
            return nil
        }
    }
    
    public var useMask: Bool {
        true
    }
    
    public func data(with nodeId: UInt8) -> Data {
        Data([value])
    }
}

private extension BeamFormingCommand {
    func commandDescription(with text: String, enabled: Bool) -> String {
        "\(enabled ? "Enable" : "Disable") \(text)"
    }
}

extension BeamFormingCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .enable(let enabled):
            return commandDescription(with: "Beam forming", enabled: enabled)
        case .setDirection(let direction):
            return "Set Beam forming direction to: \(direction)"
        case .setBeamType(let beamType):
            return "Set Beam forming type to: \(beamType)"
        case .none:
            return "None"
        }
    }
}

public class BeamFormingFeature: BaseFeature<Data> {
    
}

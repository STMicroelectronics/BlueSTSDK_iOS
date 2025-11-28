//
//  NEAIExtrapolationModel.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum NEAIExtrapolationPhaseType : UInt8, Codable {
    public typealias RawValue = UInt8
    /** idle */
    case IDLE = 0x0
    /** extrapolation */
    case EXTRAPOLATION = 0x01
    /** busy */
    case BUSY = 0x02
    /** null */
    case NULL = 0xFF
}

extension NEAIExtrapolationPhaseType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .IDLE:
            return "IDLE"
        case .EXTRAPOLATION:
            return "EXTRAPOLATION"
        case .BUSY:
            return "BUSY"
        case .NULL:
            return "NULL"
        }
    }
}


public enum NEAIExtrapolationStateType : UInt8, Codable{
    public typealias RawValue = UInt8
    /** ok */
    case OK = 0x0
    /** init not called */
    case INIT_NOT_CALLED = 0x7B
    /** board error */
    case BOARD_ERROR = 0x7C
    /** knowledge error */
    case KNOWLEDGE_ERROR = 0x7D
    /** not enough learning */
    case NOT_ENOUGH_LEARNING = 0x7E
    /** minimal learning done */
    case MINIMAL_LEARNING_DONE = 0x7F
    /** unknown error */
    case UNKNOWN_ERROR = 0x80
    /** null */
    case NULL = 0xFF
}


extension NEAIExtrapolationStateType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .OK:
            return "OK"
        case .INIT_NOT_CALLED:
            return "INIT NOT CALLED"
        case .BOARD_ERROR:
            return "BOARD ERROR"
        case .KNOWLEDGE_ERROR:
            return "KNOWLEDGE ERROR"
        case .NOT_ENOUGH_LEARNING:
            return "NOT ENOUGH LEARNING"
        case .MINIMAL_LEARNING_DONE:
            return "MINIMAL LEARNING DONE"
        case .UNKNOWN_ERROR:
            return "UNKNOWN ERROR"
        case .NULL:
            return "NULL"
        }
    }
}


// MARK: - NEAIExtrapolation
public struct NEAIExtrapolation: Codable {
    public let phase: NEAIExtrapolationPhaseType
    public let state: NEAIExtrapolationStateType?
    public let target: Float?
    public let unit: String?
    public let stub: Bool?
    
    enum CodingKeys: String, CodingKey {
        case phase = "phase"
        case state = "state"
        case target = "target"
        case unit = "unit"
        case stub = "stub"
    }
    
    public init(phase: NEAIExtrapolationPhaseType, state: NEAIExtrapolationStateType, target: Float, unit: String?,stub: Bool?) {
        self.phase = phase
        self.state = state
        self.target = target
        self.unit = unit
        self.stub = stub
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        phase = try container.decode(NEAIExtrapolationPhaseType.self, forKey: .phase)
        state = try container.decodeIfPresent(NEAIExtrapolationStateType.self, forKey: .state)
        target = try container.decodeIfPresent(Float.self, forKey: .target)
        unit = try container.decodeIfPresent(String.self, forKey: .unit)
        stub = try container.decodeIfPresent(Bool.self, forKey: .stub) ?? true
    }
}


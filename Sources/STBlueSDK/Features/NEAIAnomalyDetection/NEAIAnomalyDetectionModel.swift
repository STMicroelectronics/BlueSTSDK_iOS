//
//  NEAIAnomalyDetection+Model.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum PhaseType : UInt8{
    public typealias RawValue = UInt8
    /** idle */
    case IDLE = 0x0
    /** learning */
    case LEARNING = 0x01
    /** detection */
    case DETECTION = 0x02
    /** detection */
    case IDLE_TRAINED = 0x03
    /** busy */
    case BUSY = 0x04
    /** null */
    case NULL = 0xFF
}

public enum StateType : UInt8{
    public typealias RawValue = UInt8
    /** ok */
    case OK = 0x0
    /** initFctNotCalled */
    case INIT_NOT_CALLED = 0x7B
    /** boardError */
    case BOARD_ERROR = 0x7C
    /** knowledgeBufferError */
    case KNOWLEDGE_ERROR = 0x7D
    /** notEnoughCallToLearning */
    case NOT_ENOUGH_LEARNING = 0x7E
    /** notEnoughCallToLearning */
    case MINIMAL_LEARNING_DONE = 0x7F
    /** unknownError */
    case UNKOWN_ERROR = 0x80
    /** null */
    case NULL = 0xFF
}

public enum StatusType : UInt8{
    public typealias RawValue = UInt8
    /** normal */
    case NORMAL = 0x0
    /** anomaly */
    case ANOMALY = 0x01
    /** null */
    case NULL = 0xFF
}

extension PhaseType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .IDLE:
            return "IDLE"
        case .LEARNING:
            return "LEARNING"
        case .DETECTION:
            return "DETECTION"
        case .IDLE_TRAINED:
            return "IDLE TRAINED"
        case .BUSY:
            return "BUSY"
        case .NULL:
            return "NULL"
        }
    }
}

extension StateType: CustomStringConvertible {
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
        case .UNKOWN_ERROR:
            return "UNKOWN ERROR"
        case .NULL:
            return "NULL"
        }
    }
}

extension StatusType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .NORMAL:
            return "NORMAL"
        case .ANOMALY:
            return "ANOMALY"
        case .NULL:
            return "NULL"
        }
    }
}

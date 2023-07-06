//
//  NEAIClassificationModel.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum NEAIClassPhaseType : UInt8{
    public typealias RawValue = UInt8
    /** idle */
    case IDLE = 0x0
    /** classification */
    case CLASSIFICATION = 0x01
    /** busy */
    case BUSY = 0x02
    /** null */
    case NULL = 0xFF
}

public enum NEAIClassModeType : UInt8{
    public typealias RawValue = UInt8
    /** 1 class */
    case ONE_CLASS = 0x01
    /** n class */
    case N_CLASS = 0x02
    /** null */
    case NULL = 0xFF
}

public enum NEAIClassStateType : UInt8{
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

extension NEAIClassPhaseType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .IDLE:
            return "IDLE"
        case .CLASSIFICATION:
            return "CLASSIFICATION"
        case .BUSY:
            return "BUSY"
        case .NULL:
            return "NULL"
        }
    }
}

extension NEAIClassModeType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .ONE_CLASS:
            return "ONE_CLASS"
        case .N_CLASS:
            return "N CLASS"
        case .NULL:
            return "NULL"
        }
    }
}

extension NEAIClassStateType: CustomStringConvertible {
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

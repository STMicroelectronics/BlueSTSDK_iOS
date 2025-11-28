//
//  RoboticsActionCode.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//



import Foundation

// Action code is made up of Action Bits , Interval and error codes if(4 MSB bits are high)
// Enums for action bits, error codes, and intervals

// Enum for action bits (high 4 bits)
public enum RoboticsActionBits: Equatable {
    case write               // Bit 4
    case read                // Bit 5
    case periodicRead(Interval) // Bit 6 with associated interval
    case ackFlag             // Bit 7
    case error(ErrorCode)    // Error with associated value (ErrorCode)
    
    // Nested enum for error codes (low 4 bits)
    public enum ErrorCode: UInt8 {
        case generalError = 0x0
        case commandNotSupported = 0x1
        case commandNotExpected = 0x2
        case commandNotAllowed = 0x3
        case paramsNotCorrect = 0x4
        case paramsOutOfRange = 0x5
        case internalError = 0x6
        case subSystemError = 0x7
        case subSystemCommunicationFailed = 0x8
        case authenticationRequired = 0x9
        case rfuA = 0xA
        case rfuB = 0xB
        case rfuC = 0xC
        case unknownError = 0xF
    }
    
    // Enum representing intervals (low 4 bits)
    public enum Interval: UInt8 {
        case cancelPeriodicRead = 0x0
        case ms100 = 0x1
        case ms200 = 0x2
        case ms500 = 0x3
        case s1 = 0x4
        case s2 = 0x5
        case s5 = 0x6
        case s10 = 0x7
        case s20 = 0x8
        case m1 = 0x9
        case m2 = 0xA
        case m5 = 0xB
        case m10 = 0xC
        case m20 = 0xD
        case hr1 = 0xE
        case doNotChange = 0xF
    }
}

//MARK: Pack Action Data
extension RoboticsActionBits {
    // Single function to combine actions and handle periodicRead with interval and error with error code
    public static func packActions(_ actions: [RoboticsActionBits]) -> Data {
        var actionByte: UInt8 = 0
        var extraPackData: UInt8 = 0
        for action in actions {
            switch action {
            case .write:
                actionByte |= 0b00010000   // Bit 4 for write
            case .read:
                actionByte |= 0b00100000   // Bit 5 for read
            case .ackFlag:
                actionByte |= 0b10000000   // Bit 7 for ackFlag
            case .periodicRead(let intervalValue):
                // Set the periodicRead bit and capture the interval
                actionByte |= 0b01000000   // Bit 6 for periodicRead
                extraPackData = intervalValue.rawValue // packing interval
            case .error(let errorCode):
                // Errors are handled separately, ignore here
                let packedByte: UInt8 = 0b11110000
                extraPackData = errorCode.rawValue // packing error

                break
            }
        }
        
        // Combine the action bits in the high 4 bits and in the low 4 bits either we will have the interval or error code
        let packedByte: UInt8 = (actionByte & 0xF0) | (extraPackData & 0x0F)
        
        // Return packed data
        return Data([packedByte])
    }


}

//MARK: Read Action Data
extension RoboticsActionBits {
    // Function to evaluate action code from a given byte
    static func evaluateActionCode(from byte: UInt8) -> [RoboticsActionBits]? {
        let highBits = byte & 0xF0  // Extract high 4 bits (bits 4-7)
        let lowBits = byte & 0x0F   // Extract low 4 bits (bits 0-3)

        var actionDescription = ""
        var actionReceived = [RoboticsActionBits]()

        // Check the high bits for action type
        if highBits == 0b11110000 {
            // It's an error code
            if let errorCode = RoboticsActionBits.ErrorCode(rawValue: lowBits) {
                actionDescription = "Error: \(errorCode)"
                actionReceived.append(.error(errorCode))
            } else {
                actionDescription = "Unknown Error"
                actionReceived.append(.error(.unknownError))

            }
        } else {
            // Check for normal actions
            if highBits & 0b10000000 != 0 {
                actionDescription += "Ack Flag, "
                actionReceived.append(.ackFlag)

            }
            if highBits & 0b01000000 != 0 {
                // It's a periodic read, include the interval
                if let interval = Interval(rawValue: lowBits) {
                    actionDescription += "Periodic Read with interval \(interval), "
                    actionReceived.append(.periodicRead(interval))

                } else {
                    actionDescription += "Periodic Read with unknown interval, "
                }
            }
            if highBits & 0b00100000 != 0 {
                actionDescription += "Read, "
                actionReceived.append(.read)

            }
            if highBits & 0b00010000 != 0 {
                actionDescription += "Write, "
                actionReceived.append(.write)

            }

            // Remove the trailing comma and space if present
            if actionDescription.hasSuffix(", ") {
                actionDescription.removeLast(2)
            }
        }

        return actionReceived.isEmpty ? nil: actionReceived
    }
}


// Extend Array to add a method for packing RoboticsActionBits
extension Array where Element == RoboticsActionBits {
    var packedData: Data {
        return RoboticsActionBits.packActions(self)
    }
}



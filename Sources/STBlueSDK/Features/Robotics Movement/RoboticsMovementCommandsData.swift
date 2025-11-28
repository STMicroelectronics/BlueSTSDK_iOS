//
//  RoboticsMovementCommandsData.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation


// MARK:  ############################################# PWM Movement Command ############################################# 
public struct PWMMovementCommand {
    public var action: [RoboticsActionBits]
    public var leftMode: UInt8
    public var leftWheel: Int16
    public var rightMode: UInt8
    public var rightWheel: Int16
    public var res: [UInt8] // Reserved, 8 bytes
    
    public init(action: [RoboticsActionBits], leftMode: UInt8 = 0, leftWheel: Int16, rightMode: UInt8 = 0, rightWheel: Int16, res: [UInt8] = []) {
        self.action = action
        self.leftMode = leftMode
        self.leftWheel = leftWheel
        self.rightMode = rightMode
        self.rightWheel = rightWheel
        self.res = res
    }
    
    public func toData() -> Data {
        var data = Data()
        data.append(action.packedData)
        data.append(leftMode)
        data.append(contentsOf: withUnsafeBytes(of: leftWheel.bigEndian, Array.init))
        data.append(rightMode)
        data.append(contentsOf: withUnsafeBytes(of: rightWheel.bigEndian, Array.init))
        if !res.isEmpty {
            data.append(contentsOf: res)
        }
        return data
    }
}

extension PWMMovementCommand: CustomStringConvertible {
    public var description: String {
        let statusDescriptions = [
            "Action: \(action)",
            "Left Mode: \(leftMode)",
            "Left Wheel: \(leftWheel)",
            "Right Mode: \(rightMode)",
            "Right Wheel: \(rightWheel)",
            "Reserved: \(res)"
        ]
        return statusDescriptions.joined(separator: ", ")
    }
}

extension PWMMovementCommand: Loggable {
    public var logHeader: String {
        return "Action, Left Mode, Left Wheel, Right Mode, Right Wheel, Reserved"
    }
    
    public var logValue: String {
        return "\(action), \(leftMode), \(leftWheel), \(rightMode), \(rightWheel), \(res)"
    }
}



// MARK: ###################################### Simple Movement Command #############################################
public struct SimpleMovementCommand {
    public var action: [RoboticsActionBits]
    public var direction: RobotDirection
    public var speed: UInt8
    public var angle: UInt8
    public var res: [UInt8] // Reserved, 10 bytes
    
    public static func == (lhs: SimpleMovementCommand, rhs: SimpleMovementCommand) -> Bool {
        return lhs.action == rhs.action &&
               lhs.direction == rhs.direction &&
               lhs.speed == rhs.speed &&
               lhs.angle == rhs.angle
    }
    
    public enum RobotDirection: UInt8 {
        case forward = 70  // 'F'
        case backward = 66 // 'B'
        case left = 76     // 'L'
        case right = 82    // 'R'
        case stop = 83    // 'S'

        
        public init?(rawValue: UInt8) {
            switch rawValue {
            case 70:
                self = .forward
            case 66:
                self = .backward
            case 76:
                self = .left
            case 82:
                self = .right
            default:
                return nil
            }
        }
        
        public var description: String {
            switch self {
            case .forward:
                return "Forward"
            case .backward:
                return "Backward"
            case .left:
                return "Left"
            case .right:
                return "Right"
            case .stop:
                return "Stop"

            }
        }
    }

    
    public init(action: [RoboticsActionBits], direction: RobotDirection, speed: UInt8, angle: UInt8, res: [UInt8] = []) {
        self.action = action
        self.direction = direction
        self.speed = speed
        self.angle = angle
        self.res = res
    }
    
    public func toData() -> Data {
        var data = Data()
        data.append(action.packedData)
        data.append(direction.rawValue)
        data.append(speed)
        data.append(angle)
        if !res.isEmpty {
            data.append(contentsOf: res)
        }
        return data
    }
}

extension SimpleMovementCommand: CustomStringConvertible {
    public var description: String {
        let statusDescriptions = [
            "Action: \(action)",
            "Direction: \(direction)",
            "Speed: \(speed)",
            "Angle: \(angle)",
            "Reserved: \(res)"
        ]
        return statusDescriptions.joined(separator: ", ")
    }
}

extension SimpleMovementCommand: Loggable {
    public var logHeader: String {
        return "Action, Direction, Speed, Angle, Reserved"
    }
    
    public var logValue: String {
        return "\(action), \(direction), \(speed), \(angle), \(res)"
    }
}


// MARK: ############################################# Set Navigation Command #############################################
public struct SetNavigationCommand {
    public var action: [RoboticsActionBits]?
    public var navigationMode: NavigationMode?
    public var armed: UInt8?
    public var res: [UInt8]?
    
    public enum ExpectedStatusType {
        case action
        case navigationMode
        case reserved
    }
    
    public static let expectedStatus: [ExpectedStatusType] = [.action, .navigationMode, .reserved]
    
    public init(action: [RoboticsActionBits] = [.write], navigationMode: NavigationMode, armed: UInt8, res: [UInt8]? = nil) {
        self.action = action
        self.navigationMode = navigationMode
        self.armed = armed
        self.res = res
    }
    
    public init?(data: Data) {
        guard data.count >= 2 else { return nil }
        
        var index = 0
        
        for field in SetNavigationCommand.expectedStatus {
            switch field {
            case .action:
                let actionData = data[index]
                self.action = RoboticsActionBits.evaluateActionCode(from: actionData)
                index += 1
                
            case .navigationMode:
                self.navigationMode = NavigationMode(rawValue: data[index])
                index += 1
                
            case .reserved:
                if data.count > index {
                    self.res = Array(data[index..<min(index + 10, data.count)])
                    index += 10
                } else {
                    self.res = nil
                }
            }
        }
    }
    
    public func toData() -> Data {
        var data = Data()
        
        if let action = self.action {
            data.append(action.packedData)
        }
        
        if let navigationMode = self.navigationMode {
            data.append(navigationMode.rawValue)
        }
        
        if let armed = self.armed {
            data.append(armed)
        }
        
        if let reserved = res {
            data.append(contentsOf: reserved)
        }
        
        return data
    }
}

extension SetNavigationCommand: CustomStringConvertible {
    public var description: String {
        let statusDescriptions = [
            "Action: \(String(describing: action))",
            "Navigation Mode: \(String(describing: navigationMode))",
            "Armed: \(String(describing: armed))",
            "Reserved: \(String(describing: res))"
        ]
        return statusDescriptions.joined(separator: ", ")
    }
}

extension SetNavigationCommand: Loggable {
    public var logHeader: String {
        return "Action, Navigation Mode, Armed, Reserved"
    }
    
    public var logValue: String {
        return "\(String(describing: action)), \(String(describing: navigationMode)), \(String(describing: armed)), \(String(describing: res))"
    }
}



// MARK: #############################################  Get Topology Command #############################################
public struct GetTopologyCommand {
    public var action: UInt8?
    public var topology: UInt32?
    
    public enum ExpectedStatusType {
        case action
        case topology
    }
    
    public static let expectedStatus: [ExpectedStatusType] = [.action, .topology]
    
    public init(action: UInt8) {
        self.action = action
        self.topology = nil
    }
    
    public init?(data: Data) {
        guard data.count >= 5 else { return nil }
        
        var index = 0
        
        for field in GetTopologyCommand.expectedStatus {
            switch field {
            case .action:
                self.action = data[index]
                index += 1
                
            case .topology:
                if data.count > index + 3 {
                    self.topology = UInt32(data[index]) |
                        (UInt32(data[index + 1]) << 8) |
                        (UInt32(data[index + 2]) << 16) |
                        (UInt32(data[index + 3]) << 24)
                    index += 4
                } else {
                    self.topology = nil
                }
            }
        }
    }
    
    public func toData() -> Data {
        var data = Data()
        
        if let action = self.action {
            data.append(action)
        }
        
        return data
    }
}

extension GetTopologyCommand: CustomStringConvertible {
    public var description: String {
        let statusDescriptions = [
            "Action: \(String(describing: action))",
            "Topology: \(String(describing: topology))"
        ]
        return statusDescriptions.joined(separator: ", ")
    }
}

extension GetTopologyCommand: Loggable {
    public var logHeader: String {
        return "Action, Topology"
    }
    
    public var logValue: String {
        return "\(String(describing: action)), \(String(describing: topology))"
    }
}

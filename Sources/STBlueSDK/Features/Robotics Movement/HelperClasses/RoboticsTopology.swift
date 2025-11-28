//
//  RoboticsTopology.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//


public enum TopologyBit: UInt32, CaseIterable {
    case remoteControlDifferential = 1          // 0b00000000000000000000000000000001
    case remoteControlSteering = 2              // 0b00000000000000000000000000000010
    case remoteControlMechanum = 4              // 0b00000000000000000000000000000100
    case remoteControlReserved = 8              // 0b00000000000000000000000000001000
    case odometry = 16                          // 0b00000000000000000000000000010000
    case imuAvailable = 32                       // 0b00000000000000000000000000100000
    case absoluteSpeedControl = 64               // 0b00000000000000000000000001000000
    case armSupport = 128                        // 0b00000000000000000000000100000000
    case attachmentSupport = 256                  // 0b00000000000000000000001000000000
    case autoDockingSupport = 512                // 0b00000000000000000000010000000000
    case wirelessChargingSupport = 1024          // 0b00000000000000000000100000000000
    case obstacleDetectionForward = 2048         // 0b00000000000000000001000000000000
    case obstacleDetectionMultidirectional = 4096 // 0b00000000000000000010000000000000
    case alarmHorn = 8192                        // 0b00000000000000000100000000000000
    case headlights = 16384                      // 0b00000000000000001000000000000000
    case warningLights = 32768                   // 0b00000000000000010000000000000000
    // B16-B31 are reserved for future use (RFU)
}

// Extension to provide descriptions for each bit
extension TopologyBit: CustomStringConvertible {
    public var description: String {
        switch self {
        case .remoteControlDifferential:
            return "Remote Control – Differential"
        case .remoteControlSteering:
            return "Remote Control – Steering"
        case .remoteControlMechanum:
            return "Remote Control – Mechanum"
        case .remoteControlReserved:
            return "Remote Control – Reserved"
        case .odometry:
            return "Odometry (Absolute Positions)"
        case .imuAvailable:
            return "IMU Available"
        case .absoluteSpeedControl:
            return "Absolute Speed Control"
        case .armSupport:
            return "Arm Support"
        case .attachmentSupport:
            return "Attachment Support"
        case .autoDockingSupport:
            return "Auto Docking Support"
        case .wirelessChargingSupport:
            return "Wireless Charging Support"
        case .obstacleDetectionForward:
            return "Obstacle Detection - Forward"
        case .obstacleDetectionMultidirectional:
            return "Obstacle Detection – Multidirectional"
        case .alarmHorn:
            return "Alarm / Horn"
        case .headlights:
            return "Headlights"
        case .warningLights:
            return "Warning Lights"
        }
    }
}


// Function to retrieve the string description of set bits in a UInt32 value
func retrieveTopologyDescriptions(from data: UInt32) -> [String] {
    var descriptions: [String] = []
    
    for bit in TopologyBit.allCases {
        if data & bit.rawValue != 0 {
            descriptions.append(bit.description)
        }
    }
    
    return descriptions
}

// Function to check if a specific bit is set in the provided data
func isBitSet(_ bit: TopologyBit, in data: UInt32) -> Bool {
    return data & bit.rawValue != 0
}

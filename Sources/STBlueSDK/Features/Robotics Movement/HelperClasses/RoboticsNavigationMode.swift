//
//  RoboticsNavigationMode.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum NavigationMode: UInt8 {
    case remoteControl = 0x01
    case freeNavigation = 0x02
    case followMe = 0x03
    case rfu = 0x04 // Default for the RFU range (can handle additional logic for others)

    // A custom initializer to handle the RFU range and ensure safety
    public init(rawValue: UInt8) {
        switch rawValue {
        case 0x01:
            self = .remoteControl
        case 0x02:
            self = .freeNavigation
        case 0x03:
            self = .followMe
        case 0x04...0xFF:
            self = .rfu
        default:
            fatalError("Invalid raw value \(rawValue)")
        }
    }

    // Custom description
    var description: String {
        switch self {
        case .remoteControl:
            return "Remote Control"
        case .freeNavigation:
            return "Free Navigation"
        case .followMe:
            return "Follow Me"
        case .rfu:
            return "Reserved for Future Use (RFU)"
        }
    }
}

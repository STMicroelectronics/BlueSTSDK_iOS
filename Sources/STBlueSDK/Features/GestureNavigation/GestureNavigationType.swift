//
//  GestureNavigationType.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum NavigationGestureType: UInt8 {
    case UNDEFINED = 0x00
    case SWIPE_LEFT_TO_RIGHT = 0x01
    case SWIPE_RIGHT_TO_LEFT = 0x02
    case SWIPE_UP_TO_DOWN = 0x03
    case SWIPE_DOWN_TO_UP = 0x04
    case SINGLE_PRESS = 0x05
    case DOUBLE_PRESS = 0x06
    case TRIPLE_PRESS = 0x07
    case LONG_PRESS = 0x08
    case ERROR = 0x09
}

public enum NavigationButtonType: UInt8 {
    case UNDEFINED = 0x00
    case LEFT = 0x01
    case RIGHT = 0x02
    case UP = 0x03
    case DOWN = 0x04
    case ERROR = 0x05
}

extension NavigationGestureType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .UNDEFINED:
            return "Undefined"
        case .SWIPE_LEFT_TO_RIGHT:
            return "Swipe Left to Right"
        case .SWIPE_RIGHT_TO_LEFT:
            return "Swipe Right to Left"
        case .SWIPE_UP_TO_DOWN:
            return "Swipe Up to Down"
        case .SWIPE_DOWN_TO_UP:
            return "Swipe Down to Up"
        case .SINGLE_PRESS:
            return "Single Press"
        case .DOUBLE_PRESS:
            return "Double Press"
        case .TRIPLE_PRESS:
            return "Triple Press"
        case .LONG_PRESS:
            return "Long Press"
        case .ERROR:
            return "Error"
        }
    }
}

extension NavigationButtonType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .UNDEFINED:
            return "Undefined"
        case .LEFT:
            return "Left"
        case .RIGHT:
            return "Right"
        case .UP:
            return "Up"
        case .DOWN:
            return "Down"
        case .ERROR:
            return "Error"
        }
    }
}

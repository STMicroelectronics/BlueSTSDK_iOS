//
//  ActivityType.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum ActivityType: UInt8 {
    /**
     *  we don't have enough data for select an activity
     */
    case noActivity = 0x00
    /**
     *  the person is standing
     */
    case standing = 0x01
    /**
     *  the person is walking
     */
    case walking = 0x02
    /**
     *  the person is fast walking
     */
    case fastWalking = 0x03
    /**
     *  the person is jogging
     */
    case jogging = 0x04
    /**
     *  the person is biking
     */
    case biking = 0x05
    /**
     *  the person is driving
     */
    case driving = 0x06
    /**
     * the person is doing the stairs
     */
    case stairs = 0x07
    /**
     * the adult is in the car
     */
    case adultInCar = 0x08
    /**
     *  unknown activity
     */
    case error = 0xFF
}

extension ActivityType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .noActivity:
            return "Unknown"
        case .standing:
            return "Standing"
        case .walking:
            return "Walking"
        case .fastWalking:
            return "Fast walking"
        case .jogging:
            return "Jogging"
        case .biking:
            return "Biking"
        case .driving:
            return "Driving"
        case .stairs:
            return "Stairs"
        case .adultInCar:
            return "Adult in Car"
        case .error:
            return "Unknown"
        }
    }
}

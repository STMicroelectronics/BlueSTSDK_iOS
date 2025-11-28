//
//  ShockAssetTrackingEvent.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

public struct ShockAssetTrackingEvent: Codable, Equatable, Hashable {
    public let durationMSec: Float
    public let intensityG: [Float]
    public let orientations: [AssetTrackingOrientationType]
    public let angles: [Float]

    static let UNDEF_ANGLE: Float = 180.0

    public static func == (lhs: ShockAssetTrackingEvent, rhs: ShockAssetTrackingEvent) -> Bool {
        return lhs.durationMSec == rhs.durationMSec &&
               lhs.intensityG == rhs.intensityG &&
               lhs.orientations == rhs.orientations &&
               lhs.angles == rhs.angles
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(durationMSec)
        hasher.combine(intensityG)
        hasher.combine(orientations)
        hasher.combine(angles)
    }
}

public enum AssetTrackingOrientationType: Int, Codable {
    case undef = 0x00
    case positive = 0x01
    case negative = 0x02

    public static func from(rawValue: UInt8) -> AssetTrackingOrientationType {
        switch rawValue {
        case 0x01:
            return .positive
        case 0x02:
            return .negative
        default:
            return .undef
        }
    }
}

//
//  AssetTrackingEventData.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct AssetTrackingEventInfo {
    public let type: AssetTrackingEventType
    public let fall: FallAssetTrackingEvent?
    public let shock: ShockAssetTrackingEvent?
    public let status: StatusAssetTrackingEvent?
}

public struct AssetTrackingEventData {
    
    public let event: FeatureField<AssetTrackingEventInfo>

    let NUMBER_BYTES_FALL = 5
    let NUMBER_BYTES_SHOCK = 1 + 4 * 4
    let NUMBER_BYTES_FULL_SHOCK = 1 + 4 * 4 + 3 * 1 + 3 * 4
    let NUMBER_BYTES_STATUS = 1 + 4 + 1
    
    init(with data: Data, offset: Int) {
        let code = UInt8(data.extractUInt8(fromOffset: offset))
        let type: AssetTrackingEventType = AssetTrackingEventType.from(rawValue: code)
        
        var fall: FallAssetTrackingEvent?
        var shock: ShockAssetTrackingEvent?
        var status: StatusAssetTrackingEvent?
        
        switch type {
        case .reset:
            fall = nil
            shock = nil
            
        case .fall:
            if (data.count - offset == 5) {
                let heightCm = data.extractFloat(fromOffset: offset + 1)
                fall = FallAssetTrackingEvent(heightCm: heightCm)
                shock = nil
            }
            
        case .shock:
            
            guard data.count - offset >= NUMBER_BYTES_SHOCK else {
                fatalError("We need \(NUMBER_BYTES_SHOCK) bytes available for Shock Event")
            }

            fall = nil

            let durationMSec = data.extractFloat(fromOffset: offset + 1)
            let intensityX = data.extractFloat(fromOffset: offset + 1 + 4)
            let intensityY = data.extractFloat(fromOffset: offset + 1 + 2 * 4)
            let intensityZ = data.extractFloat(fromOffset: offset + 1 + 3 * 4)

            if data.count - offset > NUMBER_BYTES_SHOCK {
                guard data.count - offset == NUMBER_BYTES_FULL_SHOCK else {
                    fatalError("We need \(NUMBER_BYTES_FULL_SHOCK) bytes available for Full Shock Event")
                }

                var code = data[offset + 1 + 4 * 4]
                let orientationX = AssetTrackingOrientationType.from(rawValue: code)

                code = data[offset + 1 + 4 * 4 + 1]
                let orientationY = AssetTrackingOrientationType.from(rawValue: code)

                code = data[offset + 1 + 4 * 4 + 2]
                let orientationZ = AssetTrackingOrientationType.from(rawValue: code)
                
                let angleX = data.extractFloat(fromOffset: offset + 1 + 4 * 4 + 3)
                let angleY = data.extractFloat(fromOffset: offset + 1 + 4 * 4 + 3 + 4)
                let angleZ = data.extractFloat(fromOffset: offset + 1 + 4 * 4 + 3 + 2 * 4)

                shock = ShockAssetTrackingEvent(
                    durationMSec: durationMSec,
                    intensityG: [intensityX, intensityY, intensityZ],
                    orientations: [orientationX, orientationY, orientationZ],
                    angles: [angleX, angleY, angleZ]
                )
            } else {
                shock = ShockAssetTrackingEvent(
                    durationMSec: durationMSec,
                    intensityG: [intensityX, intensityY, intensityZ],
                    orientations: [],
                    angles: []
                )
            }
            
        case .motion, .stationary:
            guard data.count - offset >= NUMBER_BYTES_STATUS else {
                fatalError("We need \(NUMBER_BYTES_STATUS) bytes available for Status Event")
            }
            
            let current = data.extractInt32(fromOffset: offset + 1)
                
            let rawPowerIndex = data.extractUInt8(fromOffset: offset + 1 + 4)
            let powerIndex = max(1, min(Int(rawPowerIndex), 10))
            
            status = StatusAssetTrackingEvent(current: Int(current), powerIndex: powerIndex)
            
        case .null:
            fall = nil
            shock = nil
            
        }
    
        self.event = FeatureField<AssetTrackingEventInfo>(name: "Asset Tracking Event",
                                                                 uom: nil,
                                                                 min: nil,
                                                                 max: nil,
                                                                 value: AssetTrackingEventInfo(type: type,
                                                                                               fall: fall,
                                                                                               shock: shock,
                                                                                               status: status))
    }
}

extension AssetTrackingEventData: CustomStringConvertible {
    public var description: String {
        let type = event.value?.type.description
        let fallHeightCm = event.value?.fall?.heightCm
        let shockDurationMs = event.value?.shock?.durationMSec
        let shockIntensityGX = event.value?.shock?.intensityG[0]
        let shockIntensityGY = event.value?.shock?.intensityG[1]
        let shockIntensityGZ = event.value?.shock?.intensityG[2]
        let current = event.value?.status?.current
        let powerIndex = event.value?.status?.powerIndex
        
        switch event.value?.type {
        case .reset:
            return String("\n--- RESET EVENT ---")
        case .fall:
            return String(format: "\n--- FALL EVENT ---\nType: %.2f\nHeightCm: %.2f\nDurationMsec: %.2f\nIntensityX: %.2f\nIntensityY: %.2f\nIntensityZ: %.2f", type ?? "✖", fallHeightCm ?? "✖", shockDurationMs ?? "✖", shockIntensityGX ?? "✖", shockIntensityGY ?? "✖", shockIntensityGZ ?? "✖")
        case .shock:
            return String(format: "\n--- SHOCK EVENT ---\nType: %.2f\nHeightCm: %.2f\nDurationMsec: %.2f\nIntensityX: %.2f\nIntensityY: %.2f\nIntensityZ: %.2f", type ?? "✖", fallHeightCm ?? "✖", shockDurationMs ?? "✖", shockIntensityGX ?? "✖", shockIntensityGY ?? "✖", shockIntensityGZ ?? "✖")
        case .motion, .stationary:
            return String(format: "\n--- STATUS EVENT ---\nType: %.2f\nCurrent: %.2f[µA]\nPowerIndex: %.2f\n", type ?? "✖", current ?? "✖", powerIndex ?? "✖")
        case .null:
            return String("\n--- NULL EVENT ---")
        default:
            return String(format: "\nType: %.2f\nHeightCm: %.2f\nDurationMsec: %.2f\nIntensityX: %.2f\nIntensityY: %.2f\nIntensityZ: %.2f", type ?? 0.0, fallHeightCm ?? 0.0, shockDurationMs ?? 0.0, shockIntensityGX ?? 0.0, shockIntensityGY ?? 0.0, shockIntensityGZ ?? 0.0)
        }
    }
}

extension AssetTrackingEventData: Loggable {
    public var logHeader: String {
        "\(event.logHeader)"
    }
    
    public var logValue: String {
        "\(event.logValue)"
    }
}

//
//  AccelerationEventData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

private enum AccelerationEventCommandPayload: UInt8 {
    case enable = 0x01
    case disable = 0x00
}

public enum AccelerationEventCommand: FeatureCommandType {
    case orientation(enabled: Bool)
    case multiple(enabled: Bool)
    case tilt(enabled: Bool)
    case freeFall(enabled: Bool)
    case singleTap(enabled: Bool)
    case doubleTap(enabled: Bool)
    case wakeUp(enabled: Bool)
    case pedometer(enabled: Bool)
    case none
    
    var value: UInt8 {
        switch self {
        case .orientation:
            return 0x61
        case .multiple:
            return 0x6D
        case .tilt:
            return 0x74
        case .freeFall:
            return 0x66
        case .singleTap:
            return 0x73
        case .doubleTap:
            return 0x64
        case .wakeUp:
            return 0x77
        case .pedometer:
            return 0x70
        case .none:
            return 0x00
        }
    }
    
    public var payload: Data? {
        switch self {
        case .orientation(let enabled),
                .multiple(let enabled),
                .tilt(let enabled),
                .freeFall(let enabled),
                .singleTap(let enabled),
                .doubleTap(let enabled),
                .wakeUp(let enabled),
                .pedometer(let enabled):
            return enabled ? Data([AccelerationEventCommandPayload.enable.rawValue]) :
            Data([AccelerationEventCommandPayload.disable.rawValue])
        case .none:
            return nil
        }
    }
    
    public var useMask: Bool {
        true
    }
    
    public func data(with nodeId: UInt8) -> Data {
        Data([value])
    }
}

private extension AccelerationEventCommand {
    func commandDescription(with text: String, enabled: Bool) -> String {
        //"\(enabled ? "Enable" : "Disable") \(text)"
        "\(text)"
    }
}

extension AccelerationEventCommand: CustomStringConvertible {
    public var description: String {
        switch self {
        case .orientation(let enabled):
            return commandDescription(with: "Orientation", enabled: enabled)
        case .multiple(let enabled):
            return commandDescription(with: "Multiple", enabled: enabled)
        case .tilt(let enabled):
            return commandDescription(with: "Tilt", enabled: enabled)
        case .freeFall(let enabled):
            return commandDescription(with: "Free Fall", enabled: enabled)
        case .singleTap(let enabled):
            return commandDescription(with: "Single Tap", enabled: enabled)
        case .doubleTap(let enabled):
            return commandDescription(with: "Double Tap", enabled: enabled)
        case .wakeUp(let enabled):
            return commandDescription(with: "Wake Up", enabled: enabled)
        case .pedometer(let enabled):
            return commandDescription(with: "Pedometer", enabled: enabled)
        case .none:
            return "None"
        }
    }
}

public enum AccelerationEventType: UInt16 {
    case orientationTopLeft = 0x04
    case orientationTopRight = 0x01
    case orientationBottomLeft = 0x03
    case orientationBottomRight = 0x02
    case orientationUp = 0x05
    case orientationDown = 0x06
    case tilt = 0x08
    case freeFall = 0x10
    case singleTap = 0x20
    case doubleTap = 0x40
    case wakeUp = 0x80
    case pedometer = 0x100
    case none = 0x00
}

extension AccelerationEventType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .orientationTopLeft:
            return "Orientation Top Left"
        case .orientationTopRight:
            return "Orientation Top Right"
        case .orientationBottomLeft:
            return "Orientation Bottom Left"
        case .orientationBottomRight:
            return "Orientation Bottom Right"
        case .orientationUp:
            return "Orientation Up"
        case .orientationDown:
            return "Orientation Down"
        case .tilt:
            return "Tilt"
        case .freeFall:
            return "Free Fall"
        case .singleTap:
            return "Single Tap"
        case .doubleTap:
            return "Double Tap"
        case .wakeUp:
            return "Wake Up"
        case .pedometer:
            return "Pedometer"
        case .none:
            return "No Event"
        }
    }
}

public struct AccelerationEventData {
    
    public private(set) var event: FeatureField<AccelerationEventType>
    public private(set) var steps: FeatureField<UInt16>
    
    init(eventAndPedometerWith data: Data, offset: Int) {
        
        let event = UInt16(data.extractUInt8(fromOffset: offset)) | AccelerationEventType.pedometer.rawValue
        let numberOfSteps = data.extractUInt16(fromOffset: offset + 1)
        
        self.event = FeatureField<AccelerationEventType>(name: "Event",
                                                         uom: nil,
                                                         min: AccelerationEventType.none,
                                                         max: AccelerationEventType.pedometer,
                                                         value: AccelerationEventType(rawValue: event))
        
        self.steps = FeatureField<UInt16>(name: "nSteps",
                                          uom: nil,
                                          min: 0,
                                          max: 2000,
                                          value: numberOfSteps)
    }
    
    init(pedometerWith data: Data, offset: Int) {
        
        let numberOfSteps = data.extractUInt16(fromOffset: offset)
        
        self.event = FeatureField<AccelerationEventType>(name: "Event",
                                                         uom: nil,
                                                         min: AccelerationEventType.none,
                                                         max: AccelerationEventType.pedometer,
                                                         value: AccelerationEventType.pedometer)
        
        self.steps = FeatureField<UInt16>(name: "nSteps",
                                          uom: nil,
                                          min: 0,
                                          max: UInt16.max,
                                          value: numberOfSteps)
    }
    
    init(eventWith data: Data, offset: Int) {
        
        let event = UInt16(data.extractUInt8(fromOffset: offset))
        
        self.event = FeatureField<AccelerationEventType>(name: "Event",
                                                         uom: nil,
                                                         min: AccelerationEventType.none,
                                                         max: AccelerationEventType.pedometer,
                                                         value: AccelerationEventType(rawValue: event))
        
        self.steps = FeatureField<UInt16>(name: "nSteps",
                                          uom: nil,
                                          min: 0,
                                          max: 2000,
                                          value: nil)
    }
}

extension AccelerationEventData: CustomStringConvertible {
    public var description: String {
        
        let event = event.value ?? .none
        let steps = steps.value ?? 0
        
        return "Event: \(event.description) - Steps: \(steps)"
    }
}

extension AccelerationEventData: Loggable {
    public var logHeader: String {
        "n/a"
    }
    
    public var logValue: String {
        "n/a"
    }
}

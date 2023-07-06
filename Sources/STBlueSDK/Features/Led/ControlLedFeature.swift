//
//  ControlLedFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum ControlLedCommand: UInt8, FeatureCommandType {
    case switchOffLed = 0x00
    case switchOnLed = 0x01
    case radioReboot = 0x02

    public var description: String {
        switch self {
        case .switchOffLed:
            return "Switch off led"
        case .switchOnLed:
            return "Switch on led"
        case .radioReboot:
            return "Radio reboot"
        }
    }
    
    public var useMask: Bool {
        false
    }
    
    public func data(with nodeId: UInt8) -> Data {
        
        var deviceId: UInt8 = 0x00
        
        switch nodeId {
        case 0x83:
            deviceId = 0x01
        case 0x84:
            deviceId = 0x02
        case 0x87:
            deviceId = 0x03
        case 0x88:
            deviceId = 0x04
        case 0x89:
            deviceId = 0x05
        case 0x8A:
            deviceId = 0x06
        default:
            deviceId = 0x00
        }
        
        var data = Data(capacity: 2)
        
        withUnsafeBytes(of: deviceId) { data.append(contentsOf: $0) }
        withUnsafeBytes(of: rawValue) { data.append(contentsOf: $0) }
        
        return data
    }
    
    public var payload: Data? {
        return nil
    }
}

public class ControlLedFeature: BaseFeature<Data>, CommandFeature {
    
    public var commands: [FeatureCommandType] = [
        ControlLedCommand.switchOnLed,
        ControlLedCommand.switchOffLed
    ]
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
    }

    public override func parse(commandResponse response: FeatureCommandResponse) ->
        FeatureCommandResponse {
            return response
    }
}

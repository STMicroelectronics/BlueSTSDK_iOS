//
//  RoboticsMovementFeature.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

// MARK: - Robot Movement Feature
//Robot Movement Feature Confirming to Robot Movement Status to received the data from the BLE
public class RoboticsMovementFeature: BaseFeature<RobotMovementStatusData> {
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
    
        guard let packet = RobotMovementStatusData(data: data, offset: offset) else {
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        }
        
        return (FeatureSample(with: timestamp, data: packet as? T, rawData: data), data.count)
    }

    public override func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse {
        response
    }

}


// MARK: - Robot Movement Receive Data
public struct RobotMovementStatusData {
    // command type and action type are common for any command response 
    public var commandType: RoboticsMovementType
    public var actionType: [RoboticsActionBits]
    public var leftData: Data?

    public init?(data: Data, offset: Int) {
        // Ensure the data contains at least commandType and actionType
        guard data.count >= 2 else { return nil }
        
        let firstData = data.extractUInt8(fromOffset: offset)
        self.commandType = RoboticsMovementType(rawValue: firstData)
        let secondData = data.extractUInt8(fromOffset: offset + 1)
        self.actionType =  (RoboticsActionBits.evaluateActionCode(from: secondData) != nil) ?  RoboticsActionBits.evaluateActionCode(from: secondData)! : [RoboticsActionBits.ackFlag] // if not evaluated as any then we will consider it only ack command
        self.leftData = data.count > 2 ? data[2...] : nil
    }

}

// MARK: - Loggable

extension RobotMovementStatusData : Loggable {
    public var logHeader: String {
        return "CommandType, ActionType, LeftData"
    }

    public var logValue: String {
        return "\(commandType), \(actionType), \(leftData ?? Data())"
    }
}

// MARK: - CustomStringConvertible
extension RobotMovementStatusData : CustomStringConvertible {
    public var description: String {
        return "Command Type: \(commandType), Action Type: \(actionType), Left Data: \(leftData ?? Data())"
    }
}

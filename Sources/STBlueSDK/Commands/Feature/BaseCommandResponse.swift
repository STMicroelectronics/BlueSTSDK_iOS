//
//  FeatureCommandResponse.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol FeatureCommandResponse: CustomStringConvertible {
    var timestamp: UInt16 { get }
    var featureMask: UInt32 { get }
    var commandType: UInt8 { get }
    var data: Data { get }
}

public class BaseCommandResponse: FeatureCommandResponse {

    public var timestamp: UInt16
    public var featureMask: UInt32
    public var commandType: UInt8
    public var data: Data

    init(timestamp: UInt16, featureMask: UInt32, commandType: UInt8, rawData: Data) {
        self.timestamp = timestamp
        self.featureMask = featureMask
        self.commandType = commandType
        self.data = rawData
    }

}

extension BaseCommandResponse: CustomStringConvertible {
    public var description: String {

        var featureString = "Unknown Feature"

        if let featureType = FeatureType.feature(from: featureMask) {
            featureString = String(describing: featureType.type)
        }

        return "\(featureString) - Message Response:\nTimestamp: \(timestamp)\nFeatureMask: \(featureMask)\nCommand Type: \(commandType)\nData: \(data.hex)"
    }
}

public extension BaseCommandResponse {

    static func parse(_ data: Data ) -> BaseCommandResponse? {
        if data.count < 7 {
            return nil
        }

        let timestamp = data.extractUInt16(fromOffset: 0)
        let featureMask = data.extractUInt32(fromOffset: 2, endian: .big)
        let commandType = data.extractUInt8(fromOffset: 6)

        let responseData = data.subdata(in: 7..<data.count)

        return BaseCommandResponse(timestamp: timestamp,
                                   featureMask: featureMask,
                                   commandType: commandType,
                                   rawData: responseData)
    }
}

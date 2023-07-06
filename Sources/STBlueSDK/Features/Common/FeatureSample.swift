//
//  FeatureSample.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol AnyFeatureSample: CustomStringConvertible {
}

public struct FeatureSample<T: Loggable>: AnyFeatureSample {

    public let notificationTime: Date
    public let timestamp: UInt64
    public let data: T?
    public let rawData: Data

    init(with timestamp: UInt64, data: T?, rawData: Data) {
        self.timestamp = timestamp
        self.data = data
        self.rawData = rawData
        self.notificationTime = Date()
    }

    init(with data: T?, rawData: Data) {
        self.notificationTime = Date()
        self.timestamp = UInt64(notificationTime.timeIntervalSince1970)
        self.data = data
        self.rawData = rawData
    }
}

extension FeatureSample: CustomStringConvertible {
    public var description: String {
        
        var descr = "ts: \(timestamp)\nraw data: \(rawData.hex)"
        
        if let data = data as? Data {
            descr += "\n\(data.hex)"
        } else if let data = data as? CustomStringConvertible {
            descr += "\n\(data.description)"
        } else {
            return "n/a"
        }
        
        return descr
    }
}

extension FeatureSample: Loggable {
    public var logHeader: String {
        "RawData,\(data?.logHeader ?? "n/a")"
    }

    public var logValue: String {
        "\(rawData.hex),\(data?.logValue ?? "n/a")"
    }

}

//
//  Feature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol Loggable {
    var logHeader: String { get }
    var logValue: String { get }
}

public protocol Feature: Loggable {

    var name: String { get }
    var simpleDescription: String { get }
    var isEnabled: Bool { get set }
    var isNotificationsEnabled: Bool { get set }
    var type: FeatureType { get }
    var notificationDate: Date? { get }
    var hasData: Bool { get }
    var lastSample: AnyFeatureSample? { get }

    func update(with timestamp: UInt64, data: Data, offset: Int, mtu: Int) -> Int

    func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse

    func description(with sample: AnyFeatureSample?) -> String
}

public protocol Initializable {
    init(name: String, type: FeatureType)
}

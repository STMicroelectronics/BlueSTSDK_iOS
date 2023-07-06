//
//  HumidityData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct HumidityData {

    public let humidity: FeatureField<Float>

    init(with data: Data, offset: Int) {
        
        let humidity = Float(data.extractUInt16(fromOffset: offset)) / 10.0

        self.humidity = FeatureField<Float>(name: "Humidity",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: humidity)
    }
}

extension HumidityData: Loggable {
    public var logHeader: String {
        "TBI"
    }

    public var logValue: String {
        "TBI"
    }
}

extension HumidityData: CustomStringConvertible {
    public var description: String {

        let humidity = humidity.value ?? .nan

        return String(format: "Humidity: %.2f", humidity)
    }
}

//
//  TemperatureData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct TemperatureData {
    
    public let temperature: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        let temperature = Float(data.extractUInt16(fromOffset: offset)) / 10.0
        
        self.temperature = FeatureField<Float>(name: "Temperature",
                                               uom: "\u{2103}",
                                               min: 0,
                                               max: 100,
                                               value: temperature)
    }
}

extension TemperatureData: CustomStringConvertible {
    public var description: String {
        
        let temperature = temperature.value ?? .nan
        
        return String(format: "Temperature: %.2f", temperature)
    }
}

extension TemperatureData: Loggable {
    public var logHeader: String {
        "\(temperature.logHeader)"
    }

    public var logValue: String {
        "\(temperature.logValue)"
    }
}

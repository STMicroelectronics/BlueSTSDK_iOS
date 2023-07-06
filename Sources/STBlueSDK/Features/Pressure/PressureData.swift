//
//  PressureData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PressureData {

    public let pressure: FeatureField<Float>

    init(with data: Data, offset: Int) {
        
        let pressure = Float(data.extractInt32(fromOffset: offset)) / 100.0

        self.pressure = FeatureField<Float>(name: "Pressure",
                                               uom: "mBar",
                                               min: 900,
                                               max: 1100,
                                               value: pressure)
    }
}

extension PressureData: CustomStringConvertible {
    public var description: String {

        let pressure = pressure.value ?? .nan

        return String(format: "Pressure: %.2f", pressure)
    }
}

extension PressureData: Loggable {
    public var logHeader: String {
        "\(pressure.logHeader)"
    }

    public var logValue: String {
        "\(pressure.logValue)"
    }
}

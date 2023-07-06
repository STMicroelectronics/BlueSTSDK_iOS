//
//  COSensorData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct COSensorData {
    
    public let coConcentration: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        let coConcentration = Float(data.extractUInt32(fromOffset: offset)) / 100.0
        
        self.coConcentration = FeatureField<Float>(name: "CO Concentration",
                                                   uom: nil,
                                                   min: 1000000,
                                                   max: 1,
                                                   value: coConcentration)
    }
    
}

extension COSensorData: CustomStringConvertible {
    public var description: String {
        
        let coConcentration = coConcentration.value ?? 1000000
        
        return String(format: "CO Concentration: %zd", coConcentration)
    }
}

extension COSensorData: Loggable {
    public var logHeader: String {
        "\(coConcentration.logHeader)"
    }
    
    public var logValue: String {
        "\(coConcentration.logValue)"
    }
    
}

//
//  LuminosityData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct LuminosityData {
    
    public let luminosity: FeatureField<UInt16>
    
    init(with data: Data, offset: Int) {
        
        let luminosity = data.extractUInt16(fromOffset: offset)
        
        self.luminosity = FeatureField<UInt16>(name: "Luminosity",
                                               uom: "Lux",
                                               min: 0,
                                               max: 1000,
                                               value: luminosity)
    }
    
}

extension LuminosityData: CustomStringConvertible {
    public var description: String {
        
        let luminosity = luminosity.value ?? 0
        
        return String(format: "Luminosity: %zd", luminosity)
    }
}

extension LuminosityData: Loggable {
    public var logHeader: String {
        "\(luminosity.logHeader)"
    }
    
    public var logValue: String {
        "\(luminosity.logValue)"
    }
    
}

//
//  ColorAmbientLightData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct ColorAmbientLightData {
    
    public let lux: FeatureField<UInt32>
    public let cct: FeatureField<UInt16>
    public let uvIndex: FeatureField<UInt16>
    
    init(with data: Data, offset: Int) {
        
        let lux = data.extractUInt32(fromOffset: offset)
        let cct = data.extractUInt16(fromOffset: offset + 4)
        let uvIndex = data.extractUInt16(fromOffset: offset + 6)
        
        self.lux = FeatureField<UInt32>(name: "Lux",
                                        uom: "Lux",
                                        min: 0,
                                        max: 400000,
                                        value: lux)
        
        self.cct = FeatureField<UInt16>(name: "Correlated Color Temperature",
                                        uom: "K",
                                        min: 0,
                                        max: 20000,
                                        value: cct)
        
        self.uvIndex = FeatureField<UInt16>(name: "UV Index",
                                        uom: "Lon",
                                        min: 0,
                                        max: 12,
                                        value: uvIndex)
    }
    
}

extension ColorAmbientLightData: CustomStringConvertible {
    public var description: String {
        
        let lux = lux.value ?? 0
        let cct = cct.value ?? 0
        let uvIndex = uvIndex.value ?? 0
        
        return String(format: "Lux: %zd\nCCT: %zd\nUv Index: %zd", lux, cct, uvIndex)
    }
}

extension ColorAmbientLightData: Loggable {
    public var logHeader: String {
        "\(lux.logHeader),\(cct.logHeader),\(uvIndex.logHeader)"
    }
    
    public var logValue: String {
        "\(lux.logValue),\(cct.logValue),\(uvIndex.logValue)"
    }
    
}

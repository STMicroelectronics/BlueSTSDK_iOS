//
//  MemsNormData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct MemsNormData {
    
    public let norm: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        let norm = Float(data.extractUInt16(fromOffset: offset))
        
        self.norm = FeatureField<Float>(name: "MemsNorm",
                                        uom: nil,
                                        min: 0,
                                        max: 2000,
                                        value: norm)
    }
    
}

extension MemsNormData: CustomStringConvertible {
    public var description: String {
        
        let norm = norm.value ?? 0
        
        return String(format: "MemsNorm: %zd", norm)
    }
}

extension MemsNormData: Loggable {
    public var logHeader: String {
        "\(norm.logHeader)"
    }
    
    public var logValue: String {
        "\(norm.logValue)"
    }
    
}

//
//  MagnetometerData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct MagnetometerData {
    
    public let magX: FeatureField<Float>
    public let magY: FeatureField<Float>
    public let magZ: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        let magX = Float(data.extractInt16(fromOffset: offset))
        let magY = Float(data.extractInt16(fromOffset: offset + 2))
        let magZ = Float(data.extractInt16(fromOffset: offset + 4))
        
        self.magX = FeatureField<Float>(name: "X",
                                        uom: "mGa",
                                        min: 2000,
                                        max: -2000,
                                        value: magX)
        
        self.magY = FeatureField<Float>(name: "Y",
                                        uom: "mGa",
                                        min: 2000,
                                        max: -2000,
                                        value: magY)
        
        self.magZ = FeatureField<Float>(name: "Z",
                                        uom: "mGa",
                                        min: 2000,
                                        max: -2000,
                                        value: magZ)
    }
    
}

extension MagnetometerData: CustomStringConvertible {
    public var description: String {
        
        let magX = magX.value ?? 0
        let magY = magY.value ?? 0
        let magZ = magZ.value ?? 0
        
        return String(format: "MagX: %.2f\nMagY: %.2f\nMagZ: %.2f", magX, magY, magZ)
    }
}

extension MagnetometerData: Loggable {
    public var logHeader: String {
        "\(magX.logHeader),\(magY.logHeader),\(magZ.logHeader)"
    }
    
    public var logValue: String {
        "\(magX.logValue),\(magY.logValue),\(magZ.logValue)"
    }
    
}

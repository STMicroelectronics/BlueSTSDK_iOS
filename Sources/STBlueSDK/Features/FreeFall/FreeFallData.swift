//
//  FreeFallData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct FreeFallData {
    
    public let freeFall: FeatureField<UInt8>
    
    init(with data: Data, offset: Int) {
        
        let counter = data.extractUInt8(fromOffset: offset)
        
        self.freeFall = FeatureField<UInt8>(name: "FreeFall",
                                            uom: nil,
                                            min: 0,
                                            max: 1,
                                            value: counter)
    }
    
}

extension FreeFallData: CustomStringConvertible {
    public var description: String {
        
        let freeFall = freeFall.value ?? 0
        
        return String(format: "FreeFall: %zd", freeFall)
    }
}

extension FreeFallData: Loggable {
    public var logHeader: String {
        "\(freeFall.logHeader)"
    }
    
    public var logValue: String {
        "\(freeFall.logValue)"
    }
    
}

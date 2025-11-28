//
//  RawPnPLControlledData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class RawPnPLControlledData {
    
    public let rawData: FeatureField<Data>
    
    init(with data: Data, offset: Int) {
        
        var rawD: Data = Data()
        
        for dataNum in 0..<(data.count - offset) {
            rawD.append(data[offset + dataNum])
        }
    
        
        self.rawData = FeatureField<Data>(name: "RawPnPLControlledData",
                                          uom: nil,
                                          min: nil,
                                          max: nil,
                                          value: rawD)
    }
}

extension RawPnPLControlledData: CustomStringConvertible {
    public var description: String {
        
        let rawData = rawData.value ?? Data()
        
        return "RawPnPLControlledData: \(rawData)"
    }
}

extension RawPnPLControlledData: Loggable {
    public var logHeader: String {
        "\(rawData.logHeader)"
    }
    
    public var logValue: String {
        "\(rawData.logValue)"
    }
    
}

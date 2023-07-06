//
//  SwitchData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct SwitchData {
    
    public let status: FeatureField<UInt8>
    
    init(with data: Data, offset: Int) {
        
        let status = data.extractUInt8(fromOffset: offset)
        
        self.status = FeatureField<UInt8>(name: "Status",
                                          uom: nil,
                                          min: 0,
                                          max: UInt8.max,
                                          value: status)
    }
}

extension SwitchData: CustomStringConvertible {
    public var description: String {
        
        let status = status.value ?? 0
        
        return String(format: "Status: \(status)")
    }
}

extension SwitchData: Loggable {
    public var logHeader: String {
        "\(status.logHeader)"
    }
    
    public var logValue: String {
        "\(status.logValue)"
    }
}

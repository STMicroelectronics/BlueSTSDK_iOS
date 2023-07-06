//
//  AILoggingData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct AILoggingData {
    
    public let status: FeatureField<AILoggingStatus>
    
    init(with data: Data, offset: Int) {
        
        let status = AILoggingStatus(rawValue: data.extractUInt8(fromOffset: offset))
        
        self.status = FeatureField<AILoggingStatus>(name: "Status",
                                       uom: nil,
                                       min: nil,
                                       max: nil,
                                       value: status)
    }
    
}

extension AILoggingData: CustomStringConvertible {
    public var description: String {
        
        let status = status.value ?? .unknown
        
        return String(format: "Status: %@", status.description)
    }
}

extension AILoggingData: Loggable {
    public var logHeader: String {
        "\(status.logHeader)"
    }
    
    public var logValue: String {
        "\(status.logValue)"
    }
    
}

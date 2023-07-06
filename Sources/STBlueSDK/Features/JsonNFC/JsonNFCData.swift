//
//  JsonNFCData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct JsonNFCData {
    
    public let response: FeatureField<JsonReadModes>
    
    init(response: JsonReadModes) {
        
        self.response = FeatureField<JsonReadModes>(name: "JsonNFC",
                                                    uom: nil,
                                                    min: nil,
                                                    max: nil,
                                                    value: response)
    }
}

extension JsonNFCData: CustomStringConvertible {
    public var description: String {
        
        if let response = response.value,
           let responseData = try? JSONEncoder().encode(response) {
            return String(data: responseData, encoding: .utf8) ?? "n/a"
        }
        
        return "n/a"
    }
}

extension JsonNFCData: Loggable {
    public var logHeader: String {
        "TBI"
    }
    
    public var logValue: String {
        "TBI"
    }
    
}

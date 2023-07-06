//
//  ExtendedConfigurationData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct ExtendedConfigurationData {

    public let response: FeatureField<ECResponse>

    init(response: ECResponse) {

        self.response = FeatureField<ECResponse>(name: "ExtConfig",
                                                 uom: nil,
                                                 min: nil,
                                                 max: nil,
                                                 value: response)
    }
}

extension ExtendedConfigurationData: CustomStringConvertible {
    public var description: String {

        if let response = response.value,
           let responseData = try? JSONEncoder().encode(response) {
            return String(data: responseData, encoding: .utf8) ?? "n/a"
        }
        
        return "n/a"
    }
}

extension ExtendedConfigurationData: Loggable {
    public var logHeader: String {
        "TBI"
    }

    public var logValue: String {
        "TBI"
    }
}

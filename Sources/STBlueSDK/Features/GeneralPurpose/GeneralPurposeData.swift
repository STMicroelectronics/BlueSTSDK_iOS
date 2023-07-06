//
//  GeneralPurposeData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct GeneralPurposeData {

    public let rawData: FeatureField<Data>

    init(data: Data) {

        self.rawData = FeatureField<Data>(name: "General purpose",
                                         uom: "RawData",
                                         min: nil,
                                         max: nil,
                                         value: data)
    }
}

extension GeneralPurposeData: CustomStringConvertible {
    public var description: String {
        let data = rawData.value ?? Data()
        return String(format: "RawData: \(data.hex)")
    }
}

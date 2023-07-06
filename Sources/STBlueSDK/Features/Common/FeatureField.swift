//
//  FeatureField.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct FeatureField<ValueType> {

    public let name: String
    public let uom: String?
    public let min: ValueType?
    public let max: ValueType?
    public let value: ValueType?

}

extension FeatureField: Loggable {

    public var logHeader: String {
        guard let uom = uom else {
            return (name)
        }

        return "\(name) (\(uom))"
    }

    public var logValue: String {
        guard let value = value else { return "n/a" }
        return "\(value)"
    }
}

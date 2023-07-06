//
//  PnPLikeConfigurationParameter.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PnPLikeConfigurationParameter {
    public let name: String?
    public let displayName: String?
    public let type: ParameterType?
    public var detail: ParameterDetail?
    public let unit: String?
    public let writable: Bool?
}

public struct ParameterDetail {
    public let requestName: String?
    public let primitiveType: String?
    public var currentValue: JSONValue?
    public let enumValues: [Int: String]?
    public var paramObj: [ObjectNameValue]?
}

public enum ParameterType {
    case propertyStandard
    case propertyEnumeration
    case propertyObject
    case commandEmpty
    case commandStandard
    case commandEnumeration
    case commandObject
}

public struct ObjectNameValue {
    public let primitiveType: String?
    public let name: String?
    public let displayName: String?
    public var currentValue: JSONValue?
}

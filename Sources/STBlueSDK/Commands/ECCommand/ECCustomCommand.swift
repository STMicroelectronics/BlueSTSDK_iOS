//
//  ECCustomCommand.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct ECCustomCommand: Codable {
    public enum ECCustomCommandType: String, Codable {
        case integer = "Integer"
        case string = "String"
        case bool = "Boolean"
        case enumString = "EnumString"
        case enumInteger = "EnumInteger"
        case void = "Void"
    }
    
    enum CodingKeys: String, CodingKey {
        case name = "Name"
        case type = "Type"
        case note = "Desc"
        case min = "Min"
        case max = "Max"
        case stringValues = "StringValues"
        case integerValues = "IntegerValues"
    }
    
    public let name: String
    public let type: ECCustomCommandType
    public let note: String?
    public var min: Int?
    public var max: Int?
    public var stringValues: [String]?
    public var integerValues: [Int]?
    
    public var minValue: Int {
        min ?? 0
    }
    
    public var maxValue: Int {
        max ?? 0
    }
    
    public var minValueDesc: String {
        NumberFormatter.localizedString(from: NSNumber(value: minValue), number: .none)
    }
    public var maxValueDesc: String {
        NumberFormatter.localizedString(from: NSNumber(value: maxValue), number: .none)
    }
    
    public var integerValuesFormatted: [String] {
        return integerValues?.map { NumberFormatter.localizedString(from: NSNumber(value: $0), number: .none) } ?? []
    }
    
    public func isValidString(_ value: String) -> Bool {
        guard type == .string else { return false }
        
        return value.count >= minValue && value.count <= maxValue
    }
    
    public func isValidInt(_ value: Int) -> Bool {
        guard type == .integer else { return false }
        
        return value >= minValue && value <= maxValue
    }
}

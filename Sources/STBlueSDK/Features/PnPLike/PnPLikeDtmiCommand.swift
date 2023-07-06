//
//  PnPLikeDtmiCommand.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore

public typealias PnPLikeDtmiElements = [PnPLikeElement]

// MARK: - PnPLikeElement
public struct PnPLikeElement: Codable {
    public let id: String
    public let type: String
    public let contents: [PnPLikeContent]
    public let displayName: DisplayName?
    public let context: [String]

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case context = "@context"
        case contents, displayName
    }
}

// MARK: - DisplayName
public struct DisplayName: Codable {
    public let en: String

    public enum CodingKeys: String, CodingKey {
        case en
    }
}

// MARK: - Request
public struct Request: Codable {
    public let type: String
    public let displayName: DisplayName?
    public let name: String
    public let schema: SchemaContent
    public let description: DisplayName?

    public enum CodingKeys: String, CodingKey {
        case type = "@type"
        case displayName, name, schema, description
    }
}

// MARK: - EnumResponseValue
public struct EnumResponseValue: Codable {
    public let displayName: DisplayName?
    public let enumValue: Int?
    public let name: String
    public let id: String?
    public let schema: String?
    public let type: String?

    public enum CodingKeys: String, CodingKey {
        case displayName, enumValue, name, schema
        case id = "@id"
        case type = "@type"
    }
}

// MARK: - PnPLikeContent
public struct PnPLikeContent: Codable {
    public let id: String?
    public let type: ContentType
    public let displayName: DisplayName?
    public let name: String
    public var schema: SchemaContent?
    public let unit: String?
    public let writable: Bool?
    public let displayUnit: DisplayName?
    public let commandType: String?
    public let request: Request?
    public let response: EnumResponseValue?
    public let contentDescription: DisplayName?
    public let comment: String?

    public enum CodingKeys: String, CodingKey {
        case id = "@id"
        case type = "@type"
        case contentDescription = "description"
        case displayName, name, schema, unit, writable, commandType, request, response, comment, displayUnit
    }
}

public extension PnPLikeContent {

    // MARK: - Function used to build complex PARAMETER (ex. object structure inside a Parameter Object)
    func buildParameterObject(paramType: ParameterType, boardSensorConfiguration: JSONValue?) -> [ObjectNameValue]? {
        /// Used for correct selection
        var currentParameterObject: [EnumResponseValue]? = []

        if paramType == .propertyObject {
            currentParameterObject = schema?.enumResponseValues
        } else {
            currentParameterObject = request?.schema.enumResponseValues
        }

        var paramsToAdd: [ObjectNameValue]? = []
        if currentParameterObject != nil {
            let boardParameterObjectConfiguration = boardSensorConfiguration?.extractObjectParam(keyValue: name)
            currentParameterObject?.forEach { param in
                paramsToAdd?.append(ObjectNameValue(primitiveType: param.schema,
                                                    name: param.name,
                                                    displayName: param.displayName?.en ?? "",
                                                    currentValue: boardParameterObjectConfiguration?.extractValueParam(keyValue: param.name)))
            }
            return paramsToAdd
        }
        return nil
    }

    // MARK: - Function used to build up Enum Values declared in DTMI
    func extractEnumValues(paramType: ParameterType) -> [Int: String]? {
        //let schema = extractSchemaObject(schema: sensor.schema)
        let schema = paramType == .propertyEnumeration ? schema?.object : request?.schema.object

        var tuples: [Int: String] = [:]
        schema?.enumValues?.forEach { enumValue in
            if enumValue.enumValue != nil,
               let key = enumValue.enumValue {
                tuples[key] = enumValue.displayName?.en ?? ""
            }
        }

        return tuples
    }

    func buildParameterType(with boardSensorConfiguration: JSONValue?) -> (type: ParameterType?, detail: ParameterDetail?) {
        var typeIsProperty = false
        var typeIsCommand = false

        let typeStr = type.string
        let typeStrArr = type.stringArray

        if typeStr != nil {
            if typeStr == "Property" {
                typeIsProperty = true
            }

            if typeStr == "Command" {
                typeIsCommand = true
            }
        }

        if typeStrArr != nil {
            typeStrArr?.forEach { str in
                if str == "Property" {
                    typeIsProperty = true
                }

                if str == "Command" {
                    typeIsCommand = true
                }
            }
        }

        if typeIsProperty {

            let schemaString = schema?.string
            let schemaObj = schema?.object

            if schemaString != nil { /// Build STANDARD Properety
                return buildParameterPropertyType(type: nil, boardSensorConfiguration: boardSensorConfiguration)
            }

            if schemaObj != nil { /// Build ENUM / OBJECT Properety
                return buildParameterPropertyType(type: schemaObj?.type, boardSensorConfiguration: boardSensorConfiguration)
            }

        } else if typeIsCommand {

            let schemaString = request?.schema.string
            let schemaObj = request?.schema.object

            if schemaString == nil && schemaObj == nil {
                return buildParameterCommandType(type: "Empty", boardSensorConfiguration: boardSensorConfiguration)
            }

            if schemaString != nil { /// Build STANDARD Command
                return buildParameterCommandType(type: nil, boardSensorConfiguration: boardSensorConfiguration)
            }

            if schemaObj != nil { /// Build ENUM / OBJECT Command
                return buildParameterCommandType(type: schemaObj?.type, boardSensorConfiguration: boardSensorConfiguration)
            }
        }

        return (nil, nil)
    }

    func buildParameterCommandType(type: String?, boardSensorConfiguration: JSONValue?) -> (type: ParameterType?, detail: ParameterDetail?) {
        switch type {
        case "Empty":
            return (type: .commandEmpty,
                    detail: ParameterDetail(requestName: nil,
                                            primitiveType: nil,
                                            enumValues: nil,
                                            paramObj: nil))

        case "Enum":
            return (type: .commandEnumeration,
                    detail: ParameterDetail(requestName: request?.name,
                                            primitiveType: schema?.string,
                                            currentValue: boardSensorConfiguration?.extractValueParam(keyValue: name),
                                            enumValues: extractEnumValues(paramType: .commandEnumeration),
                                            paramObj: nil))

        case "Object":
            return (type: .commandObject,
                    detail: ParameterDetail(requestName: request?.name,
                                            primitiveType: schema?.string,
                                            currentValue: nil,
                                            enumValues: nil,
                                            paramObj: buildParameterObject(paramType: .commandObject,
                                                                           boardSensorConfiguration: boardSensorConfiguration)))

        default:
            return (type: .commandStandard,
                    detail: ParameterDetail(requestName: request?.name,
                                            primitiveType: schema?.string,
                                            currentValue: boardSensorConfiguration?.extractValueParam(keyValue: name),
                                            enumValues: nil,
                                            paramObj: nil))
        }
    }

    func buildParameterPropertyType( type: String?, boardSensorConfiguration: JSONValue?) -> (type: ParameterType?, detail: ParameterDetail?) {
        switch type {

        case "Enum":
            return (type: .propertyEnumeration,
                    detail: ParameterDetail(requestName: nil,
                                            primitiveType: schema?.string,
                                            currentValue: boardSensorConfiguration?.extractValueParam(keyValue: name),
                                            enumValues: extractEnumValues(paramType: .propertyEnumeration),
                                            paramObj: nil))

        case "Object":
            return (type: .propertyObject,
                    detail: ParameterDetail(requestName: nil,
                                            primitiveType: schema?.string,
                                            currentValue: nil,
                                            enumValues: nil,
                                            paramObj: buildParameterObject(paramType: .propertyObject,
                                                                           boardSensorConfiguration: boardSensorConfiguration)))
        default:
            return (type: .propertyStandard,
                    detail: ParameterDetail(requestName: nil,
                                            primitiveType: schema?.string,
                                            currentValue: boardSensorConfiguration?.extractValueParam(keyValue: name),
                                            enumValues: nil,
                                            paramObj: nil))
        }
    }
}

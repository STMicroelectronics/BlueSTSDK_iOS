//
//  JSONValue.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum JSONValue: Codable {
    case string(String)
    case int(Int)
    case double(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self = try ((try? container.decode(String.self)).map(JSONValue.string))
            .or((try? container.decode(Int.self)).map(JSONValue.int))
            .or((try? container.decode(Double.self)).map(JSONValue.double))
            .or((try? container.decode(Bool.self)).map(JSONValue.bool))
            .or((try? container.decode([String: JSONValue].self)).map(JSONValue.object))
            .or((try? container.decode([JSONValue].self)).map(JSONValue.array))
            .resolve(with: DecodingError.typeMismatch(JSONValue.self,
                                                      DecodingError.Context(codingPath: container.codingPath,
                                                                            debugDescription: "Not a JSON")))
    }
}

public extension JSONValue {

    func value(for deviceId: Int, firmwareId: Int, key: String?) -> JSONValue? {

        if case let .array(devices) = searchKey(keyValue: "devices") {

            for device in devices {
                if case let .int(devId) = device.searchKey(keyValue: "board_id"),
                   case let .int(fwId) = device.searchKey(keyValue: "fw_id") {

                    if devId == deviceId, fwId == firmwareId {
                        return device.searchKey(keyValue: key)
                    } else {
                        continue
                    }
                }
            }
        }

        return nil
    }

    func searchKey(keyValue: String?) -> JSONValue? {
        if keyValue != nil {
            switch self {
                
            case .object(let dict):
                for key in dict.keys {
                    if keyValue == key {
                        return dict[key]
                    } else {
                        return dict[key]?.searchKey(keyValue: key)
                    }
                }
                
            case .array(let arr):
                for item in arr {
                    if let foundObj = item.searchKey(keyValue: keyValue) {
                        return foundObj
                    }
                }
                return nil
                
            default:
                return nil
            }
        }
        
        return nil
    }
    
//    /// Function used to search to extract actual value for a specific parameter present in JSON Board
    func extractValueParam(keyValue: String?) -> JSONValue? {
        extractObjectParam(keyValue: keyValue)
    }
//        if keyValue != nil {
//
//            switch self {
//
//            case .object(let dict):
//                for key in dict.keys {
//                    if keyValue == key {
//                        return dict[key]?.value
//                    }
//                }
//
//            default:
//                return nil
//            }
//
//        }
//
//        return nil
//    }
    
    func extractObjectParam(keyValue: String?) -> JSONValue? {
        if keyValue != nil {
            switch self {
            case .object(let dict):
                for key in dict.keys {
                    if keyValue == key {
                        return dict[key]
                    }
                }
            default:
                return nil
            }
        }
        return nil
    }
}

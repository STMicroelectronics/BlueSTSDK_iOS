//
//  PnpLCommand.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum PnpLCommandValue {
    case plain(value: Encodable)
    case object(name: String, value: AnyEncodable)
    case objects(name: String, values: [AnyEncodable])
}

public enum PnpLCommandElement {
    case plain(name: String)
    case param(name: String, param: String)
}

public extension PnpLCommandValue {
    var value: AnyEncodable {
        switch self {
        case .plain(let value):
            return AnyEncodable(value)
        case .object(let name, let value):
            return AnyEncodable([ name: value ])
        case .objects(let name, let values):
            return AnyEncodable([ name: values ])
        }
    }
}

public enum PnpLCommand {
    case status
    case simpleJson(element: String, value: PnpLCommandValue)
    case json(element: String, param: String, value: PnpLCommandValue)
    case command(element: String, param: String, value: PnpLCommandValue)
    case emptyCommand(element: String, param: String)
}

private extension PnpLCommand {

    var code: String {
        switch self {
        case .status:
            return "get_status"
        case .json(let element, _, _),
                .simpleJson(let element, _):
            return "\(element)"
        case .command(let element, let param, _),
                .emptyCommand(let element, let param):
            return "\(element)*\(param)"
        }
    }

    var value: Encodable {
        switch self {
        case .status:
            return [ code: "all"]
        case .simpleJson(_, let value):
            return [ code: value.value ]
        case .json(_, let param, let value):
            return [ code: [ param: value.value] ]
        case .command(_, _, let value):
            return [ code: value.value ]
        case .emptyCommand:
            return [ code: AnyEncodable([String:String]())]

        }
    }
}

extension PnpLCommand: JsonCommand {
    public var json: String? {
        guard let data = try? JSONEncoder().encode(value) else { return nil }
        return String(data: data, encoding: .utf8)
    }
}

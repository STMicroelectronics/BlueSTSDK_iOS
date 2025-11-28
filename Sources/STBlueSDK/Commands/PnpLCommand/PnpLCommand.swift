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
    case anyPlain(value: AnyEncodable)
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
        case .anyPlain(value: let value):
            return AnyEncodable(value)
        case .plain(let value):
            return AnyEncodable(value)
        case .object(let name, let value):
            return AnyEncodable([ name: value ])
        case .objects(let name, let values):
            return AnyEncodable([ name: values ])
        }
    }
}

public extension PnpLCommand {
    static var logControllerStatus: PnpLCommand {
        PnpLCommand.simpleJson(element: "get_status",
                               value: .plain(value: "log_controller"))
    }
}

public enum PnpLCommand {
    case status
    case elementStatus(element: String)
    case setTime(date: Date)
    case setName(name: String)
    case startLog
    case stopLog
    case enableAllSensors(enable: Bool)

    case simpleJson(element: String, value: PnpLCommandValue)
    case json(element: String, param: String, value: PnpLCommandValue)
    case command(element: String, param: String, value: PnpLCommandValue)
    case commandWithRequest(element: String, param: String, request: String, value: PnpLCommandValue)
    case emptyCommand(element: String, param: String)
}

private extension PnpLCommand {

    var code: String {
        switch self {
        case .status, .elementStatus:
            return "get_status"
        case .setTime(_):
            return "log_controller*set_time"
        case .setName(_):
            return "acquisition_info"
        case .startLog:
            return "log_controller*start_log"
        case .stopLog:
            return "log_controller*stop_log"
        case .enableAllSensors:
            return "log_controller*enable_all"
        case .json(let element, _, _),
                .simpleJson(let element, _):
            return "\(element)"
        case .command(let element, let param, _),
                .emptyCommand(let element, let param),
                .commandWithRequest(let element, let param, _, _):
            return "\(element)*\(param)"
        }
    }

    var value: Encodable {
        switch self {
        case .status:
            return [ code: "all"]
        case .elementStatus(let element):
            return [ code: element]
        case .setTime(let date):
            let formatter = DateFormatter()
            formatter.dateFormat = "yyyyMMdd_HH_mm_ss"
            return [ code: [ "datetime": formatter.string(from: date)]]
        case .setName(let name):
            return [ code: [ "name": name] ]
        case .startLog:
            return [ code: ["interface": 0] ]
        case .enableAllSensors(let enable):
            return [ code: ["status": enable] ]
        case .stopLog:
            return [ code: [String: String]() ]
        case .simpleJson(_, let value):
            return [ code: value.value ]
        case .json(_, let param, let value):
            return [ code: [ param: value.value] ]
        case .command(_, _, let value):
            return [ code: value.value ]
        case .commandWithRequest(_, _, let request, let value):
            return [ code: [request : value.value] ]
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

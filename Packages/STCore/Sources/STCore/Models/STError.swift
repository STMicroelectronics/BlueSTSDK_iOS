//
//  STError.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum STError: Error {
    case unknown
    case urlNotValid
    case dataNotValid
    case server(error: Error)
    case generic(text: String)
    case raw(data: Data)
    case notAuthorized

    public var localizedDescription: String {
        switch self {
        case .unknown:
            return "unknown"
        case .urlNotValid:
            return "urlNotValid"
        case .dataNotValid:
            return "dataNotValid"
        case .server(let error):
            return error.localizedDescription
        case .generic(let text):
            return text
        case .raw(let data):
            return "raw data: \(data)"
        case .notAuthorized:
            return "notAuthorized"
        }
    }
}

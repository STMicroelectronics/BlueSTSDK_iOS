//
//  Localizable.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol Localizable {
    var localizedKey: String { get }
}

public extension RawRepresentable where RawValue == String, Self: Localizable {

//    var localized: String {
//        localized(in: nil)
//    }

    func localized(in bundle: Bundle? = nil) -> String {
        NSLocalizedString(rawValue, bundle: bundle ?? .main, comment: "")
    }

    func localized(with arguments: [ CVarArg ]? = nil, in bundle: Bundle? = nil) -> String {
        var localizedString = NSLocalizedString(rawValue, bundle: bundle ?? .main, comment: "")

        if let arguments = arguments, arguments.count > 0 {
            localizedString = String(format: localizedString, arguments: arguments)
        }

        return localizedString
    }
}


public extension String {
    func localized(in bundle: Bundle? = nil) -> String {
        NSLocalizedString(self, bundle: bundle ?? .main, comment: "")
    }

    func localized(with arguments: [ CVarArg ]? = nil, in bundle: Bundle? = nil) -> String {
        var localizedString = NSLocalizedString(self, bundle: bundle ?? .main, comment: "")

        if let arguments = arguments, arguments.count > 0 {
            localizedString = String(format: localizedString, arguments: arguments)
        }

        return localizedString
    }

    var localized: String {
        localized(in: nil)
    }
}

//
//  Permission.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum Permission: String, CaseIterable {
    case autoUpdateFirmware
    case downlodFirmware
    case offlineUpdateFirmware
    case firmwareSwap
//    case exploreCatalog
    case debugConsole
    case addCustomFwDbEntry
    case addCustomDTDLEntry

    public var isAuthenticationRequired: Bool {

        guard let loginService: LoginService = Resolver.shared.resolve() else { return true }

        switch self {
        case .autoUpdateFirmware,
                .downlodFirmware,
                .offlineUpdateFirmware,
                .firmwareSwap:
            return !loginService.isAuthenticated
        case .addCustomFwDbEntry, //.exploreCatalog,
                .addCustomDTDLEntry,
                .debugConsole:
            return false
        }
    }

    public var appModesEnabled: [AppMode] {
        switch self {
        case .autoUpdateFirmware,
                .downlodFirmware,
                .offlineUpdateFirmware,
                .firmwareSwap,
                .addCustomFwDbEntry,
                .addCustomDTDLEntry,
                .debugConsole:
            return [ .expert ]
//        case .exploreCatalog:
//            return [ .expert, .beginner]
        }
    }

    public var userTypesEnabled: [UserType] {
        switch self {
        case .autoUpdateFirmware,
                .downlodFirmware,
                .offlineUpdateFirmware,
                .firmwareSwap,
                .addCustomFwDbEntry,
                .addCustomDTDLEntry,
                .debugConsole:
            return [ .developer ]
//        case .exploreCatalog:
//            return [ .studentOrResearcher, .engineerOrSale ]
        }
    }
}

//
//  SessionService.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol NetworkSession {
    var username: String? { get }
    var password: String? { get }
    var accessToken: String? { get }
    var refreshToken: String? { get }
    var auth: Auth? { get set }
}

public protocol SessionService {
    var isWelcomeNeeded: Bool { get }
    var permissions: [Permission] { get }
    var app: App? { get }
    func update(appMode: AppMode, userType: UserType)
    func reset()
}

public class SessionServiceCore: SessionService, NetworkSession {

    public var username: String?

    public var password: String?

    public var accessToken: String? {
        return auth?.accessToken
    }

    public var refreshToken: String? {
        return auth?.refreshToken
    }

    @JsonUserDefault(key: "app", defaultValue: nil)
    public var app: App?

    @JsonKeychain(key: "auth", defaultValue: nil)
    public var auth: Auth?

    public var permissions: [Permission] {
        guard let app = app else { return [] }
        
//        switch app.appMode {
//        case .beginner:
//            switch app.userType {
//            case .developer: return Permission.allCases
//            case .studentOrResearcher: return [ .exploreCatalog ]
//            case .engineerOrSale: return [ .exploreCatalog ]
//            case .other: return [ .exploreCatalog ]
//            default: return []
//            }
//        case .expert:
//            switch app.userType {
//            case .developer: return Permission.allCases
//            case .studentOrResearcher: return [ .exploreCatalog ]
//            case .engineerOrSale: return [ .exploreCatalog ]
//            case .other: return [ .exploreCatalog ]
//            default: return []
//            }
//        default:
//            return []
//        }

        return Permission.allCases.compactMap {
            if $0.appModesEnabled.contains(app.appMode),
               $0.userTypesEnabled.contains(app.userType) {
                return $0
            } else {
                return nil
            }
        }
    }

    public var isWelcomeNeeded: Bool {
        app == nil
    }

    public init() {
        let appMode = app?.appMode ?? .none
        let userType = app?.userType ?? .none

        print("App Mode: \(appMode.description)")
        print("User Type: \(userType.description)")
    }

    public func reset() {
        app = nil
    }

    public func update(appMode: AppMode, userType: UserType) {
        app = App(appMode: appMode, userType: userType)
    }

}

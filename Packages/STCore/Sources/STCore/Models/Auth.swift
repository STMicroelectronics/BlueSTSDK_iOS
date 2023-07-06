//
//  Auth.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct Auth {
    public let idToken: String?
    public let accessToken: String?
    public let refreshToken: String?

    public init(idToken: String?, accessToken: String?, refreshToken: String?) {
        self.idToken = idToken
        self.accessToken = accessToken
        self.refreshToken = refreshToken
    }
}

extension Auth: Codable {
    enum CodingKeys: String, CodingKey {
        case idToken
        case accessToken
        case refreshToken
    }
}

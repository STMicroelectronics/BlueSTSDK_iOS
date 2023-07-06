//
//  LoginService.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

public typealias LogoutCallback = (Bool) -> Void
public typealias AuthCompletion = (Error?) -> Void

public protocol LoginService {
    var isAuthenticated: Bool { get }
    var authData: Data? { get set }

    func resetAuthentication(from controller: UIViewController, completion: LogoutCallback?)
    func authenticate(from controller: UIViewController, completion: @escaping AuthCompletion)
    func resumeExternalUserAgentFlow(with url: URL) -> Bool
}

//
//  Container.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol Container: AnyObject {
    typealias Factory<T> = (Container) -> T?

    func register<T>(key: String, instance: T)
    func register<T>(key: String, factory: @escaping Factory<T>)

    func register<T>(type: T.Type, instance: T)
    func register<T>(type: T.Type, factory: @escaping Factory<T>)

    func resolve<T>() -> T?
    func resolve<T>(key: String) -> T?
}

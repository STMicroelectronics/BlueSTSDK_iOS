//
//  Resolver.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public final class Resolver {

    public static var shared = Resolver()

    private var components: [String: Any] = [:]

    public init() {}
}

private extension Resolver {
    func internalResolve<T>(for key: String) -> T? {
        guard let component = components[key] else {
            return nil
        }

        if let factory = component as? Factory<T> {
            return factory(self)
        }

        guard let result = component as? T else {
            return nil
        }

        return result
    }
}

extension Resolver: Container {
    public func register<T>(type: T.Type, instance: T) {
        register(key: "\(type)", instance: instance)
    }

    public func register<T>(type: T.Type, factory: @escaping Factory<T>) {
        components["\(type)"] = factory
    }

    public func register<T>(key: String, instance: T) {
        components[key] = instance
    }

    public func register<T>(key: String, factory: @escaping (Container) -> T?) {
        components[key] = factory
    }

    public func resolve<T>() -> T? {
        return resolve(key: "\(T.self)")
    }

    public func resolve<T>(key: String) -> T? {
        return internalResolve(for: key)
    }
}

//
//  WeakObject.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol Object {
    var id: UUID { get }
    var refItem: AnyObject? { get }
}

public class StrongObject<T>: Equatable, Object {
    public var id = UUID()

    public var refItem: AnyObject?

    public init(refItem: AnyObject) {
        self.refItem = refItem
    }

    public static func == (lhs: StrongObject, rhs: StrongObject) -> Bool {
        return lhs.id == rhs.id
    }
}

public class WeakObject<T>: Equatable, Object {
    public var id = UUID()

    public weak var refItem: AnyObject?

    public init(refItem: AnyObject) {
        self.refItem = refItem
    }

    public static func == (lhs: WeakObject, rhs: WeakObject) -> Bool {
        return lhs.id == rhs.id
    }
}

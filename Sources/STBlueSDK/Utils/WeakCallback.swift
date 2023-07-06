//
//  WeakCallback.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth

public typealias WriteCallback = (Error?) -> ()

public class WeakCallback<T> : Equatable {
    let id = UUID()

    weak var refItem: AnyObject?
    let callback: T

    public init(refItem: AnyObject, callback: T) {
        self.refItem = refItem
        self.callback = callback
    }

    public static func == (lhs: WeakCallback, rhs: WeakCallback) -> Bool {
        return lhs.id == rhs.id
    }
}

public class WeakWriteCallBack : WeakCallback<WriteCallback> {
    var characteristicUUID: CBUUID

    public init(refItem: AnyObject, characteristicUUID: CBUUID, callback: @escaping WriteCallback) {
        self.characteristicUUID = characteristicUUID

        super.init(refItem: refItem, callback: callback)
    }
}

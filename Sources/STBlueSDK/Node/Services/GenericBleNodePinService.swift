//
//  GenericBleNodePinService.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol GenericBleNodePinService {
    func setDialogShowed()
    func isDialogShowed() -> Bool
}

public class GenericBleNodePinServiceCore {
    private static let genericBleNodePinKey = "genericBleNodePinKey"
    private var defaultPinVisualized: Bool = false

    public init() {
        loadFavorites()
    }
    
    func loadFavorites() {
        let defaults = UserDefaults.standard
        let favorites = defaults.bool(forKey: GenericBleNodePinServiceCore.genericBleNodePinKey)
        defaultPinVisualized = favorites
    }
}

extension GenericBleNodePinServiceCore: GenericBleNodePinService {
    public func setDialogShowed(){
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: GenericBleNodePinServiceCore.genericBleNodePinKey)
        defaults.synchronize()
    }
    public func isDialogShowed() -> Bool {
        let defaults = UserDefaults.standard
        let isShowed = defaults.bool(forKey: GenericBleNodePinServiceCore.genericBleNodePinKey)
        return isShowed
    }
}

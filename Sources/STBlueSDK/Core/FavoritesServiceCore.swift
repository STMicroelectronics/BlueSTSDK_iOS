//
//  FavoritesService.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol FavoritesService {

    func addNodeToFavorites(node: Node)
    func removeNodeFromFavorites(node: Node)
    func isFavorite(node: Node) -> Bool
}

public class FavoritesServiceCore {
    private static let favoritesKey = "BlueManagerFavoritesKey"
    private var favoriteNodes: Set<String> = Set<String>()

    public init() {
        loadFavorites()
    }

    func loadFavorites() {
        let defaults = UserDefaults.standard
        guard let favorites = defaults.array(forKey: FavoritesServiceCore.favoritesKey) as? [String] else { return }

        favoriteNodes = Set<String>(favorites)
    }
}

extension FavoritesServiceCore: FavoritesService {
    public func addNodeToFavorites(node: Node) {
        guard let address = node.address else { return }
        favoriteNodes.insert(address)

        let defaults = UserDefaults.standard
        defaults.set(Array(favoriteNodes), forKey: FavoritesServiceCore.favoritesKey)
        defaults.synchronize()
    }

    public func removeNodeFromFavorites(node: Node) {
        guard let address = node.address else { return }
        favoriteNodes.remove(address)

        let defaults = UserDefaults.standard
        defaults.set(Array(favoriteNodes), forKey: FavoritesServiceCore.favoritesKey)
        defaults.synchronize()
    }

    public func isFavorite(node: Node) -> Bool {
        guard let address = node.address else { return false }

        return favoriteNodes.contains(address)
    }
}

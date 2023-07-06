//
//  Array+Node.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension Array where Element: Node {
    /**
     *  Search in the discovered node the one that has a particular name,
     *  @note the node name is not unique so we will return the first node that match the name
     *
     *  @param name node name to search
     *
     *  @return a node with the name, or nil if a node with that name doesn't exist
     */
    func nodeWith(name: String) -> Node? {
        return first { $0.name == name }
    }

    func nodeWith(address: String) -> Node? {
        return first { $0.address == address }
    }

    /**
     *  Search in the discovered node the one that has a particular tag
     *
     *  @param tag tag to search
     *
     *  @return a node with that tag or nil if the node doesn't exist
     */
    func nodeWith(tag: String) -> Node? {
        return first {
            return $0.peripheral.identifier.uuidString == tag
        }
    }
}

public extension Array {
    mutating func syncAppend(_ newElement: Element) {
        objc_sync_enter(self)

        defer { objc_sync_exit(self) }

        append(newElement)
    }

    mutating func syncRemove(at index: Int) {
        objc_sync_enter(self)

        defer { objc_sync_exit(self) }

        remove(at: index)
    }
}

//
//  NodeState.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

//connecting
//connected
//disconnecting
//disconneted
//ready connesso + scansione servizi


public enum NodeState: Int {
    case disconnected = 0
    case connecting = 1
    case connected = 2
    case disconnecting = 3
}

public extension NodeState {

    /**
     *  convert the enum value to a string
     *
     *  @param state enum with the current board status
     *
     *  @return a string representation of the enum value
     */

    var stringValue: String {
        switch self {
        case .disconnected:
            return NSLocalizedString("Disconnected", comment: "")
        case .connecting:
            return NSLocalizedString("Connecting", comment: "")
        case .connected:
            return NSLocalizedString("Connected", comment: "")
        case .disconnecting:
            return NSLocalizedString("Disconnecting", comment: "")
        }
    }
}

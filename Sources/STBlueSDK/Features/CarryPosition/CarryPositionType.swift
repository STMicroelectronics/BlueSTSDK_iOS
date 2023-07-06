//
//  CarryPositionType.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum CarryPositionType: UInt8 {
    /**
     *  we don't have enough data for select a position
     */
    case unknown = 0x00
    /**
     *  the node is on the desk
     */
    case onDesk = 0x01
    /**
     *  the node is in the user hand
     */
    case inHand = 0x02
    /**
     *  the node is in near the user head
     */
    case nearHead = 0x03
    /**
     *  the node is in the shirt pocket
     */
    case shirtPocket = 0x04
    /**
     *  tthe node is in the trousers pocket
     */
    case trousersPocket = 0x05
    /**
     *  the node is attached to an arm that is swinging
     */
    case armSwing = 0x06
    /**
     *  invalid code
     */
    case error = 0xFF
}

extension CarryPositionType: CustomStringConvertible {
    public var description: String {
        switch self {
        case .unknown:
            return "Unknown"
        case .onDesk:
            return "OnDesk"
        case .inHand:
            return "InHand"
        case .nearHead:
            return "NearHead"
        case .shirtPocket:
            return "ShirtPocket"
        case .trousersPocket:
            return "TrousersPocket"
        case .armSwing:
            return "ArmSwing"
        case .error:
            return "Error"
        }
    }
}

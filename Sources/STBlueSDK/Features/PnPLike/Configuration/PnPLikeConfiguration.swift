//
//  PnPLikeConfiguration.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PnPLikeConfiguration {
    public let name: String
    public let specificSensorOrGeneralType: PnPLType
    public let displayName: String?
    public var parameters: [PnPLikeConfigurationParameter]?
    public var visibile: Bool
}

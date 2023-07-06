//
//  EnvironmentalFeature.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol EnvironmentalFeature: Feature {

    var image: String { get }
    var missingImage: String { get }
    var isSecondaryUomEnabled: Bool { get }

    func valueString(with secondaryUom: Bool, offset: Double) -> String
    
}

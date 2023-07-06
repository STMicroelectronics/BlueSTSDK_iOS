//
//  HSDOptionModel.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class HSDOptionModel {
    public enum Mode {
        case odr
        case fs
    }
    
    public let mode: Mode
    public let name: String
    public let unit: String?
    public let values: [Double]
    public let selected: Double
    
    init(mode: Mode, name: String, unit: String?, values: [Double], selected: Double) {
        self.mode = mode
        self.name = name
        self.unit = unit
        self.values = values
        self.selected = selected
    }
}

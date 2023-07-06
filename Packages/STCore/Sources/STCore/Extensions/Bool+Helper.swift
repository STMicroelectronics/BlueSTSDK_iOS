//
//  Bool+Helper.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//


import Foundation

public extension Bool {
    var string: String {
        self == true ? "true" : "false"
    }
}

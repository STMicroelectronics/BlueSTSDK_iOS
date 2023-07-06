//
//  Int+Helper.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal extension Int {
    func roundToBeMultipleOf(_ multiple: Int) -> Int {
        let ( _, renainder ) = self.quotientAndRemainder(dividingBy: multiple)
        return renainder == 0 ? self : self + multiple - renainder
    }
}

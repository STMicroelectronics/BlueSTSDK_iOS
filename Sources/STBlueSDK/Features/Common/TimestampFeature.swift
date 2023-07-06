//
//  TimestampFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class TimestampFeature<T: Loggable & CustomStringConvertible>: BaseFeature<T> {
    
    public override func update(with timestamp: UInt64, data: Data, offset: Int, mtu: Int) -> Int {
        let time = UInt64(Date.timeIntervalSinceReferenceDate * 1000)
        
        return super.update(with: time, data: data, offset: offset - 2, mtu: mtu)
    }
}



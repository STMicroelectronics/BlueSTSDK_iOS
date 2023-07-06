//
//  BatteryCommandResponse.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class BatteryCommandResponse: BaseCommandResponse {
    var capacity: Float? {
        get {
            if commandType == BatteryCommand.getBatteryCapacity.rawValue {
                return Float(data.extractUInt16(fromOffset: 0))
            }

            return nil
        }
    }

    var current: Float? {
        get {
            if commandType == BatteryCommand.getMaxAssorbedCurrent.rawValue {
                return Float(data.extractInt16(fromOffset: 0))
            }

            return nil
        }
    }
}

//
//  COSensorCommandResponse.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class COSensorCommandResponse: BaseCommandResponse {
    var sensitivity: Float? {
        get {
            if commandType == COSensorCommand.getSesintivity.value {
                return data.extractFloat(fromOffset: 0)
            }
            
            return nil
        }
    }
}

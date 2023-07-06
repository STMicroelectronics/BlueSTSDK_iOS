//
//  FirmwareUpgradeParam.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal struct FirmwareUpgradeParam {
    
    private static let safePackageLength = UInt(16)
    
    let file: URL
    let baseAddress: UInt32?
    let packageSize: UInt
    
    static func buildSafeParamFrom(param: FirmwareUpgradeParam) -> FirmwareUpgradeParam {
        return FirmwareUpgradeParam(file: param.file,
                                    baseAddress: param.baseAddress,
                                    packageSize: FirmwareUpgradeParam.safePackageLength)
    }
    
}

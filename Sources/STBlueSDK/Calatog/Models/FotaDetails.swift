//
//  FotaDetails.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct FotaDetails {
    public let partialFota: Int?
    public let type: FotaType?
    public let fotaMaxChunkLength: Int?
    public let fotaChunkDivisorConstraint: Int?
    public let url: String?
    public let bootLoaderType: BootLoaderType?
}

extension FotaDetails: Codable {
    enum CodingKeys: String, CodingKey {
        case partialFota = "partial_fota"
        case type
        case fotaMaxChunkLength = "fota_max_chunk_length"
        case fotaChunkDivisorConstraint = "fota_chunk_divisor_constraint"
        case url = "fw_url"
        case bootLoaderType = "bootloader_type"
    }
}

public enum FotaType: String, Codable {
    case no
    case yes
    case fast
    case wbMode = "wb_mode"
    case wbReady = "wb_ready"
}

public enum BootLoaderType: String, Codable {
    case none
    case custom
    case wb
    case sbsfu
}

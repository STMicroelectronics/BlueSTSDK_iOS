//
//  Catalog.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct Catalog {
    public var blueStSdkV2: [Firmware]
    public let blueStSdkV1: [Firmware]?
    public let characteristics: [BleCharacteristic]?
    public let boards: [CatalogBoard]?
    public let checksum: String?
    public let date: String?
    public let version: String?
}

extension Catalog: Codable {
    enum CodingKeys: String, CodingKey {
        case blueStSdkV2 = "bluestsdk_v2"
        case blueStSdkV1 = "bluestsdk_v1"
        case characteristics
        case boards
        case checksum
        case date
        case version
    }
}

public extension Catalog {
    
    mutating func add(customFirmwares firmwares: [Firmware]) {
        blueStSdkV2.append(contentsOf: firmwares)
    }
    
    func v2Firmware(with deviceId: Int, optByte0: Int, optByte1: Int) -> Firmware? {
        var selectedFirmware: Firmware?

        let bleFwId = optByte0 != 0x00 ? optByte0 : optByte1 + 256

        if bleFwId < 0 {
            return nil
        }

        for firmware in blueStSdkV2 {
            if let unwrappedDeviceId = UInt8(firmware.deviceId.dropFirst(2), radix: 16),
               let unwrappedBleVersionId = UInt8(firmware.bleVersionIdHex.dropFirst(2), radix: 16),
                unwrappedDeviceId == deviceId,
                unwrappedBleVersionId == bleFwId {
                selectedFirmware = firmware
            }
        }

        return selectedFirmware
    }

    func v2Firmware(with deviceId: String, firmwareId: String, checkCustomFirmware: Bool = true) -> Firmware? {
        blueStSdkV2.first(where: {
            if checkCustomFirmware {
                return $0.deviceId.lowercased() == deviceId.lowercased() && $0.bleVersionId == 0xff ||
                $0.deviceId.lowercased() == deviceId.lowercased() && $0.bleVersionIdHex.lowercased() == firmwareId.lowercased()
            } else {
                return $0.deviceId.lowercased() == deviceId.lowercased() && $0.bleVersionIdHex.lowercased() == firmwareId.lowercased()
            }
        })
    }

    func v2Firmware(with node: Node) -> Firmware? {
        blueStSdkV2.first(where: {
            $0.deviceId.lowercased() == node.deviceId.longHex && $0.bleVersionId == 0xff ||
            $0.deviceId.lowercased() == node.deviceId.longHex && $0.bleVersionIdHex.lowercased() == node.bleFirmwareVersion.longHex
        })
    }

    func v1Firmware(with node: Node) -> Firmware? {
        blueStSdkV1?.first(where: {
            $0.deviceId.lowercased() == node.deviceId.longHex && $0.bleVersionIdHex.lowercased() == node.bleFirmwareVersion.longHex
        })
    }

    func availableNewV2Firmwares(with deviceId: String, currentFirmware: Firmware) -> [Firmware]? {

        availableV2Firmwares(with: deviceId, currentFirmware: currentFirmware)?.filter {
            $0.name == currentFirmware.name &&
            $0.version > currentFirmware.version &&
            $0.fota?.url != nil &&
            !($0.fota?.url?.isEmpty ?? true)
        }
    }

    func mostRecentAvailableNewV2Firmware(with deviceId: String, currentFirmware: Firmware) -> Firmware? {
        availableNewV2Firmwares(with: deviceId, currentFirmware: currentFirmware)?.max(by: { $0.version < $1.version } )
    }

    func availableV2Firmwares(with deviceId: String, currentFirmware: Firmware?) -> [Firmware]? {
        blueStSdkV2.filter {
            $0.deviceId.lowercased() == deviceId.lowercased() &&
            $0.bleVersionIdHex.lowercased() != currentFirmware?.bleVersionIdHex.lowercased()
        }
    }
}

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
import STCore

public struct Catalog {
    public var blueStSdkV2: [Firmware]
    public let blueStSdkV1: [Firmware]?
    public let characteristics: [BleCharacteristic]?
    public let boards: [CatalogBoard]?
    public let sensorAdapters: [SensorAdapterElement]?
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
        case sensorAdapters = "sensor_adapters"
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

    func v2Firmware(with deviceId: String, name: String, checkCustomFirmware: Bool = true) -> Firmware? {

        v2Firmware(with: deviceId, names: [ name ], checkCustomFirmware: checkCustomFirmware)
    }

    func v2Firmware(with deviceId: String, names: [String], checkCustomFirmware: Bool = true) -> Firmware? {

        blueStSdkV2.first(where: { firmware in
            firmware.deviceId.lowercased() == deviceId.lowercased() && 
            names.compactMap { firmware.name.lowercased().starts(with: $0.lowercased()) ? true : nil }.count != 0 &&
            firmware.bleVersionId != 0xff
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

    func availableNewV2Firmwares(with deviceId: String, currentFirmware: Firmware, enabledFirmwares: [String]?) -> [Firmware]? {

        availableV2Firmwares(with: deviceId, currentFirmware: currentFirmware, enabledFirmwares: enabledFirmwares)?.filter {
            $0.name == currentFirmware.name &&
            $0.version > currentFirmware.version &&
            $0.fota?.url != nil &&
            !($0.fota?.url?.isEmpty ?? true)
        }
    }

    func mostRecentAvailableNewV2Firmware(with deviceId: String, currentFirmware: Firmware) -> Firmware? {
        availableNewV2Firmwares(with: deviceId, currentFirmware: currentFirmware, enabledFirmwares: nil)?.max(by: { $0.version < $1.version } )
    }

    func availableV2Firmwares(with deviceId: String, currentFirmware: Firmware?, enabledFirmwares: [String]?) -> [Firmware]? {

        for firmware in self.blueStSdkV2 {
            Logger.debug(text: "\(firmware.name) - \(firmware.version)")
        }

        return blueStSdkV2.filter { firmware in
            let flag = firmware.deviceId.lowercased() == deviceId.lowercased() &&
            firmware.bleVersionIdHex.lowercased() != currentFirmware?.bleVersionIdHex.lowercased() &&
            enabledFirmwares?.contains(where: { firmwareId in
                return firmware.bleVersionIdHex.lowercased() == firmwareId.lowercased()
            }) ?? true

            return flag
        }
    }

    func availableV2Firmwares(with deviceId: String, names: [String]?, supportedVersions: [String]? = nil) -> [Firmware]? {
        blueStSdkV2.filter { firmware in
            let flag = names != nil ? names?.compactMap { firmware.name.lowercased().starts(with: $0.lowercased()) ? true : nil }.count != 0 : true
            let supported = (supportedVersions != nil) ? supportedVersions!.contains(firmware.version) : true
            return firmware.deviceId.lowercased() == deviceId.lowercased() && flag && supported

        }
    }
}

public extension Array where Element == Firmware {
    var uniqueFwName: [Firmware] {
        var uniqueValues: [Firmware] = []
        forEach { item  in
            if !uniqueValues.contains(where: {value in return value.name==item.name}) {
                uniqueValues.append(item)
            }
        }
        return uniqueValues
    }
}

//
//  Node+Advertise.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore

public extension Node {
    var name: String? {
        return advertiseInfo.name
    }

    var deviceId: UInt8 {
        return advertiseInfo.deviceId
    }

    var bleFirmwareVersion: Int {
        return advertiseInfo.bleFirmwareId
    }

    var address: String? {
        return advertiseInfo.address
    }

    var compoundAddress: String? {
        if let address = address, !address.isEmpty {
            return address
        } else {
            return tag
        }
    }

    var tag: String? {
        return peripheral.identifier.uuidString
    }

    var protocolVersion: UInt8 {
        return advertiseInfo.protocolVersion
    }

    var advertisingMask: UInt32 {
        return advertiseInfo.featureMap
    }

    var type: NodeType {
        return advertiseInfo.boardType
    }

    var isSleeping: Bool {
        advertiseInfo.isSleeping
    }

    var hasExtension: Bool {
        advertiseInfo.hasGeneralPurpose
    }

    var isMLCSupportedKey: String {
        return type == NodeType.sensorTileBoxPro || type == NodeType.sensorTileBoxProB || type == NodeType.sensorTileBoxProC ? "lsm6dsv16x_mlc" : "ism330dhcx_mlc"
    }

    var mlcSensorName: String {
        return type == NodeType.sensorTileBoxPro || type == NodeType.sensorTileBoxProB || type == NodeType.sensorTileBoxPro ? "lsm6dsv16x" : "ism330dhcx"
    }

    var maxPnplMtu: Int {
        if let internalPnpMaxMtu = internalPnpMaxMtu {
            return internalPnpMaxMtu
        }

        if let feature = characteristics.first(with: PnPLFeature.self) as? PnPLFeature,
           let catalogService: CatalogService = Resolver.shared.resolve(),
           let catalog = catalogService.catalog,
           let firmwareDB = catalog.v2Firmware(with: self),
           let pnpLMaxWriteLength = firmwareDB.characteristics?.first(where: { $0.uuid == feature.type.uuid.uuidString.lowercased()})?.maxWriteLength {
            internalPnpMaxMtu = pnpLMaxWriteLength > mtu ? mtu : pnpLMaxWriteLength
        } else {
            internalPnpMaxMtu = 20
        }

        return internalPnpMaxMtu!
    }
    
    var bleFirmwareName: String? {
        guard let catalogService: CatalogService = Resolver.shared.resolve(),
              let catalog = catalogService.catalog else { return nil}
        if let firmware = catalog.v2Firmware(with: deviceId.longHex, firmwareId: UInt32(advertiseInfo.bleFirmwareId).longHex) {
            return "\(firmware.name) v\(firmware.version)"
        }
        return nil
    }
}

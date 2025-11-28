//
//  Node+BLE.swift
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

    var availableFeatureTypes: [FeatureType] {
        FeatureType.nodeFeatureTypes(self.type)
    }

    var isConnected: Bool {
        state == NodeState.connected
    }

    var hasDebugConsole: Bool {
        characteristics.contains(where: { $0.characteristic.uuid == BlueUUID.Service.Debug.termUuid })
    }

    var hasPnPL: Bool {
        (characteristics.allFeatures().first(where: { $0 is PnPLFeature }) != nil)
    }

    var mtu: Int {
        return peripheral.maximumWriteValueLength(for: .withoutResponse)
    }

    var otaAddress: String? {

        // Available only for STM32 WB boards

        guard let address = address,
              let lastDigit = Int(address.suffix(2), radix: 16) else {
                  return nil
              }

        return address.prefix(address.count - 2).appending(String(format: "%02X", lastDigit + 1))
    }

    func isOTA() -> Bool {

        guard let catalogService: CatalogService = Resolver.shared.resolve(),
              let catalog = catalogService.catalog else {
            return false
        }

        var isOta = false

        if type == .wbOtaBoard  {
            isOta = true
        }

        if protocolVersion == 0x02 {
            let firmware = catalog.v2Firmware(with: Int(type.rawValue & 0xFF),
                                            optByte0: Int(optionByte(0)),
                                            optByte1: Int(optionByte(1)))

            if let firmware = firmware,
               firmware.fota?.type == .wbReady {
                isOta = true
            }
        }

        return isOta
    }

    func optionByte(_ index: Int) -> UInt8 {
        let optBytes = withUnsafeBytes(of: advertiseInfo.featureMap.bigEndian, Array.init)
        let optBytesData =  Data(bytes: optBytes, count: optBytes.count)

        return optBytesData.extractUInt8(fromOffset: index)
    }
}

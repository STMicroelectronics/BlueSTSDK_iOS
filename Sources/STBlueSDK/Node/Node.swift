//
//  Node.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth
import STCore

public class Node {
    
    public var peripheral: CBPeripheral
    public var rssi: Int?
    private let advertiseInfo: AdvertiseInfo
    public var state: NodeState = .disconnected
    public var characteristics: [BlueCharacteristic] = [BlueCharacteristic]()

    init(peripheral: CBPeripheral, rssi: Int, advertiseInfo: AdvertiseInfo) {
        self.peripheral = peripheral
        self.rssi = rssi
        self.advertiseInfo = advertiseInfo
    }

    deinit {
        STBlueSDK.log(text: "DEINIT NODE")
    }
}

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

    func imageIndexes(with firmware: Firmware) -> [Int] {

        var images = [Int]()

        let optBytesUnsigned = withUnsafeBytes(of: advertiseInfo.featureMap.bigEndian, Array.init)

        var offsetForFirstOptByte: Int = 0

        if optBytesUnsigned[0] == 0x00 {
            offsetForFirstOptByte = 1
        }

        guard let optionBytes = firmware.optionBytes else { return images }

        for i in 0..<optionBytes.count {
            if optionBytes[i].format == "enum_icon",
               let iconValues = optionBytes[i].iconValues {
                images.append(contentsOf: iconValues.compactMap({ element in

                    if let value = element.value,
                       value == optBytesUnsigned[i + 1 + offsetForFirstOptByte] {
                        return element.code
                    } else {
                        return nil
                    }

                }))
            }
        }

        return images
    }

    func firstExtraMessage(with firmware: Firmware) -> String? {

        var message: String? = nil

        let optBytesUnsigned = withUnsafeBytes(of: advertiseInfo.featureMap.bigEndian, Array.init)
        let offsetForFirstOptByte: Int = advertiseInfo.offsetForFirstOptByte

        guard let optionBytes = firmware.optionBytes else { return nil }

        for i in 0..<optionBytes.count {

            let currentOptionByte = optionBytes[i]

            if currentOptionByte.format == "int" {
                if let escapeValue = currentOptionByte.escapeValue {
                    if escapeValue == optBytesUnsigned[i + 1 + offsetForFirstOptByte] {
                        message = currentOptionByte.escapeMessage ?? " "
                    } else if let negativeOffset = currentOptionByte.negativeOffset,
                              let name = currentOptionByte.name,
                              let scaleFactor = currentOptionByte.scaleFactor,
                              let type = currentOptionByte.type {
                        message = name +
                        " " +
                        String((Int(optBytesUnsigned[i + 1 + offsetForFirstOptByte]) - negativeOffset) * scaleFactor) +
                        " " +
                        type
                    } else {
                        message = nil
                    }
                } else if let negativeOffset = currentOptionByte.negativeOffset,
                          let scaleFactor = currentOptionByte.scaleFactor,
                          let type = currentOptionByte.type,
                          let name = currentOptionByte.name {
                    message = name +
                    " " +
                    String((Int(optBytesUnsigned[i + 1 + offsetForFirstOptByte]) - negativeOffset) * scaleFactor) + " " + type
                } else {
                    message = nil
                }
            }
        }

        return message
    }


    func secondExtraMessage(with firmware: Firmware) -> String? {

        var enumMessages = [String]()

        let optBytesUnsigned = withUnsafeBytes(of: advertiseInfo.featureMap.bigEndian, Array.init)
        let offsetForFirstOptByte: Int = advertiseInfo.offsetForFirstOptByte

        guard let optionBytes = firmware.optionBytes else { return nil }

        for i in 0..<optionBytes.count {

            let currentOptionByte = optionBytes[i]

            if currentOptionByte.format == "enum_string",
                      let name = currentOptionByte.name,
                      let optByteStringValues = currentOptionByte.stringValues {

                if let element = optByteStringValues.first(where: { current in
                    if let value = current.value {
                        return value == optBytesUnsigned[i + 1 + offsetForFirstOptByte]
                    }

                    return false
                }),
                   let displayName = element.displayName {
                    enumMessages.append(name + displayName)
                } else {
                    enumMessages.append(name)
                }
            }
        }

        return enumMessages.joined(separator: " ")
    }

    var availableFeatureTypes: [FeatureType] {
        FeatureType.nodeFeatureTypes(self.type)
    }

    var isConnected: Bool {
        state == NodeState.connected
    }

    var hasDebugConsole: Bool {
        characteristics.contains(where: { $0.characteristic.uuid == BlueUUID.Service.Debug.termUuid })
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

        if type == .wbOtaBoard || type == .wbaBoard {
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

extension Node: Equatable {
    public static func == (lhs: Node, rhs: Node) -> Bool {
        return lhs.address == rhs.address
    }
}

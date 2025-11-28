//
//  Node+String.swift
//
//  Copyright (c) 2023 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension Node {
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
    
    func getOptionBytesMessagesForBoxProFlow(with firmware: Firmware) -> [String]? {

        var enumMessages = [String]()

        let optBytesUnsigned = withUnsafeBytes(of: advertiseInfo.featureMap.bigEndian, Array.init)
        let offsetForFirstOptByte: Int = advertiseInfo.offsetForFirstOptByte

        guard let optionBytes = firmware.optionBytes else { return nil }

        for i in 0..<optionBytes.count {

            let currentOptionByte = optionBytes[i]

            if currentOptionByte.format == "enum_string",
                      let optByteStringValues = currentOptionByte.stringValues {

                if let element = optByteStringValues.first(where: { current in
                    if let value = current.value {
                        return value == optBytesUnsigned[i + 1 + offsetForFirstOptByte]
                    }

                    return false
                }),
                   let displayName = element.displayName {
                    enumMessages.append(displayName)
                } else {
                    enumMessages.append("")
                }
            }
        }

        return enumMessages
    }
}

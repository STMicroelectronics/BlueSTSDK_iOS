//
//  Node+Image.swift
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
}

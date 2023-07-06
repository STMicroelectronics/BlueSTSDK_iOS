//
//  Data+Firmware.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal extension Data {
    func buildLoadCommand() -> Data? {

        var command = Data()
        guard let commandData = "upgradeFw".data(using: .isoLatin1) else { return nil }
        command.append(commandData)

        let crc = BlueSTM32CRC.getCrc(self)

        Swift.withUnsafeBytes(of: UInt32(count)) { command.append(contentsOf: $0) }
        Swift.withUnsafeBytes(of: crc) { command.append(contentsOf: $0) }

        return command
    }
}

internal extension Array where Element == Data {

    var dataSize: Int {
        map { $0.count }
        .reduce(0, +)
    }
}

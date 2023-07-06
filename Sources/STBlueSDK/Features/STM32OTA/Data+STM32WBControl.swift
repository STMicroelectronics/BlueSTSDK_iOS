//
//  Data+STM32WBControl.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal struct STM32WBCommand {
    static let rebootOtaMode = UInt8(0x01)
    static let stop = UInt8(0x00)
    static let startM0 = UInt8(0x01)
    static let startM4 = UInt8(0x02)
    static let finish = UInt8(0x07)
    static let cancel = UInt8(0x08)
}

internal extension Data {
    static func rebootToFlashCommand(sectorOffset: UInt8,numSector: UInt8) -> Data {
        Data([STM32WBCommand.rebootOtaMode, sectorOffset, numSector])
    }

    static func stopUpload() -> Data {
        Data([STM32WBCommand.stop])
    }

    static func startUpload(type: FirmwareType, fileLength: Int?) -> Data? {

        var uploadType = STM32WBCommand.startM4
        
        if case .radio = type {
            uploadType = STM32WBCommand.startM0
        }

        var commandData = Data()


        guard let address = type.firstSectorToFlash else { return nil }

        Swift.withUnsafeBytes(of: address.bigEndian) { commandData.append(contentsOf: $0) }

        commandData[0] = uploadType
        
        if(type.mustWaitForConfirmation) {
            commandData.append(type.numberOfSectors(with: UInt64(fileLength ?? 0)) ?? 0)
        }

        return commandData
    }


    /// tell to the board that we finish to upload the file
    static func uploadFinished() -> Data {
        Data([STM32WBCommand.finish])
    }

    /// tell to the board that we abort the file upload
    static func cancelUpload() -> Data {
        Data([STM32WBCommand.cancel])
    }

}

//
//  DebugConsoleFirmwareLoader.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal class DebugConsoleFirmwareLoader: BaseFirmwareLoader {

    private var lastCall: Date = Date()

    override func sendFwPackage(console: DebugConsole) -> Bool {

        let packageSize = min(firmwareData.count - byteSent, chunkSize)
        guard packageSize != 0 else {
            return false; // nothing to send
        }

        let dataToSend = firmwareData[byteSent..<byteSent + packageSize]

        byteSent = byteSent + packageSize

        let diff = -lastCall.timeIntervalSinceNow
        if diff < 0.013 {
            STBlueSDK.log(text: "[Firmware upgrade] Error: \(diff)")
        }

        lastCall = Date()

        return console.writeFast(data: dataToSend)
    }
}

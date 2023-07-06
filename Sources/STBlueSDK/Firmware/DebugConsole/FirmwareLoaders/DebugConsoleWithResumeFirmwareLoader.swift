//
//  DebugConsoleWithResumeFirmwareLoader.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal class DebugConsoleWithResumeFirmwareLoader: BaseFirmwareLoader {

    var numerOfPacketSent: UInt32 = 0

    override func sendFwPackage(console: DebugConsole) -> Bool {

        numerOfPacketSent = numerOfPacketSent * UInt32(chunkSize)
        let packageSize = min(firmwareData.count - byteSent, chunkSize)

        guard packageSize > 0 else {
            return false
        }

        var dataToSend = firmwareData[byteSent..<byteSent + packageSize]
        dataToSend.append(Data(bytes: &numerOfPacketSent, count: 4))
        byteSent += packageSize
        numerOfPacketSent += 1
        return console.writeFast(data: dataToSend)
    }

    override func console(_ console: DebugConsole, didReceiveErrorMessage message: String) {
        guard let messageData = message.data(using: .isoLatin1) else {
            return
        }

        guard messageData[0] == 0x01 else {
            return
        }

        timeoutWorkItem?.cancel()

        let lastPacakgeReceved = UInt32(messageData.extractInt32(fromOffset: 1))

        messagesQueue.async { [weak self] in
            guard let self = self else { return }
            STBlueSDK.log(text: "error -> \(self.numerOfPacketSent) to \(lastPacakgeReceved)")
            self.numerOfPacketSent = lastPacakgeReceved + 1
        }
    }
}

//
//  BaseFirmwareLoader.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit

internal class BaseFirmwareLoader: DebugConsoleDelegate {

    internal static let ackReps = "\u{01}"
    internal static let timeout: TimeInterval = 1.0
    internal static let numberOfBlocksForPackage: Int = 10

    internal let url: URL

    internal let messagesQueue: DispatchQueue
    internal var timeoutWorkItem: DispatchWorkItem?
    internal let packageDelay: UInt64
    internal let firmwareData: Data
    internal let crc: UInt32

    internal var chunkSize: Int = 16

    internal var nodeReadyToReceiveFile = false
    internal var byteSent = 0
    internal var numberOfPackageReceived = 0
    internal var maxMtu: Int
    internal var callback: FirmwareUpgradeCallback?
    internal var writeError = false

    init(url: URL, firmwareData: Data, packageDelay: UInt, fastFota: Bool, maxMtu: Int, callback: FirmwareUpgradeCallback) {
        self.url = url
        self.firmwareData = firmwareData
        self.packageDelay = UInt64(packageDelay) * UInt64(1000000) // Nano seconds
        self.crc = BlueSTM32CRC.getCrc(firmwareData)
        self.maxMtu = maxMtu
        self.callback = callback

        self.nodeReadyToReceiveFile = false
        self.byteSent = 0
        self.numberOfPackageReceived = 0

        if fastFota {
            chunkSize = maxMtu

            while !(chunkSize % 8 == 0) {
                chunkSize = chunkSize - 1
            }
            STBlueSDK.log(text: "[Firmware upgrade] >>FAST FOTA Debug Console<< chunkLength: \(chunkSize)")
        }

        messagesQueue = DispatchQueue(label: "DebugConsoleFirmwareLoader")
    }

    internal func setupTimeoutWorkItem() {
        timeoutWorkItem?.cancel()
        timeoutWorkItem = DispatchWorkItem { [weak self] in
            guard let self = self,
            DispatchQueue.main.sync(execute: { UIApplication.shared.applicationState }) == .active else { return }

            self.callback?.completion(self.url, .trasmissionError)
        }

        guard let timeOutWorkItem = timeoutWorkItem else { return }

        messagesQueue.asyncAfter(deadline: .now() + BaseFirmwareLoader.timeout, execute: timeOutWorkItem)
    }

    internal func checkCrc(response: String) -> Bool {
        let data = response.data(using: .isoLatin1)
        let ackCrc = data?.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            ptr.bindMemory(to: UInt32.self).first
        }
        return ackCrc == crc
    }

    internal func onLoadFail(console: DebugConsole, error: FirmwareUpgradeError){
        writeError = true
        callback?.completion(url, error)
        console.removeDelegate(self)
        callback = nil
    }

    internal func onLoadComplete(console: DebugConsole) {
        console.removeDelegate(self)
        callback?.progress(url, 0, firmwareData.count)
        callback?.completion(url, nil)
        callback = nil
    }

    internal func sendFwPackage(console: DebugConsole) -> Bool {
        return false
    }

    func console(_ console: DebugConsole, didReceiveTerminalMessage message: String) {
        if !nodeReadyToReceiveFile {
            if checkCrc(response: message) {
                nodeReadyToReceiveFile = true
                numberOfPackageReceived = 0
                sendNextFwPackage(console: console)
            } else{
                onLoadFail(console: console, error: .trasmissionError)
            }
        } else {
            timeoutWorkItem?.cancel()
            if message == BaseFirmwareLoader.ackReps {
                onLoadComplete(console: console)
            } else {
                onLoadFail(console: console, error: .corruptedFile)
            }
        }
    }

    func console(_ console: DebugConsole, didReceiveErrorMessage message: String) {

    }

    func console(_ console: DebugConsole, didSendMessage message: String?, error: Error?) {
        guard error == nil else {
            onLoadFail(console: console, error: .trasmissionError)
            return
        }

        if nodeReadyToReceiveFile {
            if let timeoutWorkItem = timeoutWorkItem {
                timeoutWorkItem.cancel()
            }
            notifyNodeReceivedFwMessage()
            setupTimeoutWorkItem()
        } else {
            if let message = message,
               let data = message.data(using: .utf8) {
                STBlueSDK.log(text: "\(data.hex)")
            } else {
                STBlueSDK.log(text: "n/a")
            }
        }
    }

}

extension String {
    var decodingUnicodeCharacters: String { applyingTransform(.init("Hex-Any"), reverse: false) ?? "" }
}

private extension BaseFirmwareLoader {
    func notifyNodeReceivedFwMessage() {
        numberOfPackageReceived += 1
        if numberOfPackageReceived % BaseFirmwareLoader.numberOfBlocksForPackage == 0 {
            callback?.progress(url, byteSent, firmwareData.count)
        }
    }
}

internal extension BaseFirmwareLoader {
    func sendNextFwPackage(console: DebugConsole) {
        let when = DispatchTime(uptimeNanoseconds: DispatchTime.now().uptimeNanoseconds + packageDelay)
        messagesQueue.asyncAfter(deadline: when) { [weak self] in

            guard let self = self else { return }

            //mDelegate is set to nil in case of error
            if self.sendFwPackage(console: console) && !self.writeError {
                self.sendNextFwPackage(console: console)
            }
        }
    }
}

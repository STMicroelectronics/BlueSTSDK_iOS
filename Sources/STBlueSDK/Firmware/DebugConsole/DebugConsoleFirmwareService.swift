//
//  DebugConsoleFirmwareService.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal class DebugConsoleFirmwareService: BaseFirmwareService {

    private let nodeService: NodeService
    private let packageDelay: UInt
    private let fastFota: Bool
    private let resume: Bool

    init(nodeService: NodeService, packageDelay: UInt = 13, fastFota: Bool, resume: Bool) {
        self.nodeService = nodeService
        self.packageDelay = packageDelay
        self.fastFota = fastFota
        self.resume = resume
    }

    override func upgradeFirmware(with url: URL, type: FirmwareType, callback: FirmwareUpgradeCallback) {
        guard case .application(let value) = type,
              case .other = value else {
            callback.completion(url, .unsupportedOperation)
            return
        }

        super.upgradeFirmware(with: url, type: type, callback: callback)
    }

    override func startLoading(with url: URL, type: FirmwareType, firmwareData: Data, callback: FirmwareUpgradeCallback) {
        
        guard let debugConsole = nodeService.debugConsole else {
            callback.completion(url, .unknownError)
            return
        }

        if resume {
            debugConsole.addDelegate(DebugConsoleWithResumeFirmwareLoader(url: url,
                                                                          firmwareData: firmwareData,
                                                                          packageDelay: packageDelay,
                                                                          fastFota: fastFota,
                                                                          maxMtu: nodeService.node.mtu,
                                                                          callback: callback))
        } else {
            debugConsole.addDelegate(DebugConsoleFirmwareLoader(url: url,
                                                                firmwareData: firmwareData,
                                                                packageDelay: packageDelay,
                                                                fastFota: fastFota,
                                                                maxMtu: nodeService.node.mtu,
                                                                callback: callback))
        }

        STBlueSDK.log(text: "[Firmware upgrade] Start loading")

        guard let loadCommandData = firmwareData.buildLoadCommand() else {
            callback.completion(url, .invalidFwFile)
            return
        }

        STBlueSDK.log(text: "[Firmware upgrade] Start command: \(loadCommandData.hex)")

        debugConsole.write(data: loadCommandData)
    }

    override func currentVersion(_ completion: @escaping FirmwareVersionCompletion) {
        let command = "versionFw\r\n"

        BlueManager.shared.sendMessage(command,
                                       to: nodeService.node,
                                       completion: DebugConsoleCallback(timeOut: 1.0,
                                                                        onCommandResponds: { text in
            completion(FirmwareVersion(with: text))
        }, onCommandError: {
            completion(nil)
        }))

    }
}

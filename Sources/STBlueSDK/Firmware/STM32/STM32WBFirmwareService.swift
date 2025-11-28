//
//  STM32WBFirmwareService.swift
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

internal class STM32WBFirmwareService: BaseFirmwareService {
    
    private let writeQueue = DispatchQueue(label: "STM32WBFirmwareService_writeQueue")
    
    private static let disconnectDelay: TimeInterval = 0.3
    private static let discoveryTimeout = 30 * 1000
    private static var writeDelay: TimeInterval = 0.001
    
    var control: BlueCharacteristic?
    var upload: BlueCharacteristic?
    var reboot: BlueCharacteristic?
    var willReboot: BlueCharacteristic?
    var nodeService: NodeService
    
    init?(with nodeService: NodeService) {
        if let reboot = nodeService.node.characteristics.characteristic(with: STM32WBRebootOtaModeFeature.self) {
            self.reboot = reboot
            self.nodeService = nodeService
            super.init()
            
            BlueManager.shared.addDelegate(self)
        } else if let upload = nodeService.node.characteristics.characteristic(with: STM32WBOtaUploadFeature.self) {
            self.upload = upload
            self.nodeService = nodeService
            super.init()
            
            BlueManager.shared.addDelegate(self)
        } else {
            return nil
        }
    }
    
    deinit {
        STBlueSDK.log(text: "DEINIT FIRMWARE UPGRADE")
    }
    
    override func upgradeFirmware(with url: URL, type: FirmwareType, callback: FirmwareUpgradeCallback) {
        switch type {
        case .application(let board), .radio(let board):
            if case .other = board {
                BlueManager.shared.removeDelegate(self)
                callback.completion(url, .unsupportedOperation)
                return
            }
            
        default:
            BlueManager.shared.removeDelegate(self)
            callback.completion(url, .unsupportedOperation)
            return
        }
        
        super.upgradeFirmware(with: url, type: type, callback: callback)
    }
    
    override func currentVersion(_ completion: @escaping FirmwareVersionCompletion) {
        let version = if nodeService.node.type == NodeType.nucleoWB0X {
            FirmwareVersion(name: "STM32WB0X OTA",
                            mcuType: "STM32WB0X",
                            major: 1,
                            minor: 0,
                            patch: 0)
        } else if nodeService.node.type.family == NodeFamily.wbaFamily {
            FirmwareVersion(name: "STM32WBA OTA",
                            mcuType: "STM32WBA",
                            major: 1,
                            minor: 0,
                            patch: 0)
        } else {
            FirmwareVersion(name: "STM32WB OTA",
                            mcuType: "STM32WB",
                            major: 1,
                            minor: 0,
                            patch: 0)
        }
        
        completion(version)
    }
    
    override func startLoading(with url: URL, type: FirmwareType, firmwareData: Data, callback: FirmwareUpgradeCallback) {
        
        super.startLoading(with: url, type: type, firmwareData: firmwareData, callback: callback)
        
        //        print("STARTING STM32WB OTA UPGRADE...")
        //        print("type: \(type)")
        //        print("typeFromNode: \(nodeService.node.type)")
        
        // STEP 1.: REBOOT IN OTA MODE if it's necessary
        if nodeService.node.isOTA() ||
            type.wbBoardType == .wba5 ||
            type.wbBoardType == .wb09 ||
            type.wbBoardType == .wba6 ||
            type.wbBoardType == .wba2 ||
            type.wbBoardType == .st67w6x {
        //if nodeService.node.isOTA() || nodeService.node.type.family == .wbaFamily || nodeService.node.type == .nucleoWB0X  {
            DispatchQueue.global(qos: .background).async { [weak self] in
                guard let self = self else { return }
                self.sendFirmware(to: self.nodeService.node, revertCommand: type.wbBoardType == .st67w6x)
                //self.sendFirmware(to: self.nodeService.node, revertCommand: nodeService.node.type == .st67w6x)
            }
        } else {
            rebootInOtaMode(type: type, firmwareData: firmwareData)
        }
    }
}

private extension STM32WBFirmwareService {
  
    func rebootInOtaMode(type: FirmwareType, firmwareData: Data) {
        if let firstSector = type.firstSector,
           let numberOfSectors = type.numberOfSectors(with: UInt64(firmwareData.count)) {
            guard let reboot = reboot else { return }
            nodeService.bleService.write(data: Data.rebootToFlashCommand(sectorOffset: firstSector,
                                                                         numSector: numberOfSectors),
                                         characteristic: reboot.characteristic)
        }
    }

    func sendFirmware(data: Data, isWBA: Bool) {

        guard let upload = upload,
              let url = url,
              let callback = callback else { return }
        
        let mtu = (isWBA) ? min(240, nodeService.node.mtu) : nodeService.node.mtu // need to do this because when negociating the MTU, the WBA pretends to be able to receive 248 bytes while it doesn't handle them well

        STBlueSDK.log(text: "[Firmware upgrade] CHUNK LENGTH --> \(mtu)")

        self.nodeService.bleService.write(data: data,
                                          mtu: mtu,
                                          characteristic: upload.characteristic,
                                          writeDelay: STM32WBFirmwareService.writeDelay) { bytes, totalBytes in
            callback.progress(url, bytes, totalBytes)
        }
    }

    func sendFirmware(to node: Node, revertCommand: Bool) {
        self.nodeService.update(node: node)

        self.control = nodeService.node.characteristics.characteristic(with: STM32WBOtaControlFeature.self)
        self.upload = nodeService.node.characteristics.characteristic(with: STM32WBOtaUploadFeature.self)
        self.willReboot = nodeService.node.characteristics.characteristic(with: STM32WBOtaWillRebootFeature.self)

        BlueManager.shared.discoveryStop()

        guard let willReboot = willReboot else { return }

        BlueManager.shared.enableNofitications(for: node, characteristic: willReboot.characteristic)
        
        STM32WBFirmwareService.writeDelay = (firmwareType?.mustWaitForConfirmation == true) ? 0.015 : 0.001

        guard let firmwareType = firmwareType,
              let data = firmwareData,
              let startCommand = Data.startUpload(type: firmwareType, revertCommand: revertCommand, fileLength: firmwareData?.count) else { return }
        
        guard let control = control else {
            STBlueSDK.log(text: "[Firmware upgrade] - No upload characteristic found")
            if let url = self.url,
               let callback = self.callback {
                callback.completion(url, .trasmissionError)
            }
            return
        }

        nodeService.bleService.write(data: startCommand,
                                     characteristic: control.characteristic)

        if(!firmwareType.mustWaitForConfirmation) {
            
            Thread.sleep(forTimeInterval: STM32WBFirmwareService.writeDelay)
            sendFirmware(data: data, isWBA: false)
            
            let finishCommand = Data.uploadFinished()

            nodeService.bleService.write(data: finishCommand,
                                         characteristic: control.characteristic)
        }
    }
}

extension STM32WBFirmwareService: BlueDelegate {

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {

    }
    
    func manager(_ manager: BlueManager, didDiscover node: Node) {
        if node.isOTA() {
            //               node.address == self.nodeService.node.otaAddress {
            // STEP 4. CONNECT TO NODE
            manager.connect(node)
        }
    }

    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {

    }

    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        if node.state == .disconnected {
            // STEP 3.: SEARCH REBOOTED BOARD IN OTA MODE
            if !node.isOTA() {
                BlueManager.shared.discoveryStart(STM32WBFirmwareService.discoveryTimeout)
            }
        } else if node.state == .connected {
            // STEP 5. SEND START UPLOAD COMMAND

            self.sendFirmware(to: node, revertCommand: false)
        }
    }

    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        if let feature = feature as? STM32WBOtaWillRebootFeature,
           let willReboot = feature.sample?.data,
           willReboot,
           let callback = callback,
           let url = self.url {
            callback.completion(url, nil)
            
        }
        writeQueue.async {
            if(self.firmwareType?.mustWaitForConfirmation == true) {
                let value = self.willReboot?.characteristic.value
                if(value != nil && !value!.isEmpty) {
                    switch(value![0]) {
                    case 0x02:
                        Thread.sleep(forTimeInterval: STM32WBFirmwareService.writeDelay)
                        self.sendFirmware(data: self.firmwareData!, isWBA: (node.type.family == NodeFamily.wbaFamily || node.type == .nucleoWB0X))
                        let finishCommand = Data.uploadFinished()
                        self.nodeService.bleService.write(data: finishCommand,characteristic: self.control!.characteristic)
                    case 0x03: break
                    default: break
                    }
                }
            }
        }
    }

    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {

    }
}

//
//  FirmwareServiceFactory.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum FirmwareUpgradeError: Error {
    case corruptedFile
    case trasmissionError
    case invalidFwFile
    case unsupportedOperation
    case unknownError
}

public typealias FirmwareUpgradeCompletion = (_ url: URL, _ error: FirmwareUpgradeError?) -> Void
public typealias FirmwareUpgradeProgress = (_ url: URL, _ bytes: Int, _ totalBytes: Int) -> Void

public typealias FirmwareVersionCompletion = (_ version: FirmwareVersion?) -> Void

public protocol FirmwareUpgradeCallback {

    var completion: FirmwareUpgradeCompletion { get set }
    var progress: FirmwareUpgradeProgress { get set }

}

public struct DefaultFirmwareUpgradeCallback: FirmwareUpgradeCallback {
    public var completion: FirmwareUpgradeCompletion
    public var progress: FirmwareUpgradeProgress

    public init(completion: @escaping FirmwareUpgradeCompletion, progress: @escaping FirmwareUpgradeProgress) {
        self.completion = completion
        self.progress = progress
    }
}

public protocol FirmwareService {

    func currentVersion(_ completion: @escaping FirmwareVersionCompletion)
    func upgradeFirmware(with url: URL, type: FirmwareType, callback: FirmwareUpgradeCallback)

    func startLoading(with url: URL, type: FirmwareType, firmwareData: Data, callback: FirmwareUpgradeCallback)

}

public struct FirmwareServiceFactory {
    
    static public func type(for nodeService: NodeService) -> FirmwareServiceType {
        
        if nodeService.node.characteristics.characteristic(with: STM32WBRebootOtaModeFeature.self) != nil ||
            nodeService.node.characteristics.characteristic(with: STM32WBOtaUploadFeature.self) != nil {
            return .stm32
        } else if nodeService.node.characteristics.first(with: BlueNRGOtaMemoryInfoFeature.self) as? BlueNRGOtaMemoryInfoFeature != nil,
                  nodeService.node.characteristics.first(with: BlueNRGOtaSettingsFeature.self) as? BlueNRGOtaSettingsFeature != nil,
                  nodeService.node.characteristics.first(with: BlueNRGOtaDataTransferFeature.self) as? BlueNRGOtaDataTransferFeature  != nil,
                  nodeService.node.characteristics.first(with: BlueNRGOtaAckFeature.self) as? BlueNRGOtaAckFeature  != nil {
            return .blueNrg
        } else if nodeService.debugConsole != nil {
            return .debugConsole
        }
        
        return .unknown
    }

    static public func firmwareService(with nodeService: NodeService, catalog: Catalog, currentVersion: FirmwareVersion?) -> FirmwareService? {

        if let stm32FirmwareService = STM32WBFirmwareService(with: nodeService) {
            return stm32FirmwareService
        }

        if let nrgFirmwareService = BlueNRGFirmwareService(with: nodeService) {
            return nrgFirmwareService
        }

        guard nodeService.debugConsole != nil else { return nil }

        let advertiseBleFirmwareId = nodeService.node.bleFirmwareVersion
        var fastFota = false

        for firmware in catalog.blueStSdkV2 {
            if let boardType = firmware.boardType,
               let bleVersionId = firmware.bleVersionId,
               let fota = firmware.fota,
               nodeService.node.type == boardType,
               advertiseBleFirmwareId == bleVersionId,
               fota.type == .fast {
                fastFota = true
                break
            }
        }

        switch nodeService.node.type {
        case .sensorTileBox:
            if FirmwareServiceFactory.stBoxHasNewFwUpgrade(version: currentVersion) {
                return DebugConsoleFirmwareService(nodeService: nodeService,
                                                   packageDelay: 15,
                                                   fastFota: false,
                                                   resume: true)
            } else {
                return DebugConsoleFirmwareService(nodeService: nodeService,
                                                   packageDelay: 30,
                                                   fastFota: fastFota,
                                                   resume: false)
            }
        case .nucleo,
                .nucleoF401RE,
                .nucleoL476RG,
                .nucleoF446RE,
                .stWinBox,
                .stWinBoxB,
                .blueCoin,
                .sensorTile,
                .stEvalBCN002V1,
                .stEvalSTWINKIT1,
                .stEvalSTWINKT1B,
                .sensorTileBoxPro,
                .sensorTileBoxProB,
                .bL475eIot01A:
                //.proteus:
            return DebugConsoleFirmwareService(nodeService: nodeService,
                                               fastFota: fastFota,
                                               resume: false)
        default:
            return nil;
        }
    }

}

private extension FirmwareServiceFactory {
    static func stBoxHasNewFwUpgrade(version: FirmwareVersion?) -> Bool {
        guard let version = version else { return false }

        let compareVersion = version.compare(to: FirmwareVersion(major: 3, minor: 0, patch: 15))
        return compareVersion == .orderedSame || compareVersion == .orderedDescending
    }
}

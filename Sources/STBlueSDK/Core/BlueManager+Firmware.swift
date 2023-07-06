//
//  BlueManager+Firmware.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension BlueManager {

    func firmwareUpgrade(for node: Node,
                         type: FirmwareType = FirmwareType.application(board: .other),
                         url: URL,
                         catalog: Catalog,
                         callback: FirmwareUpgradeCallback) {

        guard let nodeSerice = nodeServices.nodeService(with: node) else { return }

        if firmwareService == nil {
            firmwareService = FirmwareServiceFactory.firmwareService(with: nodeSerice, catalog: catalog, currentVersion: nil)
        }

        firmwareService?.upgradeFirmware(with: url,
                                         type: type,
                                         callback: DefaultFirmwareUpgradeCallback(completion: { [weak self] url, error in

            guard let self = self else { return }

            self.firmwareService = nil
            callback.completion(url, error)
        }, progress: { url, bytes, totalBytes in
            callback.progress(url, bytes, totalBytes)
        }))
    }
    
    func firmwareServiceType(for node: Node) -> FirmwareServiceType {
        
        guard let nodeSerice = nodeServices.nodeService(with: node) else { return .unknown}
        
        return FirmwareServiceFactory.type(for: nodeSerice)
        
    }
    
    func firmwareCurrentVersion(for node: Node, catalog: Catalog?, completion: @escaping FirmwareVersionCompletion) {
        
        guard let nodeSerice = nodeServices.nodeService(with: node),
        let catalog = catalog else { return }
        
        if firmwareService == nil {
            firmwareService = FirmwareServiceFactory.firmwareService(with: nodeSerice, catalog: catalog, currentVersion: nil)
        }
        
        BlueManager.shared.firmwareService?.currentVersion(completion)
    }
}

//
//  BlueManager+Catalog.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STCore

public extension BlueManager {

    func clearDB() {
        if let catalogService: CatalogService = Resolver.shared.resolve() {
            catalogService.clear()
        }
    }

    func updateCustomCatalog(with url: URL, completion: @escaping (Catalog?, STError?) -> Void) {

        guard let data = try? Data(contentsOf: url) else {
            completion(nil, .dataNotValid)
            return
        }

        guard let catalog = try? JSONDecoder().decode(Catalog.self, from: data),
              let customFirmware = catalog.blueStSdkV2.first(where: { $0.bleVersionId == 0xff } ) else {
            completion(nil, .dataNotValid)
            return
        }

        if let catalogService: CatalogService = Resolver.shared.resolve() {
            catalogService.add(customFirmware: customFirmware)
            completion(catalog, nil)
        }
    }

    func updateCustomDtmi(with url: URL, completion: @escaping ([PnpLContent], STError?) -> Void) {
        guard let data = try? Data(contentsOf: url) else {
            completion([], .dataNotValid)
            return
        }

        guard let dtmi = try? JSONDecoder().decode([PnpLContent].self, from: data) else {
            completion([], .dataNotValid)
            return
        }

        if let catalogService: CatalogService = Resolver.shared.resolve() {
            catalogService.storeCustomDtmiContents(dtmi)
            completion(dtmi, nil)
        }
    }

    func updateCatalog(with environment: Environment, completion: @escaping (Catalog?, STError?) -> Void) {
        
        // TODO: check the version
        
        URLSession.shared.getCatalog(with: environment) { [weak self] result in
            guard let self = self else { return }
            
            switch result {
            case .success(let catalog):
                if let catalogService: CatalogService = Resolver.shared.resolve() {
                    catalogService.storeCatalog(catalog)
                    completion(catalog, nil)
                }
            case .failure(let error):
                if let catalogService: CatalogService = Resolver.shared.resolve() {
                    completion(catalogService.catalog, error)
                }
            }
        }
    }

    func updateDtmi(with environment: Environment, firmware: Firmware, completion: @escaping ([PnpLContent], STError?) -> Void) {
        URLSession.shared.getDtmi(with: environment, firmware: firmware) { result in
            switch result {
            case .success(let dtmiContents):
                if let catalogService: CatalogService = Resolver.shared.resolve() {
                    catalogService.storeDtmiContents(dtmiContents, for: firmware)
                    completion(dtmiContents, nil)
                }
            case .failure(let error):
                completion([], error)
            }
        }
    }
    
    func add(customFirmwareToCatalog firmware: Firmware)  -> Catalog? {
        if let catalogService: CatalogService = Resolver.shared.resolve() {
            return catalogService.add(customFirmware: firmware)
        }

        return nil
    }
    
    func removeCustomFirmware(for node: Node) -> Catalog? {
        if let catalogService: CatalogService = Resolver.shared.resolve() {
            return catalogService.removeCustomFirmware(for: node.type)
        }

        return nil
    }

    func ignoreFirmwareUpdate(_ firmware: Firmware, deviceTag: String) {
        if let catalogService: CatalogService = Resolver.shared.resolve() {
            catalogService.ignoreFirmwareUpdate(firmware, deviceTag: deviceTag)
        }
    }

    func isFirmwareUpdateIgnored(_ firmware: Firmware, deviceTag: String) -> Bool {
        if let catalogService: CatalogService = Resolver.shared.resolve() {
            return catalogService.isFirmwareUpdateIgnored(firmware, deviceTag: deviceTag)
        }

        return false
    }

    func dtmi(for node: Node) -> FirmwareDtmi? {
        if let catalogService: CatalogService = Resolver.shared.resolve(),
           let firmware = catalogService.catalog?.v2Firmware(with: node.deviceId.longHex,
                                                            firmwareId: UInt32(node.bleFirmwareVersion).longHex) {
            
            if(catalogService.dtmi != nil) {
                return catalogService.dtmi?.firmware == firmware ? catalogService.dtmi : nil
            } else if(catalogService.customDtmi != nil){
                if let customDtmi = catalogService.customDtmi?.contents {
                    return FirmwareDtmi(firmware: firmware, contents: customDtmi)
                }
            }
        }

        return nil
    }
}

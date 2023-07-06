//
//  CatalogService.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum CatalogType {
    case standard
    case custom
}

public struct FirmwareDtmi {
    public let firmware: Firmware
    public let contents: [PnpLContent]

    public init(firmware: Firmware, contents: [PnpLContent]) {
        self.firmware = firmware
        self.contents = contents
    }
}


extension FirmwareDtmi: Codable {
    public enum CodingKeys: String, CodingKey {
        case firmware
        case contents
    }
}

public struct CustomDtmi {
    public let contents: [PnpLContent]

    public init(contents: [PnpLContent]) {
        self.contents = contents
    }
}


extension CustomDtmi: Codable {
    public enum CodingKeys: String, CodingKey {
        case contents
    }
}


public protocol CatalogService {

    var catalog: Catalog? { get }
    var dtmi: FirmwareDtmi? { get }
    var customDtmi: CustomDtmi? { get }

    func storeCatalog(_ catalog: Catalog?) -> Catalog?
    func storeDtmiContents(_ contents: [PnpLContent], for firmware: Firmware) -> FirmwareDtmi?
    func storeCustomDtmiContents(_ contents: [PnpLContent]) -> CustomDtmi?
    func add(customFirmware firmware: Firmware) -> Catalog?
    func removeCustomFirmware(for boardType: NodeType) -> Catalog?
    func ignoreFirmwareUpdate(_ firmware: Firmware, deviceTag: String)
    func isFirmwareUpdateIgnored(_ firmware: Firmware, deviceTag: String) -> Bool
    func clear()

}

public class CatalogServiceCore {
    
    private static let customFirmwareId = "0xff"
    private static let catalogKey = "BlueSTCatalogKey"
    private static let customFirmwaresKey = "BlueSTCustomFirmwaresKey"
    private static let ignoredFirmwaresKey = "BlueSTIgnoredFirmwaresKey"
    private static let customDtmiKey = "BlueSTCustomDtmiKey"
    
    var internalCatalog: Catalog?
    
    public var dtmi: FirmwareDtmi?
    public var customDtmi: CustomDtmi?

    public var catalog: Catalog? {
        guard var fullCatalog = internalCatalog else { return nil }
        fullCatalog.add(customFirmwares: customFirmwares)
        
        return fullCatalog
    }

    var firmwareUpdateIgnored: [String]
    var customFirmwares: [Firmware] = [Firmware]()
    var customDtmiElements: PnPLikeDtmiElements = PnPLikeDtmiElements()
    
    public init() {
        firmwareUpdateIgnored = [String]()

        if let savedIgnoredFirmwares = UserDefaults.standard.object(forKey: CatalogServiceCore.ignoredFirmwaresKey) as? [String] {
            firmwareUpdateIgnored.append(contentsOf: savedIgnoredFirmwares)
        }

        internalCatalog = loadCurrentCatalog()
        customFirmwares = loadCustomFirmwares()
        customDtmiElements = PnPLikeDtmiElements()
        customDtmi = loadCustomDtmi()
    }
}

extension CatalogServiceCore: CatalogService {
    
    @discardableResult
    public func storeCatalog(_ catalog: Catalog?) -> Catalog? {

        if internalCatalog?.checksum == catalog?.checksum {
            return self.catalog
        }

        let userDefaults = UserDefaults.standard
        
        guard let catalog = catalog else {
            userDefaults.removeObject(forKey: CatalogServiceCore.catalogKey)
            userDefaults.synchronize()
            return self.catalog
        }
    
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(catalog) {
            userDefaults.set(encoded, forKey: CatalogServiceCore.catalogKey)
            userDefaults.synchronize()
            internalCatalog = catalog
            return self.catalog
        }
        
        return nil
    }

    @discardableResult
    public func storeDtmiContents(_ contents: [PnpLContent], for firmware: Firmware) -> FirmwareDtmi? {

        self.dtmi = FirmwareDtmi(firmware: firmware, contents: contents)

        guard let data = try? JSONEncoder().encode(FirmwareDtmi(firmware: firmware, contents: contents)) else {
            STBlueSDK.log(text: "Error")
            return self.dtmi
        }

        guard let dtmi = try? JSONDecoder().decode(FirmwareDtmi.self, from: data) else {
            STBlueSDK.log(text: "Error")
            return self.dtmi
        }

        self.dtmi = dtmi

        return self.dtmi
    }
    
    
    @discardableResult
    public func storeCustomDtmiContents(_ contents: [PnpLContent]) -> CustomDtmi? {

        self.customDtmi = CustomDtmi(contents: contents)

        let userDefaults = UserDefaults.standard

        userDefaults.removeObject(forKey: CatalogServiceCore.customDtmiKey)
                
        guard let data = try? JSONEncoder().encode(self.customDtmi) else {
            STBlueSDK.log(text: "Error")
            return self.customDtmi
        }
        
        userDefaults.set(data, forKey: CatalogServiceCore.customDtmiKey)
        userDefaults.synchronize()
        
        return self.customDtmi
    }
    
    
    @discardableResult
    public func add(customFirmware firmware: Firmware) -> Catalog? {
        if firmware.bleVersionIdHex.lowercased() != Self.customFirmwareId {
            return nil
        }
//        let firmwares = customFirmwares.filter { currentFirmware in
//            return currentFirmware.boardType == firmware.boardType
//        }
//
//        for current in firmwares {
//            if let index = customFirmwares.firstIndex(where: { $0.boardType == current.boardType }) {
//                customFirmwares.remove(at: index)
//            }
//        }
        
        if let index = customFirmwares.firstIndex(where: { $0.deviceId == firmware.deviceId && $0.bleVersionIdHex.lowercased() == Self.customFirmwareId }) {
            customFirmwares.remove(at: index)
        }
        
        customFirmwares.append(firmware)
        save()
        
        return catalog
    }
    
    public func removeCustomFirmware(for boardType: NodeType) -> Catalog? {
        let firmwares = customFirmwares.filter { currentFirmware in
            return currentFirmware.boardType == boardType
        }
        
        for current in firmwares {
            if let index = customFirmwares.firstIndex(where: { $0.boardType == current.boardType }) {
                customFirmwares.remove(at: index)
            }
        }
        
        save()
        
        return catalog
    }

    public func ignoreFirmwareUpdate(_ firmware: Firmware, deviceTag: String) {
        if !isFirmwareUpdateIgnored(firmware, deviceTag: deviceTag) {
            firmwareUpdateIgnored.append(firmware.uniqueIdentifier + "_\(deviceTag)")
            UserDefaults.standard.set(firmwareUpdateIgnored, forKey: CatalogServiceCore.ignoredFirmwaresKey)
        }
    }

    public func isFirmwareUpdateIgnored(_ firmware: Firmware, deviceTag: String) -> Bool {
        return firmwareUpdateIgnored.contains(firmware.uniqueIdentifier + "_\(deviceTag)")
    }

    public func clear() {
        customFirmwares.removeAll()
        dtmi = nil

        save()
    }
}

private extension CatalogServiceCore {
    
    func save() {
        let userDefaults = UserDefaults.standard
        
        let encoder = JSONEncoder()
        
        if let catalog = internalCatalog {
            if let encoded = try? encoder.encode(catalog) {
                userDefaults.set(encoded, forKey: CatalogServiceCore.catalogKey)
            }
        } else {
            userDefaults.removeObject(forKey: CatalogServiceCore.catalogKey)
        }
        
        if let encoded = try? encoder.encode(customFirmwares) {
            userDefaults.set(encoded, forKey: CatalogServiceCore.customFirmwaresKey)
        }
        
        userDefaults.synchronize()
    }
    
    func loadCurrentCatalog() -> Catalog? {
        let userDefaults = UserDefaults.standard
        
        let storedCatalog = userDefaults.object(forKey: CatalogServiceCore.catalogKey)
        
        if let storedCatalog = storedCatalog as? Data {
            let decoder = JSONDecoder()
            if let loadedCatalog = try? decoder.decode(Catalog.self, from: storedCatalog) {
                return loadedCatalog
            }
        }
        
        return nil
    }
    
    func loadCustomFirmwares() -> [Firmware] {
        let userDefaults = UserDefaults.standard
        
        let storedCustomFirmwares = userDefaults.object(forKey: CatalogServiceCore.customFirmwaresKey)
        
        if let storedCustomFirmwares = storedCustomFirmwares as? Data {
            let decoder = JSONDecoder()
            if let loadedCustomFirmwares = try? decoder.decode([Firmware].self, from: storedCustomFirmwares) {
                return loadedCustomFirmwares
            }
        }
        
        return []
    }
    
    func loadCustomDtmi() -> CustomDtmi? {
        let userDefaults = UserDefaults.standard
        
        let storedCustomDtmi = userDefaults.object(forKey: CatalogServiceCore.customDtmiKey)
        
        if let storedCustomDtmi = storedCustomDtmi as? Data {
            guard let customDtmi = try? JSONDecoder().decode(CustomDtmi.self, from: storedCustomDtmi) else {
                STBlueSDK.log(text: "Error")
                return nil
            }
            return customDtmi
        }
        
        return nil
    }
}

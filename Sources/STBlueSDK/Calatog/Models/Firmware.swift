//
//  Firmware.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct Firmware {
    public let deviceId: String
    public let bleVersionIdHex: String
    public let boardName: String
    public let version: String
    public let name: String
    public let dtmi: String?
    public let cloudApps: [CloudApp]?
    public let characteristics: [BleCharacteristic]?
    public let optionBytes: [OptionByte]?
    public let description: String?
    public let changelog: String?
    public let fota: FotaDetails?
    public let compatibleSensorAdapters: [Int]?
    public let extraExamplesFlow: [ExtraExampleFlow]?
    public let demoDecorator: DemoDecorator?
    public let maturity: Maturity?
}

extension Firmware: Codable {
    enum CodingKeys: String, CodingKey {
        case deviceId = "ble_dev_id"
        case bleVersionIdHex = "ble_fw_id"
        case boardName = "brd_name"
        case version = "fw_version"
        case name = "fw_name"
        case dtmi
        case cloudApps = "cloud_apps"
        case characteristics
        case optionBytes = "option_bytes"
        case description = "fw_desc"
        case changelog
        case fota
        case compatibleSensorAdapters = "compatible_sensor_adapters"
        case extraExamplesFlow = "extra_examples_flow"
        case demoDecorator = "demo_decorator"
        case maturity
    }
}

public extension Firmware {

    static let stAIotCraftIoTSystemsName = "AI-SSM"
    static let stAIotCraftIoTSystemsSupportedVersions = [
        "1.0.0"
    ]
    
    static let stAIotCraftName = "FP-SNS-DATALOG2_Datalog2"
    static let stAIotCraftSupportedVersions = [
        "3.1.0"
    ]

    var boardType: NodeType? {
        guard let deviceId = UInt8(deviceId.dropFirst(2), radix: 16) else { return nil }
        return NodeType(rawValue: deviceId)
    }

    var bleVersionId: Int? {
        return Int(bleVersionIdHex.dropFirst(2), radix: 16)
    }

    var fullName: String {
        boardName + " Running Fw: " + name + " v" + version
    }

    var compoundName: String {
        name + " v:" + version
    }

    var fileName: String {
        "\(name)v\(version)"
    }

    var url: URL? {
        guard let urlString = fota?.url,
        let url = URL(string: urlString) else { return nil }

        return url
    }

    var uniqueIdentifier: String {
        "\(name)_\(version)".lowercased()
    }
}

extension Firmware: Equatable {
    public static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.uniqueIdentifier == rhs.uniqueIdentifier
    }
}

public extension Array where Element == Firmware {
    var distintBoards: [Board] {
        map { Board(deviceId: $0.deviceId, name: $0.boardName, characteristics: nil) }.unique()
    }
}

public extension Array where Element == Firmware {
    var boardsWithCharacteristic: [Board] {
        map { Board(deviceId: $0.deviceId, name: $0.boardName, characteristics: $0.characteristics) }
    }
}

public extension Array where Element == CatalogBoard {
    var toBoard: [Board] {
        map { Board(deviceId: $0.bleDeviceId, name: $0.name, characteristics: nil) }.unique()
    }
}

public extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: Set<Iterator.Element> = []
        return filter { seen.insert($0).inserted }
    }
}

public struct Board {
    public let deviceId: String
    public let name: String
    public var variant: String? = nil
    public var boardPart: String? = nil
    public var friendlyName: String? = nil
    public var status: String? = nil
    public var description: String? = nil
    public var url: String? = nil
    public var datasheetsUrl: String? = nil
    public var videoId: String? = nil
    public var wikiUrl: String? = nil
    public var releaseDate: String? = nil
    public var characteristics: [BleCharacteristic]?

    public var type: NodeType? {
        guard let boardId = UInt8(deviceId.dropFirst(2), radix: 16) else { return nil }
        //print("boardId=\(boardId)")
        return NodeType(rawValue: boardId)
    }
}

extension Board: Hashable {
    public var hashValue: String { return self.deviceId }
    
    public static func == (lhs: Board, rhs: Board) -> Bool {
        return false
    }
    
    public func hash(into hasher: inout Hasher) {
        hasher.combine(deviceId)
    }
}

public struct CatalogBoard {
    public let bleDeviceId: String
    public let nfcDeviceId: String?
    public let usbDeviceId: String?
    public let uniqueDeviceId: Int?
    public let name: String
    public let variant: String?
    public let boardPart: String?
    public let friendlyName: String
    public let status: String
    public let description: String?
    public let documentationUrl: String?
    public let orderUrl: String?
    public let videoUrl: String?
    public let wikiUrl: String?
    public let releaseDate: String?
//
//    public var type: NodeType? {
//        guard let boardId = UInt8(bleDeviceId.dropFirst(2), radix: 16) else { return nil }
//        return NodeType(rawValue: boardId)
//    }
}

extension CatalogBoard: Codable {
    enum CodingKeys: String, CodingKey {
        case bleDeviceId = "ble_dev_id"
        case nfcDeviceId = "nfc_dev_id"
        case usbDeviceId = "usb_dev_id"
        case uniqueDeviceId = "unique_dev_id"
        case name = "brd_name"
        case variant = "brd_variant"
        case boardPart = "brd_part"
        case friendlyName = "friendly_name"
        case status
        case description
        case documentationUrl = "documentation_url"
        case orderUrl = "order_url"
        case videoUrl = "video_url"
        case wikiUrl = "wiki_url"
        case releaseDate = "release_date"
    }
}

extension String {
    var nodeType: NodeType? {
        guard let boardId = UInt8(dropFirst(2), radix: 16) else { return nil }
        return NodeType(rawValue: boardId)
    }
}

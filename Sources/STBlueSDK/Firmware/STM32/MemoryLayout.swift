//
//  MemoryLayout.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum BoardFamily {
    case wba
    case wb55
    case wb15
    case other
}

public enum FirmwareType {
    case undefined
    case application(board: BoardFamily)
    case radio(board: BoardFamily)
    case custom(startSector: UInt8?, numberOfSectors: UInt8, sectorSize: UInt16)

    static let validRange = UInt8(0x07)..<UInt8(0x80)
    
    public var mustWaitForConfirmation: Bool {
        switch self {
            case .application(let board), .radio(let board):
                return board == BoardFamily.wba
            default:
                return false
        }
    }

    public var layout: FirmwareLayout {
        switch self {
        case .undefined:
            return FirmwareLayout(startSector: 0x00, numberOfSectors: 0x00, sectorSize: 0x0000)
        case .application(let board):
            switch board {
            case .wb55:
                return FirmwareLayout(startSector: 0x07, numberOfSectors: 0x7F, sectorSize:0x1000)
            case .wb15:
                return FirmwareLayout(startSector: 0x0E, numberOfSectors: 0x24, sectorSize:0x800)
            case .wba:
                return FirmwareLayout(startSector: 0x3E, numberOfSectors: 0x3F, sectorSize:0x2000)
            case .other:
                return FirmwareType.undefined.layout
            }
        case .radio(let board):
            switch board {
            case .wb55:
                return FirmwareLayout(startSector: 0x0F, numberOfSectors: 0x7F, sectorSize:0x1000)
            case .wb15:
                return FirmwareLayout(startSector: 0x0E, numberOfSectors: 0x3C, sectorSize:0x800)
            case .wba:
                return FirmwareLayout(startSector: 0x7B, numberOfSectors: 0x3F, sectorSize:0x2000)
            case .other:
                return FirmwareType.undefined.layout
            }
        case .custom(let startSector, let numberOfSectors, let sectorSize):
            return FirmwareLayout(startSector: startSector, numberOfSectors: numberOfSectors, sectorSize:sectorSize)
        }
    }

    public var firstSector: UInt8? {
        
        guard let start = layout.startSector else { return nil }
        
        return FirmwareType.validRange.contains(start) ? start : nil
    }

    var firstSectorToFlash: UInt32? {
        if let firstSector = firstSector {
            return UInt32(firstSector) * UInt32(sectorSize)
        }

        return nil
    }

    var sectorSize: UInt16 {
        layout.sectorSize
    }

    func numberOfSectors(with fileSize: UInt64) -> UInt8? {
        let sectorsForFileSize: Int64 = (Int64(fileSize) + Int64(sectorSize - 1)) / Int64(sectorSize)
        let maxSectorSelected: Int = Int(layout.numberOfSectors)

        return UInt8(sectorsForFileSize < maxSectorSelected ? Int(sectorsForFileSize) : maxSectorSelected)
    }
}

public struct FirmwareLayout {
    public let startSector: UInt8?
    public let numberOfSectors: UInt8
    public let sectorSize: UInt16
}

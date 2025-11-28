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

public enum WbBoardType {
    case wba5
    case wb55
    case wb15
    case wb09
    case wba6
    case wba2
    case st67w6x
    case other
}

public enum FirmwareType {
    case undefined
    case application(board: WbBoardType)
    case radio(board: WbBoardType)

    static let validRange = UInt8(0x07)..<UInt8(0x81)
    
    public var mustWaitForConfirmation: Bool {
        switch self {
            case .application(let board), .radio(let board):
            return (board == WbBoardType.wba5) || (board == WbBoardType.wb09) || (board == WbBoardType.wba6) || (board == WbBoardType.wba2) || (board == WbBoardType.st67w6x)
            default:
                return false
        }
    }
    
    public var wbBoardType: WbBoardType {
        switch self {
        case .application(board: let board), .radio(board: let board):
            return board
        case .undefined:
            return .other
        }
    }

    public var layout: FirmwareLayout {
        switch self {
        case .undefined:
            return FirmwareLayout(startSector: 0x00, numberOfSectors: 0x00, sectorSize: 0x0000)
        case .application(let board):
            switch board {
            case .wb09:
                return FirmwareLayout(startSector: 0x7F, numberOfSectors: 0x100, sectorSize:0x800)
            case .wb55:
                return FirmwareLayout(startSector: 0x07, numberOfSectors: 0xD0, sectorSize:0x1000)
            case .wb15:
                return FirmwareLayout(startSector: 0x0E, numberOfSectors: 0x44, sectorSize:0x800)
            case .wba5:
                return FirmwareLayout(startSector: 0x40, numberOfSectors: 0x3D, sectorSize:0x2000)
            case .wba6:
                return FirmwareLayout(startSector: 0x80, numberOfSectors: 0x7A, sectorSize:0x2000)
            case .wba2:
                return FirmwareLayout(startSector: 0x40, numberOfSectors: 0x3A, sectorSize:0x1000)
            case .st67w6x:
                //Not Used
                return FirmwareLayout(startSector: 0x40, numberOfSectors: 0x3D, sectorSize:0x2000)
            case .other:
                return FirmwareType.undefined.layout
            }
        case .radio(let board):
            switch board {
            case .wb09:
                return FirmwareLayout(startSector: 0xFC, numberOfSectors: 0x100, sectorSize:0x800)
            case .wb55:
                return FirmwareLayout(startSector: 0x11, numberOfSectors: 0xD0, sectorSize:0x1000)
            case .wb15:
                return FirmwareLayout(startSector: 0x0E, numberOfSectors: 0x44, sectorSize:0x800)
            case .wba5:
                return FirmwareLayout(startSector: 0x7D, numberOfSectors: 0x3D, sectorSize:0x2000)
            case .wba6:
                return  FirmwareLayout(startSector: 0xFA, numberOfSectors: 0x7A, sectorSize:0x2000)
            case .wba2:
                return FirmwareLayout(startSector: 0x7A, numberOfSectors: 0x3A, sectorSize:0x1000)
            case .st67w6x:
                //Not Used
                return FirmwareLayout(startSector: 0x7D, numberOfSectors: 0x3D, sectorSize:0x2000)
            case .other:
                return FirmwareType.undefined.layout
            }
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
    public let numberOfSectors: UInt16
    public let sectorSize: UInt16
}

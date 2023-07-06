//
//  Data+NumberConversion.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum Endian {
    case little
    case big
}

public extension Data {

    func extractNumber<N: Numeric>(fromOffset: Int) -> N {
        let range: ClosedRange<Index> = fromOffset...(fromOffset + MemoryLayout<N>.size)
        let subdata = subdata(in: range.lowerBound..<range.upperBound)

        return subdata.withUnsafeBytes { $0.load(as: N.self) }
    }

    func extractUInt8(fromOffset: Int) -> UInt8 {
        extractNumber(fromOffset: fromOffset)
    }

    func extractInt8(fromOffset: Int) -> Int8 {
        extractNumber(fromOffset: fromOffset)
    }

    func extractUInt16(fromOffset: Int, endian: Endian = .little) -> UInt16 {

        let value: UInt16 = extractNumber(fromOffset: fromOffset)

        return endian == .little ? value : value.bigEndian
    }

    func extractInt16(fromOffset: Int, endian: Endian = .little) -> Int16 {
        let value: Int16 = extractNumber(fromOffset: fromOffset)

        return endian == .little ? value : value.bigEndian
    }

    func extractUInt32(fromOffset: Int, endian: Endian = .little) -> UInt32 {
        let value: UInt32 = extractNumber(fromOffset: fromOffset)

        return endian == .little ? value : value.bigEndian
    }

    func extractInt32(fromOffset: Int, endian: Endian = .little) -> Int32 {
        let value: Int32 = extractNumber(fromOffset: fromOffset)

        return endian == .little ? value : value.bigEndian
    }

    func extractFloat(fromOffset: Int, endian: Endian = .little) -> Float {
        extractNumber(fromOffset: fromOffset)
    }
}

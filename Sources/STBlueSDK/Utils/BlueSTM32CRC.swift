//
//  BlueSTM32CRC.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation


/// Compute the crc with the same algorithm/polynomial used inside the STM32.
public class BlueSTM32CRC {

    private static let INITIAL_VALUE: UInt32 = 0xffffffff;
    private static let CRC_TABLE: [UInt32] = [ // Nibble lookup table for 0x04C11DB7 polynomial
    0x00000000, 0x04C11DB7, 0x09823B6E, 0x0D4326D9, 0x130476DC, 0x17C56B6B, 0x1A864DB2, 0x1E475005,
    0x2608EDB8, 0x22C9F00F, 0x2F8AD6D6, 0x2B4BCB61, 0x350C9B64, 0x31CD86D3, 0x3C8EA00A, 0x384FBDBD];

    public var crcValue: UInt32 = INITIAL_VALUE;

    private static func crc32fast(_ crc: UInt32,_ newData: UInt32) -> UInt32 {
        var newCrc = crc ^ newData; // Apply all 32-bits

        // Process 32-bits, 4 at a time, or 8 rounds

         // Assumes 32-bit reg, masking index to 4-bits
        newCrc = (newCrc << 4) ^ BlueSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTM32CRC.CRC_TABLE[Int(newCrc >> 28)]; //  0x04C11DB7 Polynomial used in STM32
        newCrc = (newCrc << 4) ^ BlueSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];
        newCrc = (newCrc << 4) ^ BlueSTM32CRC.CRC_TABLE[Int(newCrc >> 28)];

        return newCrc;
    }


    /// update the CRC value with the new data
    /// Node: we use world of 4 bytes to compute the crc, if the sequence has a length
    /// that is not a multiple of 4 bytes the last bytes will be ingored.
    /// - Parameter data: new bytes to add at the crc computation
    public func upgrade(_ data: Data) {
        data.withUnsafeBytes{ (ptr: UnsafeRawBufferPointer) in
            let uint32Ptr = ptr.bindMemory(to: UInt32.self)
            uint32Ptr.forEach{
                crcValue = BlueSTM32CRC.crc32fast(crcValue, $0)
            }
        }
    }

    /// reset the crc value to the initial value
    public func reset() {
        crcValue = BlueSTM32CRC.INITIAL_VALUE;
    }

    /// utility function to compute the crc of a specific data
    ///
    /// - Parameter data: sequence of byte used for computing the crc
    /// - Returns: crc for the data sequence
    public static func getCrc(_ data: Data) -> UInt32 {
        let length = data.count - data.count % 4
        let tempData = data[0..<length]
        let crcEngine = BlueSTM32CRC()
        crcEngine.upgrade(tempData)
        return crcEngine.crcValue
    }
}

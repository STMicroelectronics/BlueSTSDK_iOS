//
//  BytesUtils.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension UInt8 {
    var hex: String {
        String(format: "%02x", self).lowercased()
    }

    var longHex: String {
        String(format: "0x%02x", self).lowercased()
    }
}

public extension UInt32 {
    var hex: String {
        String(format: "%02x", self).lowercased()
    }

    var longHex: String {
        String(format: "0x%02x", self).lowercased()
    }
}

public extension Int {
    var longHex: String {
        String(format: "0x%02x", self).lowercased()
    }
}

public extension Int16 {
    var bytes: [UInt8] {
        let array = Array(withUnsafeBytes(of: self.littleEndian) { Data($0) })
        return array
    }
    
    var reversedBytes: [UInt8] {
        let array = Array(withUnsafeBytes(of: self.littleEndian) { Data($0) })
        return array.reversed()
    }

}

public extension Data {
    var hex: String {
        map { $0.hex }.joined()
    }
    
    var bytes: [UInt8] {
        [UInt8](self)
    }

}

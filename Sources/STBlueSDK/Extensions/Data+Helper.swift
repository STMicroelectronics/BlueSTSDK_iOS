//
//  Data+Helper.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension Data {
    func subdata(in range: ClosedRange<Index>) -> Data {
        return subdata(in: range.lowerBound ..< range.upperBound + 1)
    }

    func swapData() -> Data {
        
        var mdata = self
        let count = count / MemoryLayout<Float>.size
        mdata.withUnsafeMutableBytes { i16ptr in
            for i in 0..<count {
                i16ptr[i] = i16ptr[i].byteSwapped
            }
        }
        return mdata
    }

    func chunks(_ size: Int) -> [Data] {
        return stride(from: 0, to: count, by: size).map { (startIndex) -> Data in
            let endIndex = (startIndex.advanced(by: size) > count) ? count : startIndex + size
            return subdata(in: startIndex..<endIndex)
        }
    }

    var nullTerminated: Data {
        var data = self
        data.append(0)
        return data
    }
    
    var xor: UInt8 {
        get {
            reduce(UInt8(0)) { xorSum, value in xorSum ^ value }
        }
    }
}

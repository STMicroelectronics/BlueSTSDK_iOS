//
//  RawPnPLStreamEntry.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct RawPnPLStreamEntry {
    public let name: String
    public let format: RawPnPLFormat
    public let unit: String?
    public let max: Double?
    public let min: Double?
    public let value: [Any]
    public let valueFloat: [Float]
    public let streamId: UInt8
    public let elements: Int?
    public let channels: Int?
    public let multiplyFactor: Double?
    public let odr: Int?
}

public extension Array where Element == RawPnPLStreamEntry {
    var description: String {
        var result = ""

        if !isEmpty {
            //All the Entries will have the same StreamID
            result += "StreamID= \(self[0].streamId)\n"
        }

        for entry in self {

            if let enumLabel = entry.value.first as? RawPnPLEnumLabel {
                result += "\(entry.name) [\(enumLabel.label): \(enumLabel.value)] "
            } else {
                if entry.channels == 1 {
                    if entry.multiplyFactor != nil {
                        result += "\(entry.name) [\(entry.value)] "
                    } else {
                        result += "\(entry.name) [\(entry.valueFloat)] "
                    }
                } else {
                    if entry.multiplyFactor != nil {
                        result += "\(entry.name) [\(entry.valueFloat.splitByChunk(entry.channels!))] "
                    } else {
                        result += "\(entry.name) [\(entry.value.splitByChunk(entry.channels!))] "
                    }
                }
            }
            if let unit = entry.unit {
                result += "\(unit) "
            }
            if let min = entry.min {
                result += "{min = \(min)} "
            }
            if let max = entry.max {
                result += "{max = \(max)} "
            }
            result += "\n"
        }

        return result
    }
}

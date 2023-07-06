//
//  FirmwareVersion.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct FirmwareVersion {

    private static let validPattern = "(.*)_(.*)_(\\d+)\\.(\\d+)\\.(\\d+)"

    public let name: String?
    public let mcuType: String?
    public let major: Int
    public let minor: Int
    public let patch: Int

    public var stringValue: String {
        "\(major).\(minor).\(patch)"
    }

    init(name: String? = nil, mcuType: String? = nil, major: Int, minor: Int, patch: Int) {
        self.name = name
        self.mcuType = mcuType
        self.major = major
        self.minor = minor
        self.patch = patch
    }

    init?(with version: String) {

        guard version ~= FirmwareVersion.validPattern else { return nil }

        let regex = NSRegularExpression(FirmwareVersion.validPattern)

        let matches = regex.matches(in: version,
                                    options: .reportProgress,
                                    range: NSRange(location: 0, length: version.utf16.count))

        if matches.isEmpty {
            return nil
        }

        for match in matches {
            if match.numberOfRanges != 6 {
                return nil
            }

            mcuType = version[match.range(at: 1)]
            name = version[match.range(at: 2)]
            major = Int(version[match.range(at: 3)]) ?? 0
            minor = Int(version[match.range(at: 4)]) ?? 0
            patch = Int(version[match.range(at: 5)]) ?? 0

            return
        }

        return nil
    }

    public func compare(to version: FirmwareVersion) -> ComparisonResult {
        var diff = major - version.major

        if diff != 0 {
            return diff > 0 ? .orderedDescending : .orderedAscending
        }

        diff = minor - version.minor

        if diff != 0 {
            return diff > 0 ? .orderedDescending : .orderedAscending
        }

        diff = patch - version.patch

        if diff != 0 {
            return diff > 0 ? .orderedDescending : .orderedAscending
        }

        return .orderedSame
    }

}

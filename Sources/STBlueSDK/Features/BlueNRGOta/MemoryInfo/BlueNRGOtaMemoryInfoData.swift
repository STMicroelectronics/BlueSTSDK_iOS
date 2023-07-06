//
//  BlueNRGOtaMemoryInfoData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct BlueNRGOtaMemoryInfoData {
    
    public let flashLowerBound: FeatureField<UInt32>
    public let flashUpperBound: FeatureField<UInt32>
    public let versionMajor: FeatureField<UInt8>
    public let versionMinor: FeatureField<UInt8>
    
    init(with data: Data, offset: Int) {
        let lowerBound = data.extractUInt32(fromOffset: offset, endian: .big)
        let upperBound = data.extractUInt32(fromOffset: offset + 4, endian: .big)

        var versionMajor: UInt8 = 1
        var versionMinor: UInt8 = 0
        
        if data.count - offset > 9 {
            let rawVersion = data.extractUInt8(fromOffset: offset + 8)
            versionMajor =  rawVersion / 16
            versionMinor = rawVersion % 16
        }
        
        self.flashLowerBound = FeatureField<UInt32>(name: "Flash_LB",
                                                    uom: nil,
                                                    min: 0,
                                                    max: UInt32.max,
                                                    value: lowerBound)
        
        self.flashUpperBound = FeatureField<UInt32>(name: "Flash_UB",
                                                    uom: nil,
                                                    min: 0,
                                                    max: UInt32.max,
                                                    value: upperBound)
        
        self.versionMajor = FeatureField<UInt8>(name: "ProtocolVerMajor",
                                                uom: nil,
                                                min: 0,
                                                max: UInt8.max,
                                                value: versionMajor)
        
        self.versionMinor = FeatureField<UInt8>(name: "ProtocolVerMinor",
                                                uom: nil,
                                                min: 0,
                                                max: UInt8.max,
                                                value: versionMinor)
    }
    
}

extension BlueNRGOtaMemoryInfoData: Loggable {
    public var logHeader: String {
        "\(flashLowerBound.logHeader),\(flashUpperBound.logHeader),\(versionMajor.logHeader),\(versionMinor.logHeader)"
    }
    
    public var logValue: String {
        "\(flashLowerBound.logValue),\(flashUpperBound.logValue),\(versionMajor.logValue),\(versionMinor.logValue)"
    }
}

extension BlueNRGOtaMemoryInfoData: CustomStringConvertible {
    public var description: String {
        "n/a"
    }
}

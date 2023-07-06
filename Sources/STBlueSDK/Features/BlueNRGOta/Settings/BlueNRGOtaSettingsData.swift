//
//  BlueNRGOtaSettingsData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct BlueNRGOtaSettingsData {
    
    public let ackInterval: FeatureField<UInt8>
    public let imageSize: FeatureField<UInt32>
    public let baseAddress: FeatureField<UInt32>
    
    init(with data: Data, offset: Int) {
        let ackInterval = data.extractUInt8(fromOffset: offset)
        let imageSize = data.extractUInt32(fromOffset: offset + 1)
        let baseAddress = data.extractUInt32(fromOffset: offset + 5)
        
        self.ackInterval = FeatureField<UInt8>(name: "AckInterval",
                                               uom: nil,
                                               min: 0,
                                               max: UInt8.max,
                                               value: ackInterval)
        
        self.imageSize = FeatureField<UInt32>(name: "ImageSize",
                                              uom: nil,
                                              min: 0,
                                              max: UInt32.max,
                                              value: imageSize)
        
        self.baseAddress = FeatureField<UInt32>(name: "BaseAddress",
                                                uom: nil,
                                                min: 0,
                                                max: UInt32.max,
                                                value: baseAddress)
    }
    
}

extension BlueNRGOtaSettingsData: Loggable {
    public var logHeader: String {
        "\(ackInterval.logHeader),\(imageSize.logHeader),\(baseAddress.logHeader)"
    }
    
    public var logValue: String {
        "\(ackInterval.logValue),\(imageSize.logValue),\(baseAddress.logValue)"
    }
}

extension BlueNRGOtaSettingsData: CustomStringConvertible {
    public var description: String {
        "n/a"
    }
}

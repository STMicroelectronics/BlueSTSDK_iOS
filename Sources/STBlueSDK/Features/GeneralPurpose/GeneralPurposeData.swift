//
//  GeneralPurposeData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct GeneralPurposeData {

    public let rawData: FeatureField<Data>
    
    public let bytes: [FeatureField<UInt8>]

    init(with data: Data, offset: Int) {
        
        let dataValid = data.subdata(in: offset..<data.count)
        
        self.bytes = dataValid.enumerated().map { FeatureField<UInt8>(name: "B\($0)",
                                             uom: nil,
                                             min: 0,
                                             max: UInt8.max,
                                             value: $1) }

        self.rawData = FeatureField<Data>(name: "General purpose",
                                         uom: "RawData",
                                         min: nil,
                                         max: nil,
                                         value: dataValid)
        
    }
}

extension GeneralPurposeData: CustomStringConvertible {
    public var description: String {
        //let data = rawData.value ?? Data()
        //var descr = "RawData: \(data.hex)"
        var descr = ""
        
        for elem in bytes {
            descr += "\(elem.name): \(elem.value!)\n"
        }
        return descr
    }
}

extension GeneralPurposeData: Loggable {
    public var logHeader: String {
        bytes.map { $0.logHeader}.joined(separator: ",")
    }
    
    public var logValue: String {
        bytes.map { $0.logValue}.joined(separator: ",")
    }
    
}

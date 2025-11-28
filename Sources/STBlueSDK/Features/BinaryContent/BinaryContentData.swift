//
//  BinaryContentData.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct BinaryContentData {
    
    public let rawData: FeatureField<Data>
    public let bytesRec: FeatureField<Int>
    public let numberPackets: FeatureField<Int>
    
    init(with data: Data, bytesRec: Int=0, numberPackets: Int=0) {
        
        
        self.rawData = FeatureField<Data>(name: "Binary Content",
                                          uom: "RawData",
                                          min: nil,
                                          max: nil,
                                          value: data)
        
        self.bytesRec = FeatureField<Int>(name: "bytesRec",
                                          uom: "bytesRec",
                                          min: nil,
                                          max: nil,
                                          value: bytesRec)
        
        self.numberPackets = FeatureField<Int>(name: "numberPackets",
                                          uom: "numberPackets",
                                          min: nil,
                                          max: nil,
                                          value: numberPackets)
        
    }
}

extension BinaryContentData: CustomStringConvertible {
    public var description: String {
        
        let data = rawData.value ?? Data()
        
        if  data.isEmpty {
            return "numberPackets=\(numberPackets.value ?? 0) bytesRec=\(bytesRec.value ?? 0)"
        } else {
            return "numberPackets=\(numberPackets.value ?? 0) bytesRec=\(bytesRec.value ?? 0) BinaryContentData: Received"
        }
    }
}

extension BinaryContentData: Loggable {
    public var logValue: String {
        ""
    }
    
    public var logHeader: String {
        ""
    }
    
}

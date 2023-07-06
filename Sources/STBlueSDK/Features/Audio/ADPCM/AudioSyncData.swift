//
//  AudioSyncData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct AudioSyncData {
    let index: FeatureField<Int16>
    let predictedSample: FeatureField<Int32>
    
    init(with data: Data, offset: Int) {

        let index = Int16(data.extractUInt16(fromOffset: offset))
        let prevSampleIdx = data.extractInt32(fromOffset: offset + 2)
        
        self.index = FeatureField<Int16>(name: "ADPCM_index",
                                          uom: nil,
                                          min: Int16.min,
                                          max: Int16.max,
                                          value: index)
        
        self.predictedSample = FeatureField<Int32>(name: "ADPCM_predSample",
                                                   uom: nil,
                                                   min: Int32.min,
                                                   max: Int32.max,
                                                   value: prevSampleIdx)
    }
}

extension AudioSyncData: CustomStringConvertible {
    public var description: String {
        guard let index = index.value,
              let predictedSample = predictedSample.value else { return "n/a" }
        return "Index: \(index), PredictedSample: \(predictedSample)"
    }
}

extension AudioSyncData: Loggable {
    public var logHeader: String {
        "n/a"
    }
    
    public var logValue: String {
        "n/a"
    }
}

//
//  OpusAudioData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct OpusAudioData {
    
    let dataArray: FeatureField<[Int16]>
    
    init(with data: Data, offset: Int, engine: OpusEngine, manager: OpusCodecManager) {
        
        let decodedData = engine.decode(data: data, audioManager: manager)
        
        self.dataArray = FeatureField<[Int16]>(name: "OpusStrem",
                                               uom: nil,
                                               min: nil,
                                               max: nil,
                                               value: decodedData)
    }
    
}

extension OpusAudioData {
    public var audio: Data? {
        
        guard let dataArray = dataArray.value else { return nil }
        
        var outData = Data(capacity: dataArray.count * 2)
        
        dataArray.forEach { value in
            withUnsafeBytes(of: value) { outData.append(contentsOf: $0) }
        }
        
        return outData
    }
}

extension OpusAudioData: CustomStringConvertible {
    public var description: String {
        "n/a"
    }
}

extension OpusAudioData: Loggable {
    public var logHeader: String {
        "n/a"
    }
    
    public var logValue: String {
        "n/a"
    }
}

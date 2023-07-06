//
//  ADPCMAudioData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct ADPCMAudioData {
    let dataArray: FeatureField<[Int16]>
    
    init(with data: Data, offset: Int, engine: ADPCMEngine, manager: ADPCMCodecManager) {
        
        var dataArray = [Int16]()
        
        for i in offset..<(offset + 20) {
            let temp = engine.decode(code: Int8(data[i] & 0x0F), syncManager: manager)
            dataArray.append(temp)
            let temp2 = engine.decode(code: Int8((data[i] >> 4) & 0x0F), syncManager: manager)
            dataArray.append(temp2)
        }
        
        self.dataArray = FeatureField<[Int16]>(name: "ADPCM",
                                               uom: nil,
                                               min: nil,
                                               max: nil,
                                               value: dataArray)
    }
}

extension ADPCMAudioData {
    public var audio: Data? {
        guard let dataArray = dataArray.value, dataArray.count == 40 else {
            return nil
        }
        
        var outData = Data(capacity: 80)
        dataArray.forEach { value in
            outData.append(Data(value.bytes))
        }
        
        return outData
    }
}

extension ADPCMAudioData: CustomStringConvertible {
    public var description: String {
        guard let data = audio else { return "n/a" }
        return "Audio raw data: \(data.hex)"
    }
}

extension ADPCMAudioData: Loggable {
    public var logHeader: String {
        "n/a"
    }
    
    public var logValue: String {
        "n/a"
    }
}

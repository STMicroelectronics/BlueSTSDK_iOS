//
//  MachineLearningCoreData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct MachineLearningCoreData {
    
    public let registerStatus: [FeatureField<UInt8>]
    
    init(with data: Data, offset: Int, numberOfRegiters: Int) {
        
        var registerStatus = [FeatureField<UInt8>]()
        
        for index in offset..<(offset + numberOfRegiters) {
            let status = data.extractUInt8(fromOffset: index)
            
            registerStatus.append(FeatureField<UInt8>(name: "Register \(index-offset)",
                                                      uom: nil,
                                                      min: 0,
                                                      max: UInt8.max,
                                                      value: status))
        }
        
        self.registerStatus = registerStatus
    }
    
}

extension MachineLearningCoreData: CustomStringConvertible {
    public var description: String {
        var descr = ""
        
        for (index, element) in registerStatus.enumerated() {
            descr += "\(element.name) status: \(element.value ?? 0)"
            if index != 0 {
                descr += ","
            }
        }
        
        return descr.count > 0 ? descr : "No core available"
    }
}

extension MachineLearningCoreData: Loggable {
    public var logHeader: String {
        registerStatus.logHeader
    }
    
    public var logValue: String {
        registerStatus.logValue
    }
    
}

//
//  CarryPositionData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct CarryPositionData {
    
    public let position: FeatureField<CarryPositionType>
    
    init(with data: Data, offset: Int) {
        
        let position = CarryPositionType(rawValue: data.extractUInt8(fromOffset: offset))
        
        self.position = FeatureField<CarryPositionType>(name: "CarryPosition",
                                            uom: nil,
                                            min: nil,
                                            max: nil,
                                            value: position)
    }
    
}

extension CarryPositionData: CustomStringConvertible {
    public var description: String {
        
        let position = position.value ?? .unknown
        
        return String(format: "Position: %zd", position.description)
    }
}

extension CarryPositionData: Loggable {
    public var logHeader: String {
        "\(position.logHeader)"
    }
    
    public var logValue: String {
        "\(position.logValue)"
    }
    
}

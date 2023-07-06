//
//  DirectionOfArrivalData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct DirectionOfArrivalData {
    
    public let angle: FeatureField<Int16>
    
    init(with data: Data, offset: Int) {
        
        let angle = Self.normalize(data.extractInt16(fromOffset: offset))
        
        self.angle = FeatureField<Int16>(name: "Angle",
                                         uom: "\u{00B0}",
                                         min: 0,
                                         max: 360,
                                         value: angle)
    }
    
}

private extension DirectionOfArrivalData {
    static func normalize(_ angle: Int16) -> Int16 {
        
        var angle = angle
        
        while angle < 0 {
            angle += 360
        }
        
        while angle > 360 {
            angle -= 360
        }
        
        return angle
    }
}

extension DirectionOfArrivalData: CustomStringConvertible {
    public var description: String {
        
        let angle = angle.value ?? 0
        
        return String(format: "Angle: %zd", angle)
    }
}

extension DirectionOfArrivalData: Loggable {
    public var logHeader: String {
        "\(angle.logHeader)"
    }
    
    public var logValue: String {
        "\(angle.logValue)"
    }
    
}

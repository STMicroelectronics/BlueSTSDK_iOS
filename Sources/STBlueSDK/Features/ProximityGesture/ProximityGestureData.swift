//
//  ProximityGestureData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct ProximityGestureData {

    public let gesture: FeatureField<ProximityGestureType>

    init(with data: Data, offset: Int) {
        
        let gesture = ProximityGestureType(rawValue: data.extractUInt8(fromOffset: offset))

        self.gesture = FeatureField<ProximityGestureType>(name: "Gesture",
                                               uom: nil,
                                               min: nil,
                                               max: nil,
                                               value: gesture)
    }
}

extension ProximityGestureData: CustomStringConvertible {
    public var description: String {

        let gesture = gesture.value ?? .unknown

        return String(format: "Gesture: %@", gesture.description)
    }
}

extension ProximityGestureData: Loggable {
    public var logHeader: String {
        "\(gesture.logHeader)"
    }

    public var logValue: String {
        "\(gesture.logValue)"
    }
}

//
//  GestureNavigationData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct GestureNavigationData {
    
    public let gesture: FeatureField<NavigationGestureType>
    public let button: FeatureField<NavigationButtonType>
    
    init(with data: Data, offset: Int) {
        
        let gesture = NavigationGestureType(rawValue: data.extractUInt8(fromOffset: offset))
        let button = NavigationButtonType(rawValue: data.extractUInt8(fromOffset: offset + 1))
        
        self.gesture = FeatureField<NavigationGestureType>(name: "Gesture",
                                            uom: nil,
                                            min: .UNDEFINED,
                                            max: .ERROR,
                                            value: gesture)
        
        self.button = FeatureField<NavigationButtonType>(name: "Button",
                                            uom: nil,
                                            min: .UNDEFINED,
                                            max: .ERROR,
                                            value: button)
    }
    
}

extension GestureNavigationData: CustomStringConvertible {
    public var description: String {   
        let gesture = gesture.value ?? .UNDEFINED
        let button = button.value ?? .UNDEFINED

        return String(format: "Gesture: %@, Navigation: %@", gesture.description, button.description)
    }
}

extension GestureNavigationData: Loggable {
    public var logHeader: String {
        "\(gesture.logHeader),\(button.logHeader)"
    }
    
    public var logValue: String {
        "\(gesture.logValue),\(button.logValue)"
    }
    
}

//
//  CompassData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum Orientation: CaseIterable {
    case north
    case northEast
    case east
    case southEast
    case south
    case southWest
    case west
    case northWest

    static func orientation(from angle: Float) -> Orientation {
        let numberOfOrientations = Orientation.allCases.count
        let section = 360.0 / Double(numberOfOrientations)

        let shiftAngle = Double(angle) - section / 2 + 360.0
        let index = Int(shiftAngle / section) + 1

        return Orientation.allCases[index % numberOfOrientations]
    }
}

public protocol AngleData {
    var angleValue: Float { get }

    var orientation: Orientation { get }
}

public struct CompassData {
    
    public let angle: FeatureField<Float>
    
    init(with data: Data, offset: Int) {
        
        let angle = Float(data.extractUInt16(fromOffset: offset)) / 100.0
        
        self.angle = FeatureField<Float>(name: "Angle",
                                         uom: "",
                                         min: 0,
                                         max: 360,
                                         value: angle)
    }
    
}

extension CompassData: AngleData {
    public var angleValue: Float {
        angle.value ?? 0.0
    }

    public var orientation: Orientation {
        Orientation.orientation(from: angleValue)
    }
}

extension CompassData: CustomStringConvertible {
    public var description: String {
        
        let angle = angle.value ?? 0
        
        return String(format: "Angle: %.4f", angle)
    }
}

extension CompassData: Loggable {
    public var logHeader: String {
        "\(angle.logHeader)"
    }
    
    public var logValue: String {
        "\(angle.logValue)"
    }
    
}

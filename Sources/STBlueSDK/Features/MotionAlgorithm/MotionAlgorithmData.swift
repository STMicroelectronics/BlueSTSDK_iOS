//
//  MotionAlgorithmData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct MotionAlgorithmData {
    
    public let algorithm: FeatureField<Algorithm>
    public let result: FeatureField<UInt8>
    
    init(with data: Data, offset: Int) {
        
        let algorithm = Algorithm(rawValue: data.extractUInt8(fromOffset: offset))
        let value = data.extractUInt8(fromOffset: offset + 1)
        
        self.algorithm = FeatureField<Algorithm>(name: "Algorithm",
                                                 uom: nil,
                                                 min: nil,
                                                 max: nil,
                                                 value: algorithm)
        
        self.result = FeatureField<UInt8>(name: "Result",
                                         uom: nil,
                                         min: nil,
                                         max: nil,
                                         value: value)
    }
    
}

public extension MotionAlgorithmData {
    
    func getVerticalContext() -> VerticalContext? {
        guard let value = result.value, algorithm.value == .verticalContext else {
            return nil
        }
        
        return VerticalContext(rawValue: value)
    }
    
    func getPoseEstimation() -> PoseEstimation? {
        guard let value = result.value, algorithm.value == .poseEstimation else {
            return nil
        }
        
        return PoseEstimation(rawValue: value)
    }
    
    func getDetectedDeskType() -> DeskTypeDetection? {
        guard let value = result.value, algorithm.value == .deskTypeDetection else {
            return nil
        }
        
        return DeskTypeDetection(rawValue: value)
    }
}

extension MotionAlgorithmData: CustomStringConvertible {
    public var description: String {
        
        let algorithm = algorithm.value ?? .none
        let result = result.value ?? 0
        
        return String(format: "Algorithm: %@\nResult: %zd", algorithm.description, result)
    }
}

extension MotionAlgorithmData: Loggable {
    public var logHeader: String {
        "\(algorithm.logHeader),\(result.logHeader)"
    }
    
    public var logValue: String {
        "\(algorithm.logValue),\(result.logHeader)"
    }
    
}

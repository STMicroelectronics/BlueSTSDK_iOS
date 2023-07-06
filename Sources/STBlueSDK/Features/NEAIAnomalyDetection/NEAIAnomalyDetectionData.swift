//
//  NEAIAnomalyDetectionData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct NEAIAnomalyDetectionData {
    
    public let phase: FeatureField<PhaseType>
    public let state: FeatureField<StateType>
    public let phaseProgress: FeatureField<UInt8>
    public let status: FeatureField<StatusType>
    public let similarity: FeatureField<UInt8>
    
    init(with data: Data, offset: Int) {
        
        let phase = PhaseType(rawValue: data.extractUInt8(fromOffset: 4))
        let state = StateType(rawValue: data.extractUInt8(fromOffset: 5))
        let phaseProgress = data.extractUInt8(fromOffset: 6)
        let status = StatusType(rawValue: data.extractUInt8(fromOffset: 7))
        let similarity = data.extractUInt8(fromOffset: 8)
        
        self.phase = FeatureField<PhaseType>(name: "Phase",
                                            uom: nil,
                                            min: .IDLE,
                                             max: .NULL,
                                            value: phase)
        self.state = FeatureField<StateType>(name: "State",
                                            uom: nil,
                                             min: .OK,
                                             max: .NULL,
                                            value: state)
        self.phaseProgress = FeatureField<UInt8>(name: "Phase Progress",
                                            uom: "%",
                                            min: 0,
                                            max: 100,
                                            value: phaseProgress)
        self.status = FeatureField<StatusType>(name: "Status",
                                            uom: nil,
                                            min: .NORMAL,
                                            max: .NULL,
                                            value: status)
        self.similarity = FeatureField<UInt8>(name: "Similarity",
                                            uom: nil,
                                            min: 0,
                                            max: 100,
                                            value: similarity)
    }
}


extension NEAIAnomalyDetectionData: CustomStringConvertible {
    public var description: String {   
        let phase = phase.value ?? .NULL
        let state = state.value ?? .NULL
        let phaseProgress = phaseProgress.value ?? 0
        let status = status.value ?? .NULL
        let similarity = similarity.value ?? 0
        
        return String(format: "Phase: %@, State: %@, PhaseProgress: %@, Status: %@, Similarity: %@", phase.description, state.description, phaseProgress.description, status.description , similarity.description)
    }
}

extension NEAIAnomalyDetectionData: Loggable {
    public var logHeader: String {
        "\(phase.logHeader),\(state.logHeader),\(phaseProgress.logHeader),\(status.logHeader),\(similarity.logHeader)"
    }
    
    public var logValue: String {
        "\(phase.logValue),\(state.logValue),\(phaseProgress.logValue),\(status.logValue),\(similarity.logValue)"
    }
    
}

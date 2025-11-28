//
//  NEAIExtrapolationData.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct NEAIExtrapolationData {
    
    public let neaiExtrapolation: FeatureField<NEAIExtrapolation>
    
    init(neaiExtrapolation: NEAIExtrapolation) {
        
        self.neaiExtrapolation = FeatureField<NEAIExtrapolation>(name: "NEAIExtrapolation",
                                                                 uom: nil,
                                                                 min: nil,
                                                                 max: nil,
                                                                 value: neaiExtrapolation)
    }
    
}

extension NEAIExtrapolationData: CustomStringConvertible {
    public var description: String {
        let phase = neaiExtrapolation.value?.phase
        let state = neaiExtrapolation.value?.state
        let target = neaiExtrapolation.value?.target
        let unit = neaiExtrapolation.value?.unit
        let stub = neaiExtrapolation.value?.stub
        
        return String(format: "Phase: %@, State: %@, Target: %@, Unit: %@, Stub: %@ ", phase?.description  ?? "", state?.description ?? "", target?.description ?? "", unit?.description ?? "", stub?.description ?? "")
    }
}

extension NEAIExtrapolationData: Loggable {
    public var logHeader: String {
        "phase, state, target, unit, stub"
    }
    
    public var logValue: String {
        "\(neaiExtrapolation.value?.phase),\(neaiExtrapolation.value?.state),\(neaiExtrapolation.value?.target),\(neaiExtrapolation.value?.unit),\(neaiExtrapolation.value?.stub)"
    }
    
}

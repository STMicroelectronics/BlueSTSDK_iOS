//
//  SesorFusionData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct SensorFusionData {
    public let quaternionI: FeatureField<Float> // x quaternion component
    public let quaternionJ: FeatureField<Float> // y quaternion component
    public let quaternionK: FeatureField<Float> // z quaternion component
    public let quaternionS: FeatureField<Float> // w quaternion component

    init(quaternionI: Float, quaternionJ: Float, quaternionK: Float, quaternionS: Float) {

        self.quaternionI = FeatureField<Float>(name: "qi",
                                               uom: nil,
                                               min: -1,
                                               max: 1,
                                               value: quaternionI)

        self.quaternionJ = FeatureField<Float>(name: "qj",
                                               uom: nil,
                                               min: -1,
                                               max: 1,
                                               value: quaternionJ)

        self.quaternionK = FeatureField<Float>(name: "qk",
                                               uom: nil,
                                               min: -1,
                                               max: 1,
                                               value: quaternionK)

        self.quaternionS = FeatureField<Float>(name: "qs",
                                               uom: nil,
                                               min: -1,
                                               max: 1,
                                               value: quaternionS)
    }
}

extension SensorFusionData: CustomStringConvertible {
    public var description: String {

        let quaternionI = quaternionI.value ?? -1
        let quaternionJ = quaternionJ.value ?? -1
        let quaternionK = quaternionK.value ?? -1
        let quaternionS = quaternionS.value ?? -1

        return String(format: "X Component: %.4f\nY Component: %.4f\nZ Component: %.4f\nW Component", quaternionI, quaternionJ, quaternionK, quaternionS)
    }
}

extension SensorFusionData: Loggable {
    public var logHeader: String {
        "TBI"
    }

    public var logValue: String {
        "TBI"
    }
}

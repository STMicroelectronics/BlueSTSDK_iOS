//
//  SensorFusionCompactFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class SensorFusionCompactFeature: BaseFeature<SensorFusionCompactData>, CommandFeature {

    public var commands: [FeatureCommandType] = [
        AutoConfigurationCommand.start,
        AutoConfigurationCommand.stop,
        AutoConfigurationCommand.get
    ]

    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {

        if (data.count - offset < 6) {
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        }

        let quaternionsCount: UInt32 = UInt32(data.count - offset) / 6

        var offset = offset

        var samples = [SensorFusionData]()

        for _ in 0..<quaternionsCount {
            let quaternionI = Float(data.extractInt16(fromOffset: offset)) / QuaternionConfiguration.scaleFactor
            let quaternionJ = Float(data.extractInt16(fromOffset: offset + 2)) / QuaternionConfiguration.scaleFactor
            let quaternionK = Float(data.extractInt16(fromOffset: offset + 4)) / QuaternionConfiguration.scaleFactor
            let quaternionS = (1 - (pow(quaternionI, 2) + pow(quaternionJ, 2) + pow(quaternionK, 2))).squareRoot()

            samples.append(SensorFusionData(quaternionI: quaternionI,
                                            quaternionJ: quaternionJ,
                                            quaternionK: quaternionK,
                                            quaternionS: quaternionS))

            offset += 6
        }

        return (FeatureSample(with: timestamp,
                              data: SensorFusionCompactData(samples: samples) as? T, rawData: data), 6 * Int(quaternionsCount))
    }

    public override func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse {
        response
    }
}

public extension SensorFusionCompactFeature {

    var fakeData: Data {
        var data = Data(capacity: 18)

        let maxRandom = (QuaternionConfiguration.max - QuaternionConfiguration.min) * QuaternionConfiguration.decimal

        for _ in 0..<3 {
            var quaternionI = QuaternionConfiguration.min * QuaternionConfiguration.decimal + Float.random(in: 0..<maxRandom)
            var quaternionJ = QuaternionConfiguration.min * QuaternionConfiguration.decimal + Float.random(in: 0..<maxRandom)
            var quaternionK = QuaternionConfiguration.min * QuaternionConfiguration.decimal + Float.random(in: 0..<maxRandom)
            let quaternionW = QuaternionConfiguration.min * QuaternionConfiguration.decimal + Float.random(in: 0..<maxRandom)

            let norm: Float = (pow(quaternionI, 2) + pow(quaternionJ, 2) + pow(quaternionK, 2) + pow(quaternionW, 2)).squareRoot()

            quaternionI /= norm
            quaternionJ /= norm
            quaternionK /= norm

            let quaternionIScaled = Int16(quaternionI * QuaternionConfiguration.scaleFactor)
            let quaternionJScaled = Int16(quaternionJ * QuaternionConfiguration.scaleFactor)
            let quaternionKScaled = Int16(quaternionK * QuaternionConfiguration.scaleFactor)

            withUnsafeBytes(of: quaternionIScaled) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: quaternionJScaled) { data.append(contentsOf: $0) }
            withUnsafeBytes(of: quaternionKScaled) { data.append(contentsOf: $0) }
        }

        return data
    }

}

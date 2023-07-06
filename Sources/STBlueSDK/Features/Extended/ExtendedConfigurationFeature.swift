//
//  ExtendedConfigurationFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class ExtendedConfigurationFeature: BaseFeature<ExtendedConfigurationData> {

    private let dataTransporter = DataTransporter()

    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {

        if var commandFrame = dataTransporter.decapsulate(data: data) {
//            if debug {
//                STBlueSDK.log(text:Extract Data: \(String(data: commandFrame, encoding: .utf8))")
//            }

            do {
                commandFrame.removeLast()
                let response = try JSONDecoder().decode(ECResponse.self, from: commandFrame)
                dataTransporter.clear()
                return (FeatureSample(with: timestamp, data: ExtendedConfigurationData(response: response) as? T, rawData: data), 0)
            } catch {
                STBlueSDK.log(text: "Extract Data parse error: \(error)")
                return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
            }
        } else {
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        }
    }
}

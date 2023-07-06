//
//  PnPLFeature.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class PnPLFeature: BaseFeature<PnPLData> {

    private let dataTransporter = DataTransporter()

    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {

        dataTransporter.config.mtu = maxMtu

        if var commandFrame = dataTransporter.decapsulate(data: data) {
            do {
                commandFrame.removeLast()

                let response = try JSONDecoder().decode(PnPLResponse.self, from: commandFrame)
                dataTransporter.clear()
                return (FeatureSample(with: timestamp, data: PnPLData(rawData: commandFrame, response: response) as? T, rawData: data), data.count)
            } catch {
                dataTransporter.clear()
                STBlueSDK.log(text: "Extract Data parse error: \(error)")
                return (FeatureSample(with: timestamp, data: PnPLData(rawData: commandFrame, response: nil) as? T, rawData: data), data.count)
            }
        } else {
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        }
    }

}

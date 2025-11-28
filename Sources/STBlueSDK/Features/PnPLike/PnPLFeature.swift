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

public class PnPLFeature: TimestampFeature<PnPLData> {
    
    public required init(name: String, type: FeatureType) {
        super.init(name: name, type: type)
        isDataNotifyFeature = false
    }
    
    private let dataTransporter = DataTransporter()
    
    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        
        dataTransporter.config.mtu = maxMtu
        
        if var commandFrame = dataTransporter.decapsulate(data: data) {
            commandFrame.removeLast()
            let decoder = JSONDecoder()
            
            var spontaneousMessage: PnPLSpontaneousMessage? = nil
            var spontaneousResponseMessage: PnPLSpontaneousResponseMessage? = nil
            var singleComponentResponse: JSONValue? = nil

            var response: PnPLResponse? = nil
            
            if let responseTry = try? decoder.decode(PnPLResponse.self, from: commandFrame) {
                response = responseTry
            } else if let spontaneousMessageTry = try? decoder.decode(PnPLSpontaneousMessage.self, from: commandFrame) {
                spontaneousMessage = spontaneousMessageTry
            } else if let spontaneousResponseMessageTry = try? decoder.decode(PnPLSpontaneousResponseMessage.self, from: commandFrame) {
                spontaneousResponseMessage = spontaneousResponseMessageTry
            } else if let responseTry = try? decoder.decode(JSONValue.self, from: commandFrame) {
                singleComponentResponse = responseTry
            }

            dataTransporter.clear()
            return (
                FeatureSample(
                    with: timestamp,
                    data: PnPLData(
                        rawData: commandFrame,
                        response: response,
                        spontaneousMessage: spontaneousMessage,
                        spontaneousResponseMessage: spontaneousResponseMessage,
                        singleComponentResponse: singleComponentResponse) as? T, rawData: data), data.count)
        } else {
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        }
    }
    
}

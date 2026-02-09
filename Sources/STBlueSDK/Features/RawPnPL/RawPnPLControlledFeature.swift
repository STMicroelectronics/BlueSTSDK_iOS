//
//  RawPnPLControlledFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class RawPnPLControlledFeature: BaseFeature<RawPnPLControlledData> {

    internal var rawBleStreams: [RawPnPLStream] = []
    
    internal static let PROPERTY_NAME_ST_BLE_STREAM = "st_ble_stream"
    internal static let PROPERTY_NAME_ID = "id"
    internal static let PROPERTY_NAME_CUSTOM = "custom"
    internal static let PROPERTY_NAME_LABELS = "labels"
    internal static let PROPERTY_NAME_ENABLE = "enable"
    internal static let PROPERTY_NAME_MIN = "min"
    internal static let PROPERTY_NAME_MAX = "max"
    internal static let PROPERTY_NAME_UNIT = "unit"
    internal static let PROPERTY_NAME_ELEMENTS = "elements"
    internal static let PROPERTY_NAME_CHANNELS = "channels"
    internal static let PROPERTY_NAME_MULT_FACTOR = "multiply_factor"
    internal static let PROPERTY_NAME_ODR = "odr"
    
     override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
    
//        if data.count - offset < 2 {
//            return (FeatureSample(with: timestamp, data: data as? T, rawData: data), 0)
//        }
        
        let parsedData = RawPnPLControlledData(with: data, offset: offset)
        
         return (FeatureSample(with: timestamp, data: parsedData as? T, rawData: data), data.count - offset)
    }

    public override func parse(commandResponse response: FeatureCommandResponse) ->
        FeatureCommandResponse {
            return super.parse(commandResponse: response)
    }

}

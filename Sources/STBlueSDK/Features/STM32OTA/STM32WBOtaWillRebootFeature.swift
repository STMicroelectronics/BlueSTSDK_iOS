//
//  STM32WBOtaWillRebootFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

class STM32WBOtaWillRebootFeature: BaseFeature<Bool> {

    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {

        if (data.count - (offset - 2)) < 1 {
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        }

        let isRebooting = data.extractUInt8(fromOffset: (offset - 2)) == 1

        return (FeatureSample(with: isRebooting as? T, rawData: data), 1)
    }

    public override func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse {
        response
    }

}

extension Bool: Loggable {
    public var logHeader: String {
        "TBI"
    }

    public var logValue: String {
        "TBI"
    }
}

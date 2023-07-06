//
//  PnPLData.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct PnPLData {
    public let rawData: Data?
    public let response: PnPLResponse?
}

public extension PnPLData {

}

public extension PnPLData {

    func configuration(with dtmiCommands: PnPLikeDtmiElements?) -> [PnPLikeConfiguration] {
        var configurations: [PnPLikeConfiguration] = []

        dtmiCommands?.first?.contents.forEach { content in

            /// Obtained BOARD JSON sensor configuration
            let boardSensorConfiguration = response?.devices.first?.components.searchKey(keyValue: content.name)

            /// Check and Match Single Sensor Parameter / Component (PnPLike Element) between DTMI and BOARD jsons
            /// --- Extract and return PnPLike Element retrieved from DTMI ---
            let element = dtmiCommands?.element(with: content.schema?.url)

            var parameters: [PnPLikeConfigurationParameter] = [PnPLikeConfigurationParameter]()

            let type = PnPLType.type(with: content.name)

            /// Fill parameters name-value for a specific sensor
            element?.contents.forEach { param in

                let paramTypeAndDetail = param.buildParameterType(with: boardSensorConfiguration)

                parameters.append(PnPLikeConfigurationParameter(name: param.name,
                                                                displayName: param.displayName?.en ?? "",
                                                                type: paramTypeAndDetail.type,
                                                                detail: paramTypeAndDetail.detail,
                                                                unit: param.unit,
                                                                writable: param.writable))
            }

            configurations.append(PnPLikeConfiguration(name: content.name,
                                                       specificSensorOrGeneralType: type,
                                                       displayName:content.displayName?.en ?? "",
                                                       parameters: parameters,
                                                       visibile: false))
        }

        return configurations
    }
}

extension PnPLData: Loggable {
    public var logHeader: String {
        ""
    }

    public var logValue: String {
        ""
    }
}

extension PnPLData: CustomStringConvertible {
    public var description: String {
//        if let jsonSring = String(data: data, encoding: .utf8) {
//            STBlueSDK.log(text: jsonSring)
//        }
        guard let rawData = rawData else { return "" }
        return String(data: rawData, encoding: .utf8) ?? ""
    }
}

//
//  HSDDeviceParser.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class HSDDeviceParser {
    static func responseFrom(data: Data) -> HSDResponse? {
        var finalData = data
        finalData.removeLast()
//        let string = String(data: finalData, encoding: .utf8)
        do {
            return try JSONDecoder().decode(HSDResponse.self, from: finalData)
        } catch {
//            STBlueSDK.log(text:Device Response decode error: \(error)")
            return nil
        }
    }
    
    static func deviceStatusFrom(data: Data) -> HSDDeviceStatus? {
        var finalData = data
        finalData.removeLast()
//        let string = String(data: finalData, encoding: .utf8)
        do {
            return try JSONDecoder().decode(HSDDeviceStatus.self, from: finalData)
        } catch {
//            STBlueSDK.log(text:Device Status decode error: \(error)")
            return nil
        }
    }
    
    static func tagConfigFrom(data: Data) -> HSDTagConfigContainer? {
        var finalData = data
        finalData.removeLast()
//        let string = String(data: finalData, encoding: .utf8)
        do {
            return try JSONDecoder().decode(HSDTagConfigContainer.self, from: finalData)
        } catch {
//            STBlueSDK.log(text:TAG Config decode error: \(error)")
            return nil
        }
    }
}

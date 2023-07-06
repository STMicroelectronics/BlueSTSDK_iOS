//
//  HSDDeviceInfo.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class HSDDeviceInfo: Codable {
    private static let LATEST_FW_VERSION = "1.2.0"
    private static let LATEST_FW_NAME = "FP-SNS-DATALOG1"
    private static let LATEST_FW_URL = "https://www.st.com/en/embedded-software/fp-sns-datalog1.html"
    
    public let serialNumber: String
    public let alias: String
    public let partNumber: String?
    public let URL: String?
    public let fwName: String?
    public let fwVersion: String?
    public let dataFileExt: String?
    public let dataFileFormat: String?
    
    public var firmwareIsUpdated: Bool {
        guard let fwName = fwName, let fwVersion = fwVersion else { return true }
        
        if fwName + fwVersion != HSDDeviceInfo.LATEST_FW_NAME + HSDDeviceInfo.LATEST_FW_VERSION {
            return false
        }
        
        return true
    }
    
    public var fwErrorInfo: FWErrorInfo? {
        guard let fwName = fwName, let fwVersion = fwVersion else { return nil }
        
        if(HSDDeviceInfo.LATEST_FW_VERSION < fwVersion){ return nil }
        
        let currFW = fwName + "_v" + fwVersion
        let targetFW = HSDDeviceInfo.LATEST_FW_NAME + "_v" + HSDDeviceInfo.LATEST_FW_VERSION
        let targetFWUrl = HSDDeviceInfo.LATEST_FW_URL

        return FWErrorInfo(currFW: currFW, targetFW: targetFW, targetFWUrl: targetFWUrl)
    }
}

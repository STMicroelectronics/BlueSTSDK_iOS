//
//  WiFiSettings.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct WiFiSettings: Codable {
    public enum WiFiSecurity: String, CaseIterable, Codable {
        case OPEN = "OPEN"
        case WEP = "WEP"
        case WPA = "WPA"
        case WPA2 = "WPA2"
        case WPAWPA2 = "WPA/WPA2"
    }
    
    public let enable: Bool?
    public let ssid: String?
    public let password: String?
    public let securityType: WiFiSettings.WiFiSecurity?
    
    public init(enable: Bool?, ssid: String?, password: String?, securityType: WiFiSettings.WiFiSecurity?) {
        self.enable = enable
        self.ssid = ssid
        self.password = password
        self.securityType = securityType
    }
}

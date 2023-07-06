//
//  HSDCmd+GET.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class HSDGetCmd: HSDCmd {
    public static let GetDevice = HSDGetCmd(request: "device")
    public static let GetDeviceInfo = HSDGetCmd(request: "deviceInfo")
    public static let NetworkInfo = HSDGetCmd(request: "network")
    public static let TagConfig = HSDGetCmd(request: "tag_config")
    public static let LogStatus = HSDGetCmd(request: "log_status")
    
    let request: String
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["request"] = AnyEncodable(request)
        return serialized
    }
    
    public init(request: String) {
        self.request = request
        super.init(command: "GET")
    }
}

public class HSDGetDescriptorCmd: HSDGetCmd {
    let sensorId: String
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["sensorId"] = AnyEncodable(sensorId)
        return serialized
    }
    
    public init(address: String) {
        self.sensorId = address
        super.init(request: "descriptor")
    }
}

public class HSDGetStatusCmd: HSDGetCmd {
    let sensorId: String
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["sensorId"] = AnyEncodable(sensorId)
        return serialized
    }
    
    public init(address: String) {
        self.sensorId = address
        super.init(request: "status")
    }
}

class HSDGetRegisterCmd: HSDGetCmd {
    let address: String
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["address"] = AnyEncodable(address)
        return serialized
    }
    
    public init(address: String) {
        self.address = address
        super.init(request: "register")
    }
}

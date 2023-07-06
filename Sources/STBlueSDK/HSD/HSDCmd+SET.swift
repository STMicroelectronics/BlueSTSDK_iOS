//
//  HSDCmd+SET.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

extension StringProtocol {
    var lines: [SubSequence] { split(whereSeparator: \.isNewline) }
}

public class SubSensorStatusParam: Encodable {
    let id: Int
    
    var serialized: EncodableDictionary {
        ["id": AnyEncodable(id)]
    }
    
    public init(id: Int) {
        self.id = id
    }
}

public class MLCConfigParam: SubSensorStatusParam {
    let mlcConfigSize: Int
    let mlcConfigData: String
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["mlcConfigSize"] = AnyEncodable(mlcConfigSize)
        serialized["mlcConfigData"] = AnyEncodable(mlcConfigData)
        return serialized
    }
    
    internal init(id: Int, mlcConfigSize: Int, mlcConfigData: String) {
        self.mlcConfigSize = mlcConfigSize
        self.mlcConfigData = mlcConfigData
        super.init(id: id)
    }
    
    public static func fromUCFString(id: Int, ucfContent: String) -> MLCConfigParam {
        let compactString = ucfContent.lines
            .filter { isCommentLine(String($0)) }
            .map { $0.replacingOccurrences(of: " ", with: "").dropFirst(2) }
            .joined(separator: "")
        return MLCConfigParam(id: id, mlcConfigSize: compactString.count, mlcConfigData: compactString)
    }

    private static func isCommentLine(_ line: String) -> Bool {
        return !line.starts(with: "--")
    }
}

public class IsActiveParam: SubSensorStatusParam {
    let isActive: Bool
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["isActive"] = AnyEncodable(isActive)
        return serialized
    }
    
    public init(id: Int, isActive: Bool) {
        self.isActive = isActive
        super.init(id: id)
    }
}

public class ODRParam: SubSensorStatusParam {
    let ODR: Double
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["ODR"] = AnyEncodable(ODR)
        return serialized
    }
    
    public init(id: Int, odr: Double) {
        self.ODR = odr
        super.init(id: id)
    }
}

public class FSParam: SubSensorStatusParam {
    let FS: Double
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["FS"] = AnyEncodable(FS)
        return serialized
    }
    
    public init(id: Int, fs: Double) {
        self.FS = fs
        super.init(id: id)
    }
}

public class SamplePerTSParam: SubSensorStatusParam {
    let samplesPerTs: Int
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["samplesPerTs"] = AnyEncodable(samplesPerTs)
        return serialized
    }
    
    public init (id: Int, samplesPerTs: Int) {
        self.samplesPerTs = samplesPerTs
        super.init(id: id)
    }
}

public class HSDSetCmd: HSDCmd {
    let request: String?
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        if let request = request {
            serialized["request"] = AnyEncodable(request)
        }
        return serialized
    }
    
    public init(request: String?) {
        self.request = request
        super.init(command: "SET")
    }
}

public class HSDSetDeviceCmd: HSDSetCmd {}

public class HSDSetDeviceAliasCmd: HSDSetCmd {
    let alias: String
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["alias"] = AnyEncodable(alias)
        return serialized
    }
    
    public init(alias: String) {
        self.alias = alias
        super.init(request: "deviceInfo")
    }
}

public class HSDSetWiFiCmd: HSDSetDeviceCmd {
    let ssid: String?
    let password: String?
    let enable: Bool?
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["ssid"] = AnyEncodable(ssid)
        serialized["password"] = AnyEncodable(password)
        serialized["enable"] = AnyEncodable(enable)
        return serialized
    }
    
    public init(ssid: String?, password: String?, enable: Bool?) {
        self.ssid = ssid
        self.password = password
        self.enable = enable
        super.init(request: "network")
    }
}

public class HSDSetSWTagCmd: HSDSetDeviceCmd
{
    let ID: Int
    let enable: Bool
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["ID"] = AnyEncodable(ID)
        serialized["enable"] = AnyEncodable(enable)
        return serialized
    }
    
    public init(ID: Int, enable: Bool) {
        self.ID = ID
        self.enable = enable
        super.init(request: "sw_tag")
    }
}

public class HSDSetSWTagLabelCmd: HSDSetDeviceCmd
{
    let ID: Int
    let label: String
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["ID"] = AnyEncodable(ID)
        serialized["label"] = AnyEncodable(label)
        return serialized
    }
    
    public init(ID: Int, label: String) {
        self.ID = ID
        self.label = label
        super.init(request: "sw_tag_label")
    }
}

public class HSDSetHWTagCmd: HSDSetDeviceCmd
{
    let ID: Int
    let enable: Bool
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["ID"] = AnyEncodable(ID)
        serialized["enable"] = AnyEncodable(enable)
        return serialized
    }
    
    public init(ID: Int, enable: Bool) {
        self.ID = ID
        self.enable = enable
        super.init(request: "hw_tag")
    }
}

public class HSDSetHWTagLabelCmd: HSDSetDeviceCmd
{
    let ID: Int
    let label: String
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["ID"] = AnyEncodable(ID)
        serialized["label"] = AnyEncodable(label)
        return serialized
    }
    
    public init(ID: Int, label: String) {
        self.ID = ID
        self.label = label
        super.init(request: "hw_tag_label")
    }
}

public class HSDSetAcquisitionInfoCmd: HSDSetDeviceCmd
{
    let name: String?
    let notes: String?
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["name"] = AnyEncodable(name)
        serialized["notes"] = AnyEncodable(notes)
        return serialized
    }
    
    public init(name: String?, notes: String?) {
        self.name = name
        self.notes = notes
        super.init(request: "acq_info")
    }
}

public class HSDSetSensorCmd: HSDSetCmd
{
    let sensorId: Int
    let subSensorStatus: [SubSensorStatusParam]
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["sensorId"] = AnyEncodable(sensorId)
        serialized["subSensorStatus"] = AnyEncodable(subSensorStatus.map { $0.serialized })
        return serialized
    }
    
    public init(sensorId: Int, subSensorStatus: [SubSensorStatusParam]) {
        self.sensorId = sensorId
        self.subSensorStatus = subSensorStatus
        super.init(request: nil)
    }
}

public class HSDSetMLCSensorCmd: HSDSetDeviceCmd
{
    let sensorId: Int
    let subSensorStatus: [MLCConfigParam]
    
    override var serialized: EncodableDictionary {
        var serialized = super.serialized
        serialized["sensorId"] = AnyEncodable(sensorId)
        serialized["subSensorStatus"] = AnyEncodable(subSensorStatus.map { $0.serialized })
        return serialized
    }
    
    public init(sensorId: Int, subSensorStatus: [MLCConfigParam]) {
        self.sensorId = sensorId
        self.subSensorStatus = subSensorStatus
        super.init(request: "mlc_config")
    }
}


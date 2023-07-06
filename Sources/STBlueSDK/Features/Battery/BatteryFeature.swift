//
//  BatteryFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol FeatureCommandType {
    
    func data(with nodeId: UInt8) -> Data
    var description: String { get }
    var useMask: Bool { get }
    var payload: Data? { get }
}

public enum BatteryCommand: UInt8, FeatureCommandType {
    case getBatteryCapacity = 0x01
    case getMaxAssorbedCurrent = 0x02

    public var description: String {
        switch self {
        case .getBatteryCapacity:
            return "Get Battery Capacity"
        case .getMaxAssorbedCurrent:
            return "Get Max Assorbed Current"
        }
    }
    
    public var useMask: Bool {
        true
    }
    
    public func data(with nodeId: UInt8) -> Data {
        Data([rawValue])
    }
    
    public var payload: Data? {
        return nil
    }
}

public class BatteryFeature: BaseFeature<BatteryData>, CommandFeature {

    public var commands: [FeatureCommandType] = [
        BatteryCommand.getBatteryCapacity,
        BatteryCommand.getMaxAssorbedCurrent
    ]

    let uknownCurrent: UInt16 = 0x8000

    override func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {

        if (data.count - offset < 7) {
            return (FeatureSample(with: timestamp, data: nil, rawData: data), 0)
        }

        let level = Float(data.extractUInt16(fromOffset: offset)) / 10.0
        let voltage = Float(data.extractInt16(fromOffset: offset + 2)) / 1000.0

        let tempCurrent = data.extractUInt16(fromOffset: offset + 4)
        let tempStatus = data.extractUInt8(fromOffset: offset + 6)

        let current = extractCurrent(current: tempCurrent, hightRes: hasHeightResolutionCurrent(status: tempStatus))

        let batteryData = BatteryData(level: level,
                                      voltage: voltage,
                                      current: current,
                                      status: getBatteryStatus(tempStatus))

        return (FeatureSample(with: timestamp, data: batteryData as? T, rawData: data), 7)
    }

    public override func parse(commandResponse response: FeatureCommandResponse) -> 
        FeatureCommandResponse {
            return BatteryCommandResponse(timestamp: response.timestamp,
                                          featureMask: response.featureMask,
                                          commandType: response.commandType,
                                          rawData: response.data)
    }
}

private extension BatteryFeature {
    func extractCurrent(current: UInt16, hightRes: Bool) -> Float {
        if current == uknownCurrent {
            return Float.nan
        }

        if hightRes {
            return Float(current) * 0.1
        }

        return Float(current)
    }

    func hasHeightResolutionCurrent(status: UInt8) -> Bool {
        (status & 0x80) != 0
    }

    /***
     * remove the most MSB for extract only the battery status value
     * @param status battery status
     * @return the status with the MSB set to 0
     */
    func getBatteryStatus(_ status: UInt8) -> UInt8 {
        return status & 0x7F
    }
}

public extension BatteryFeature {

    var fakeData: Data {
        var data = Data(capacity: 7)

        var value = Int16.random(in: 0..<1000)
        withUnsafeBytes(of: value.bigEndian) { data.append(contentsOf: $0) }

        value = Int16.random(in: 0..<10000)
        withUnsafeBytes(of: value.bigEndian) { data.append(contentsOf: $0) }

        value = Int16.random(in: 0..<10)
        withUnsafeBytes(of: value.bigEndian) { data.append(contentsOf: $0) }

        let value8 = UInt8.random(in: 0..<4)
        withUnsafeBytes(of: value8.bigEndian) { data.append(contentsOf: $0) }

        return data
    }

}

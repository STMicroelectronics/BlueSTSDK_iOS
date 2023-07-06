//
//  HSDSensor.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public typealias HSDSensorTouple = (status: HSDSensorStatus, descriptor: HSDSubSensor)

public class HSDSensor: Codable {
    public class SubSensorDescriptor: Codable {
        public let subSensorDescriptor: [HSDSubSensor]
    }
    
    public class SensorStatusDescriptor: Codable {
        public let subSensorStatus: [HSDSensorStatus]
    }
    
    public let id: Int
    public let name: String
    public let sensorDescriptor: SubSensorDescriptor
    public var sensorStatus: SensorStatusDescriptor
    
    public var subSensors: [HSDSensorTouple] {
        var subSensors: [HSDSensorTouple] = []
        sensorDescriptor.subSensorDescriptor.enumerated().forEach { item in
            if item.offset < sensorStatus.subSensorStatus.count {
                subSensors.append((sensorStatus.subSensorStatus[item.offset], item.element))
            }
        }
        return subSensors
    }
    
    public func optionsForSensor(_ sensor: HSDSensorTouple) -> [HSDOptionModel] {
        var options: [HSDOptionModel] = []
        
        if let values = sensor.descriptor.ODR,
           let value = sensor.status.ODR {
            options.append(HSDOptionModel(mode: .odr, name: "sensor.data.odr", unit: nil, values: values, selected: value))
        }
        
        if let values = sensor.descriptor.FS,
           let value = sensor.status.FS {
            options.append(HSDOptionModel(mode: .fs, name: "sensor.data.fs", unit: sensor.descriptor.unit,  values: values, selected: value))
        }
        
        return options
    }
    
    public func statusIsEqual(_ sensor: HSDSensor) -> Bool {
        return sensorStatus.subSensorStatus.elementsEqual(sensor.sensorStatus.subSensorStatus)
    }
    
    public func getStatusForDescriptor(_ descriptor: HSDSubSensor) -> HSDSensorStatus? {
        if let index = sensorDescriptor.subSensorDescriptor.firstIndex(where: { $0.id == descriptor.id }) {
            if index < sensorStatus.subSensorStatus.count {
                return sensorStatus.subSensorStatus[index]
            }
        }
        
        return nil
    }
}

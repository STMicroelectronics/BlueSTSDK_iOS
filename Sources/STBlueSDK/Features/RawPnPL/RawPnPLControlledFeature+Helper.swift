//
//  RawPnPLControlledFeature+Helper.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import STUI
import STCore

public extension RawPnPLControlledFeature {

    func decodePnPLBoardResponseStreams(components: JSONValue) {
        rawBleStreams.removeAll()

        if case .array(let deviceComponents) = components {
            deviceComponents.forEach{ component in
                if let stBleStreamCodeValue = component.codeValues(with: [RawPnPLControlledFeature.PROPERTY_NAME_ST_BLE_STREAM]).filter({ $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_ST_BLE_STREAM) && $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_ID) }).first?.value {
                    if let streamNumber = stBleStreamCodeValue as? Int {
                        if case .object(let componentObject) = component {
                            componentObject.values.forEach { value in
                                if case .object(let valuesObject) = value {
                                    valuesObject.forEach { valueObj in
                                        if valueObj.key.elementsEqual(RawPnPLControlledFeature.PROPERTY_NAME_ST_BLE_STREAM) {
                                            if case .object(let stBleStreamArray) = valueObj.value {
                                                stBleStreamArray.forEach { stBleStream in
                                                    if stBleStream.key.elementsEqual(RawPnPLControlledFeature.PROPERTY_NAME_CUSTOM) {
                                                        if case .string(let customStringValue) = stBleStream.value {
                                                            guard let data = customStringValue.data(using: .utf8)  else { StandardHUD.shared.show(with: "Could not convert string to data."); return }
                                                            guard let customStream = try? JSONDecoder().decode(RawCustom.self, from: data) else { StandardHUD.shared.show(with: "Failed to decode data."); return }
                                                            rawBleStreams.append(
                                                                RawPnPLStream(id:streamNumber, streamName: nil, rawCustom: customStream)
                                                            )
                                                        } else {
                                                            StandardHUD.shared.show(with: "Could not read Raw Custom BLE Stream")
                                                        }
                                                    } else {
                                                        let hasActiveStream = stBleStream.value.codeValues(with: []).filter { $0.keys.contains { $0.contains(RawPnPLControlledFeature.PROPERTY_NAME_ENABLE) } && $0.value as? Bool == true || $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_CUSTOM) }
                                                        if !hasActiveStream.isEmpty {
                                                            
                                                            var currentRawPnPLStream = RawPnPLStream(id: streamNumber, streamName: stBleStream.key, codeValues: stBleStream.value.codeValues(with: []), parsedLabels: nil)
                                                            if case .object(let stBleStreamArrayObjectValues) = stBleStream.value {
                                                                stBleStreamArrayObjectValues.forEach { objValue in
                                                                    if objValue.key.elementsEqual(RawPnPLControlledFeature.PROPERTY_NAME_LABELS) {
                                                                        if case .string(let enumStringValue) = objValue.value {
                                                                            guard let data = enumStringValue.data(using: .utf8)  else { StandardHUD.shared.show(with: "Could not convert string to data."); return }
                                                                            guard let enumStream = try? JSONDecoder().decode([RawPnPLEnumLabel].self, from: data) else { StandardHUD.shared.show(with: "Failed to decode data."); return }
                                                                            currentRawPnPLStream.parsedLabels = enumStream
                                                                        }
                                                                    }
                                                                }
                                                            }
                                                            rawBleStreams.append(currentRawPnPLStream)
                                                        }
                                                    }
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    func extractBleStreamInfo(sample: FeatureSample<RawPnPLControlledData>) -> [RawPnPLStreamEntry] {
        let rawData = sample.rawData
        if let streamID = rawData.first {
            
            let streams = rawBleStreams.filter { $0.id == streamID }
            
            var rawPnPLEntries: [RawPnPLStreamEntry] = []
            
            var currentOffset = 1
            var currentCustomOffset = 1
            
            for currentStream in streams {
                if let customStream = currentStream.rawCustom {
                    customStream.output.forEach { output in
                        let streamValueResult = extractBleRawStreamValue(withType: output.type,
                                                                         withData: rawData,
                                                                         withName: output.name,
                                                                         andOffset: currentCustomOffset,
                                                                         elements: output.elements,
                                                                         hasMin: nil,
                                                                         hasMax: nil,
                                                                         hasUnit: nil,
                                                                         withStreamId: streamID,
                                                                         hasEnumLabels: currentStream.parsedLabels
                        )
                        currentCustomOffset = streamValueResult.1
                        if let entry = streamValueResult.0 {
                            rawPnPLEntries.append(entry)
                        }
                    }
                } else if let codeValuesStream = currentStream.codeValues {
                    if !codeValuesStream.isEmpty {
                        var min, max, multFactor: Double?
                        
                        let minAny = codeValuesStream.filter { $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_MIN) }.first?.value
                        let maxAny = codeValuesStream.filter { $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_MAX) }.first?.value
                        let unit = codeValuesStream.filter { $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_UNIT) }.first?.value as? String
                        
                        let odr = codeValuesStream.filter { $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_ODR) }.first?.value as? Int
                        let multFactorAny = codeValuesStream.filter { $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_MULT_FACTOR) }.first?.value
                        let elements = codeValuesStream.filter { $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_ELEMENTS) }.first?.value as? Int
                        let channels = codeValuesStream.filter { $0.keys.contains(RawPnPLControlledFeature.PROPERTY_NAME_CHANNELS) }.first?.value as? Int
                        
                        if let minAny = minAny {
                            min = Double("\(minAny)")
                        }
                        if let maxAny = maxAny {
                            max = Double("\(maxAny)")
                        }
                        if let multFactorAny = multFactorAny {
                            multFactor = Double("\(multFactorAny)")
                        }
                        
                        codeValuesStream.forEach { codeValue in
                            guard let formatValue = codeValue.value as? String else { return }
                            guard let rawPnPLCustomEntryFormat = RawPnPLFormat(rawValue: formatValue) else { return }
                            
                            let streamValueResult = extractBleRawStreamValue(withType: rawPnPLCustomEntryFormat,
                                                                             withData: rawData,
                                                                             withName: currentStream.streamName ?? "",
                                                                             andOffset: currentOffset,
                                                                             elements: elements ?? 1,
                                                                             channels: channels ?? 1,
                                                                             multFactor: multFactor,
                                                                             odr: odr,
                                                                             hasMin: min,
                                                                             hasMax: max,
                                                                             hasUnit: unit,
                                                                             withStreamId: streamID,
                                                                             hasEnumLabels: currentStream.parsedLabels
                            )
                            currentOffset = streamValueResult.1
                            if let entry = streamValueResult.0 {
                                rawPnPLEntries.append(entry)
                            }
                        }
                    }
                }
            }
            return rawPnPLEntries
        }
        return []
    }
    
    private func extractBleRawStreamValue(withType type: RawPnPLFormat,
                                          withData rawData: Data,
                                          withName name: String,
                                          andOffset currentOffset: Int,
                                          elements: Int = 1,
                                          channels: Int = 1,
                                          multFactor: Double? = nil,
                                          odr: Int? = nil,
                                          hasMin min: Double?,
                                          hasMax max: Double?,
                                          hasUnit unit: String?,
                                          withStreamId streamId: UInt8,
                                          hasEnumLabels: [RawPnPLEnumLabel]?) -> (RawPnPLStreamEntry?, Int) {
        var offset = currentOffset
        var value: [Any] = []
        var valueFloat: [Float] = []
        
        let totalNumberOfElements = elements*channels
            
        for _ in 1...totalNumberOfElements {
            switch type {
            case .uint8_t:
                let tmpValue = rawData.extractUInt8(fromOffset: offset)
                value.append(tmpValue)
                valueFloat.append(Float(tmpValue) * Float((multFactor ?? 1.0)))
                offset += 1
            case .int8_t:
                let tmpValue = rawData.extractInt8(fromOffset: offset)
                value.append(tmpValue)
                valueFloat.append(Float(tmpValue) * Float((multFactor ?? 1.0)))
                offset += 1
            case .uint16_t:
                let tmpValue = rawData.extractUInt16(fromOffset: offset)
                value.append(tmpValue)
                valueFloat.append(Float(tmpValue) * Float((multFactor ?? 1.0)))
                offset += 2
            case .int16_t:
                let tmpValue = rawData.extractInt16(fromOffset: offset)
                value.append(tmpValue)
                valueFloat.append(Float(tmpValue) * Float((multFactor ?? 1.0)))
                offset += 2
            case .uint32_t:
                let tmpValue = rawData.extractUInt32(fromOffset: offset)
                value.append(tmpValue)
                valueFloat.append(Float(tmpValue) * Float((multFactor ?? 1.0)))
                offset += 4
            case .int32_t:
                let tmpValue = rawData.extractInt32(fromOffset: offset)
                value.append(tmpValue)
                valueFloat.append(Float(tmpValue) * Float((multFactor ?? 1.0)))
                offset += 4
            case .float, .float_t:
                let tmpValue = rawData.extractFloat(fromOffset: offset)
                value.append(tmpValue)
                valueFloat.append(tmpValue * Float((multFactor ?? 1.0)))
                offset += 4
            case .char:
                break
            case .enumerative:
                let localValue = rawData.extractUInt8(fromOffset: offset)
                guard let intValue = Int("\(localValue)") else { offset += 1; break }
                guard let enumValue = hasEnumLabels?.first(where: { $0.value == intValue }) else {offset += 1; break }
                value.append(enumValue)
                valueFloat.append(Float(intValue) * Float((multFactor ?? 1.0)))
                offset += 1
            }
        }
        
        if value.isEmpty {
            return (nil, offset)
        }
        
        return (RawPnPLStreamEntry(name: name, format: type, unit: unit, max: max, min: min, value: value, valueFloat: valueFloat,streamId: streamId, elements: elements, channels: channels, multiplyFactor: multFactor, odr: odr) , offset)
    }
}

public extension Array {
    func splitByChunk(_ chunkSize: Int) -> [[Element]] {
        return stride(from: 0, to: self.count, by: chunkSize).map {
            Array(self[$0..<Swift.min($0 + chunkSize, self.count)])
        }
    }
}

extension JSONValue {
    func codeValues(with key: [String]) -> [any KeyValue] {

        var codeValues = [any KeyValue]()
        var keys = [String]()

        keys.append(contentsOf: key)

        switch self {
        case .object(let dictionary):
            for key in dictionary.keys {
                if let sensorDictionary = dictionary[key] {
                    var dictionaryKeys = [String]()
                    dictionaryKeys.append(contentsOf: keys)
                    dictionaryKeys.append(key)
                    codeValues.append(contentsOf: sensorDictionary.codeValues(with: dictionaryKeys))
                }
            }
        case .array(let array):
            for sensor in array {
                codeValues.append(contentsOf: sensor.codeValues(with: keys))
            }
        case .string(let string):
            codeValues.append(CodeValue<String>(keys: keys, value: string))
        case .int(let int):
            codeValues.append(CodeValue<Int>(keys: keys, value: int))
        case .double(let double):
            codeValues.append(CodeValue<Double>(keys: keys, value: double))
        case .bool(let bool):
            codeValues.append(CodeValue<Bool>(keys: keys, value: bool))
        }

        return codeValues
    }
}

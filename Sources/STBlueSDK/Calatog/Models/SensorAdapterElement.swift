//
//  Sensors.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

// MARK: - SensorAdapterElement
public struct SensorAdapterElement: Codable {
    public let uniqueID: Int
    public let id: String
    public let boardCompatibility: [String]?
    public let description: String
    public let icon: String
    public let model: String
    public let output: String
    public let outputs: [String]?
    public let um: String?
    public let datasheetLink: String
    public let notes: String?
    public let dataType: String
    public let powerModes: [SensorAdapterPowerMode]?
    public let configuration: SensorAdapterConfiguration?
    public let acquisitionTime: Int?
    public let fullScales: [Int]?
    public let fullScaleUm: String?
    public let bleMaxOdr: Double?

    enum CodingKeys: String, CodingKey {
        case uniqueID = "unique_id"
        case id, description, icon, model
        case boardCompatibility = "board_compatibility"
        case output, outputs, um, datasheetLink, notes, dataType, powerModes, acquisitionTime, configuration, fullScaleUm, fullScales, bleMaxOdr
    }
}

// MARK: - Configuration
public struct SensorAdapterConfiguration: Codable {
    public let powerMode: String?
    public let odr: Double?
    public let acquisitionTime, fullScale: Int?
    public let regConfig, mlcLabels, ucfFilename: String?
}

// MARK: - PowerModeElement
public struct SensorAdapterPowerMode: Codable {
    public let mode, label: String
    public let odrs: [Double]
    public let minCustomOdr: Double?
}

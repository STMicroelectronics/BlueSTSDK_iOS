//
//  MedicalSignalType.swift
//
//  Copyright (c) 2024 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

public class MedicalSignalType {
    public let numberOfSignals: Int
    public let precision: MedicalPrecision
    public let description: String
    public let yMeasurementUnit: String?
    public let minGraphValue: Int
    public let maxGraphValue: Int
    public let nLabels: Int
    public let isAutoscale: Bool
    public let showXvalues: Bool
    public let showLegend: Bool
    public let signalLabels: [String]
    public let cubicInterpolation: Bool
    public let displayWindowTimeSecond: Int
    
    init(numberOfSignals: Int, precision: MedicalPrecision, 
         description: String, yMeasurementUnit: String? = nil,
         minGraphValue: Int = 0, maxGraphValue: Int = 0 , 
         nLabels: Int = 0, isAutoscale: Bool = true, showXvalues: Bool = false,
         showLegend: Bool = true, signalLabels: [String] = [],
         cubicInterpolation: Bool = false, displayWindowTimeSecond: Int = 5) {
        self.numberOfSignals = numberOfSignals
        self.precision = precision
        self.description = description
        self.yMeasurementUnit = yMeasurementUnit
        self.minGraphValue = minGraphValue
        self.maxGraphValue = maxGraphValue
        self.nLabels = nLabels
        self.isAutoscale = isAutoscale
        self.showXvalues = showXvalues
        self.showLegend = showLegend
        self.signalLabels = signalLabels
        self.cubicInterpolation = cubicInterpolation
        self.displayWindowTimeSecond = displayWindowTimeSecond
    }
}

public extension UInt8 {
    func MedicalSignalByte() -> MedicalSignalType {
        return switch self {
        case 0x00: MedicalSignalType(numberOfSignals: 1, precision: MedicalPrecision.ubit24, description: "RNB_RED (PPG1)", showLegend: false)
        case 0x01: MedicalSignalType(
            numberOfSignals: 1, precision: MedicalPrecision.ubit24, description: "RNB_BLUE (PPG2)",
            nLabels: 10,
            showLegend: false)
            
        case 0x02: MedicalSignalType(numberOfSignals: 1, precision: MedicalPrecision.ubit24, description: "PPG3", showLegend: false)
        case 0x03: MedicalSignalType(numberOfSignals: 1, precision: MedicalPrecision.ubit24, description: "PPG4", showLegend: false)
        case 0x04: MedicalSignalType(numberOfSignals: 1, precision: MedicalPrecision.ubit24, description: "PPG5", showLegend: false)
        case 0x05: MedicalSignalType(numberOfSignals: 1, precision: MedicalPrecision.ubit24, description: "PPG6", showLegend: false)
        case 0x06: MedicalSignalType(
            numberOfSignals: 1, precision: MedicalPrecision.bit16, description: "Electromyography",
            showLegend: true)
            
        case 0x07: MedicalSignalType(
            numberOfSignals: 4, precision: MedicalPrecision.bit16, description: "Bio impedance",
            signalLabels: ["ACp", "ACq", "DCp", "DCq"])
            
        case 0x08: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "Galvanic Skin Response",
            showLegend: false)
            
        case 0x09: MedicalSignalType(
            numberOfSignals: 3,
            precision: MedicalPrecision.bit16,
            description: "Accelerometer",
            signalLabels: ["X", "Y", "Z"],
            cubicInterpolation: true)
            
        case 0x0A: MedicalSignalType(
            numberOfSignals: 3,
            precision: MedicalPrecision.bit16,
            description: "Gyroscope",
            signalLabels: ["Gx", "Gy", "Gz"],
            cubicInterpolation: true)
            
        case 0x0B: MedicalSignalType(
            numberOfSignals: 3,
            precision: MedicalPrecision.bit16,
            description: "Magnetometer",
            signalLabels: ["Mx", "My", "Mz"],
            cubicInterpolation: true)
            
        case 0x0C: MedicalSignalType(
            numberOfSignals: 1, precision: MedicalPrecision.ubit24, description: "Pressure",showLegend: false)
            
        case 0x0D: MedicalSignalType(
            numberOfSignals: 1, precision: MedicalPrecision.bit16, description: "Temperature",
            showLegend: false)
            
        case 0x10: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 1",
            showLegend:false)
            
        case 0x11: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 2",
            showLegend: false)
            
        case 0x12: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 3",
            showLegend: false)
            
        case 0x13: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 4",
            showLegend: false)
            
        case 0x14: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 5",
            showLegend: false)
            
        case 0x15: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 6",
            showLegend: false)
            
        case 0x16: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 7",
            showLegend: false)
            
        case 0x17: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 8",
            showLegend: false)
            
        case 0x18: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 9",
            showLegend: false)
            
        case 0x19: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 10",
            showLegend: false)
            
        case 0x1A: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 11",
            showLegend: false)
            
        case 0x1B: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "ECG Channel 12",
            showLegend: false)
            
        case 0x20: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "Bio impedance dZ")
            
        case 0x21: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "Bio impedance Z0")
            
        case 0x22: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "Bio impedance Ze")
            
        case 0x23: MedicalSignalType(
            numberOfSignals: 1,
            precision: MedicalPrecision.bit16,
            description: "Bio impedance Zc")
        default: MedicalSignalType(numberOfSignals: 0, precision: MedicalPrecision.notdefined, description: "Not Supported")
        }
    }
}

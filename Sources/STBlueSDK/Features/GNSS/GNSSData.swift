//
//  GNSSData.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public struct GNSSData {
    
    public let latitude: FeatureField<Float>
    public let longitude: FeatureField<Float>
    public let altitude: FeatureField<Float>
    
    public let numberOfSatellites: FeatureField<UInt8>
    public let qualityOfSignal: FeatureField<UInt8>
    
    init(with data: Data, offset: Int) {
        
        let latitude = Float(data.extractInt32(fromOffset: offset)) / 1e+07
        let longitude = Float(data.extractInt32(fromOffset: offset + 4)) / 1e+07
        let altitude = Float(data.extractInt32(fromOffset: offset + 8)) / 1e+03
        
        let numberOfSatellites = data.extractUInt8(fromOffset: offset + 12)
        let qualityOfSignal = data.extractUInt8(fromOffset: offset + 13)
        
        self.latitude = FeatureField<Float>(name: "Latitude",
                                            uom: "Lat",
                                            min: -900000000,
                                            max: 900000000,
                                            value: latitude)
        
        self.longitude = FeatureField<Float>(name: "Longitude",
                                             uom: "Lon",
                                             min: -1800000000,
                                             max: 1800000000,
                                             value: longitude)
        
        self.altitude = FeatureField<Float>(name: "Altitude",
                                            uom: "Meter",
                                            min: 0,
                                            max: Float.nan,
                                            value: altitude)
        
        self.numberOfSatellites = FeatureField<UInt8>(name: "Satellites Number",
                                                      uom: "Num",
                                                      min: 0,
                                                      max: UInt8.max,
                                                      value: numberOfSatellites)
        
        self.qualityOfSignal = FeatureField<UInt8>(name: "Signal Quality",
                                                   uom: "dB-Hz",
                                                   min: 0,
                                                   max: UInt8.max,
                                                   value: qualityOfSignal)
    }
    
}

extension GNSSData: CustomStringConvertible {
    public var description: String {
        
        let latitude = latitude.value ?? 0
        let longitude = longitude.value ?? 0
        let altitude = altitude.value ?? 0
        
        let numberOfSatellites = numberOfSatellites.value ?? 0
        let qualityOfSignal = qualityOfSignal.value ?? 0
        
        return String(format: "Latitude: %.2f\nLongitude: %.2f\nAltitude: %.2f\nNumber of satellites: %zd\nQuality of signail: %zd", latitude, longitude, altitude, numberOfSatellites, qualityOfSignal)
    }
}

extension GNSSData: Loggable {
    public var logHeader: String {
        "\(latitude.logHeader),\(longitude.logHeader),\(altitude.logHeader),\(numberOfSatellites.logHeader),\(qualityOfSignal.logHeader)"
    }
    
    public var logValue: String {
        "\(latitude.logValue),\(longitude.logValue),\(altitude.logValue),\(numberOfSatellites.logValue),\(qualityOfSignal.logValue)"
    }
    
}

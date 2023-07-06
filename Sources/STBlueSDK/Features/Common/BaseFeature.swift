//
//  BaseFeature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class BaseFeature<T: Loggable & CustomStringConvertible>: Feature, Initializable {

    public typealias FeatureExtractDataResult<T: Loggable> = (sample: FeatureSample<T>, offset: Int)

    public var maxMtu: Int = 20
    public var name: String
    public var type: FeatureType
    public var isEnabled: Bool = false
    public var isNotificationsEnabled: Bool = false
    public var sample: FeatureSample<T>?
    public var lastSample: AnyFeatureSample? {
        return sample
    }
    
    public var hasData: Bool {
        sample?.data != nil
    }

    public var notificationDate: Date? {
        sample?.notificationTime
    }
    
    public var simpleDescription: String {
        return "[\(String(describing: Swift.type(of: self)))]\nMASK: \(String(format: "%08X", type.mask))"
    }

    required public init(name: String, type: FeatureType) {
        self.name = name
        self.type = type
    }

    func extractData<T>(with timestamp: UInt64, data: Data, offset: Int) -> FeatureExtractDataResult<T> {
        fatalError("You must overwrite \(#function) in a subclass")
    }

    public func parse(commandResponse response: FeatureCommandResponse) -> FeatureCommandResponse {
        response
    }
    
    public func update(with timestamp: UInt64, data: Data, offset: Int, mtu: Int) -> Int {
        maxMtu = mtu
        let extractedData: FeatureExtractDataResult<T> = extractData(with: timestamp, data: data, offset: offset)
        sample = extractedData.sample

        return extractedData.offset
    }
    
    public func description(with sample: AnyFeatureSample?) -> String {
        
        guard let sample = sample else {
            return "\n\(simpleDescription)\nSample not available"
        }
        
        return "\n\(simpleDescription)\n\(sample.description)"
    }

}

extension BaseFeature: Loggable {
    public var logHeader: String {
        sample?.data?.logHeader ?? "n/a"
    }
    public var logValue: String {
        sample?.data?.logValue ?? "n/a"
    }
}

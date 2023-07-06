//
//  Array+BlueCharacteristic.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public extension Array where Element == BlueCharacteristic {

    func characteristic(with feature: Feature) -> BlueCharacteristic? {

        filter { $0.features.contains(where: { $0.type == feature.type }) }
        .sorted { $0.features.count > $1.features.count }
        .first

    }

    func characteristic(with classType: Feature.Type) -> BlueCharacteristic? {

        filter { $0.features.contains(where: { type(of: $0) == classType }) }
        .sorted { $0.features.count > $1.features.count }
        .first

    }

    func commandCharacteristic() -> BlueCharacteristic? {

        filter { $0.characteristic.uuid == BlueUUID.Service.Config.featureCommandUuid }
        .first

    }

    func first(with classType: Feature.Type) -> Feature? {
        return first(where: { $0.features.contains(where: { type(of: $0) == classType })})?
            .features
            .first(where: { type(of: $0) == classType })
    }
    
    func features(with classTypes: [Feature.Type]) -> [Feature] {
        
        var allFeatures = [Feature]()
        
        classTypes.compactMap { classType in
            if let features = first(where: { $0.features.contains(where: { type(of: $0) == classType })})?
                .features
                .filter { type(of: $0) == classType } {
                    allFeatures.append(contentsOf: features)
                }
        }
        
        return allFeatures
    }

    func allFeatures() -> [Feature] {
        return map { $0.features }.flatMap { $0 }
    }
}

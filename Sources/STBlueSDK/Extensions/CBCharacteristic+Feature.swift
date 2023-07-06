//
//  CBCharacteristic+Feature.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import CoreBluetooth

public extension CBCharacteristic {

    func buildBlueCharacteristic(with supportedFeatureTypes: [FeatureType],
                                 protocolVersion: UInt8,
                                 advertisingMask: UInt32,
                                 maxMtu: Int) -> BlueCharacteristic? {

        if isFeatureCaracteristics {
            return BlueCharacteristic(characteristic: self,
                                      features: buildStandardFeatures(with: supportedFeatureTypes,
                                                                      protocolVersion: protocolVersion,
                                                                      advertisingMask: advertisingMask),
                                      maxMtu: maxMtu)
        } else if isExtendedFeatureCaracteristics {
            return BlueCharacteristic(characteristic: self,
                                      features: buildFeatures(with: FeatureType.extentedTypes),
                                      maxMtu: maxMtu)
        } else if isFeatureGeneralPurposeCharacteristics {
            let feature = GeneralPurposeFeature(name: "",
                                            type: .generalPurpose(identifier: uuid.featureMask))
            return BlueCharacteristic(characteristic: self,
                                      features: [ feature ],
                                      maxMtu: maxMtu)
        } else if isExternalCharacteristics {
            return BlueCharacteristic(characteristic: self,
                                      features: buildFeatures(with: FeatureType.externalTypes),
                                      maxMtu: maxMtu)

        }

        return nil
    }

    private func buildFeatures(with featureTypes: [FeatureType]) -> [Feature] {

        guard let featureType = featureTypes.featureType(with: self.uuid) else {
            return [Feature]()
        }

        var feature = featureType.descriptor.featureClass.init(name: String(describing: featureType.descriptor.featureClass), type: featureType)
        feature.isEnabled = true
        return [ feature ]
    }

    private func buildStandardFeatures(with supportedFeatureTypes: [FeatureType],
                                       protocolVersion: UInt8,
                                       advertisingMask: UInt32) -> [Feature] {

        var features: [Feature] = [Feature]()
        var mask: UInt32 = 1 << 31

        for _ in 0..<32 {
            if uuid.featureMask & mask != 0,
               var feature = FeatureType.feature(from: mask,
                                                 types: supportedFeatureTypes) {

                feature.isEnabled = protocolVersion == 1 ? ((advertisingMask & feature.type.mask) != 0) : true

                features.append(feature)
            }

            mask = mask >> 1
        }

        return features
    }
}

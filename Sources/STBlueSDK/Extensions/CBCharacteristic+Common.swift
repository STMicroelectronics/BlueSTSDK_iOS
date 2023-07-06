//
//  CBCharacteristic+Common.swift
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

extension CBCharacteristic {

    /**
     *  tell if a characteristics has a valid uuid for be manage by this sdk
     *
     *  @param c characteristic to test
     *
     *  @return true if the characteristics can be manage by this sdk
     */
    var isFeatureCaracteristics: Bool {
        get {
            return self.uuid.uuidString.hasSuffix(BlueUUID.Feature.base)
        }
    }

    var isExtendedFeatureCaracteristics: Bool {
        get {
            return FeatureType.extentedTypes.map { $0.uuid }.contains(uuid)
        }
    }

    /**
     *  tell if a characteristics has a valid uudi for be manage by this sdk as a
     *  general pourpose characteristics
     *
     *  @param c characteristic to test
     *
     *  @return true if the characteristics can be manage by this sdk as general purpose characteristics
     */
    var isFeatureGeneralPurposeCharacteristics: Bool {
        get {
            return self.uuid.uuidString.hasSuffix(BlueUUID.Feature.generalPurpose)
        }
    }

    var isDebugCharacteristic: Bool {
        get{
            return isDebugTermCharacteristic || isDebugErrorCharacteristic
        }
    }
    var isDebugTermCharacteristic: Bool {
        get {
            return self.uuid == BlueUUID.Service.Debug.termUuid
        }
    }

    var isDebugErrorCharacteristic: Bool {
        get {
            return self.uuid == BlueUUID.Service.Debug.stdErrUuid
        }
    }

    var isExternalCharacteristics: Bool {
        get {

            var identifier = self.uuid.uuidString

            if self.uuid.data.count == 2 {
                identifier = identifier + BlueUUID.Feature.External.standard
            }
            
            return identifier.hasSuffix(BlueUUID.Feature.External.stm32WBOta) ||
            identifier.hasSuffix(BlueUUID.Feature.External.blueNRGOta) ||
            identifier.hasSuffix(BlueUUID.Feature.External.peerToPeer) ||
            identifier.hasSuffix(BlueUUID.Feature.External.standard)
        }
    }

    var isConfigCharacteristics: Bool {
        get {
            return isConfigControlCharacteristic || isConfigFeatureCommandCharacteristic
        }
    }

    var isConfigControlCharacteristic: Bool {
        get {
            return self.uuid == BlueUUID.Service.Config.configControlUuid
        }
    }

    var isConfigFeatureCommandCharacteristic: Bool {
        get {
            return self.uuid == BlueUUID.Service.Config.featureCommandUuid
        }
    }

    /**
     * tell if you can read a characteristic
     * @param c characteristic to read
     * @return true if it can be read
     */
    var isCharacteristicCanBeRead: Bool {
        return properties.contains(.read)
    }

    /**
     * tell if you can enable the notification for a characteristic
     * @param c characteristic to test
     * @return true if it can be notify
     */
    var isCharacteristicCanBeNotify: Bool {
        properties.contains(.notify) || properties.contains(.notifyEncryptionRequired) || properties.contains(.indicate)
    }

    /**
     * tell if you can write a characteristic
     * @param c characteristic to test
     * @return true if it can be write
     */
    var isCharacteristicCanBeWrite: Bool {
        properties.contains(.write) || properties.contains(.writeWithoutResponse)
    }
    
    /**
     * tell if a characteristic is withoutResponse or withResponse
     * @param c characteristic to test
     * @return CBCharacteristicWriteType
     */
    var writeType: CBCharacteristicWriteType {
        if(properties.contains(.writeWithoutResponse)){
            return CBCharacteristicWriteType.withoutResponse
        } else {
            return CBCharacteristicWriteType.withResponse
        }
    }
}

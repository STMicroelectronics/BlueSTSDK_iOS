//
//  BlueUUID.swift
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

struct BlueUUID {
    static let common = "-11E1-AC36-0002A5D5C51B"

    struct Feature {
        static let base = "-0001" + common
        static let extended = "-0002" + common
        static let generalPurpose = "-0003" + common

        struct External {
//            static let standard = "-0000-1000-8000-00805f9b34fb".uppercased()
            static let standard = ""
            static let stm32WBOta = "-8e22-4541-9d4c-21edae82ed19".uppercased()
            static let blueNRGOta = "-8508-11e3-baa7-0800200c9a66".uppercased()
            static let peerToPeer = "-8e22-4541-9d4c-21edae82ed19".uppercased()
        }
    }

    struct Service {
        static let common = "-11E1-9AB4-0002A5D5C51B"

        struct Debug {
            static let id = "000E"
            static let uuid = CBUUID(string: "00000000-\(id)\(common)")
            static let termUuid = CBUUID(string: "00000001-\(id)\(BlueUUID.common)")
            static let stdErrUuid = CBUUID(string: "00000002-\(id)\(BlueUUID.common)")
        }

        struct Config {
            static let id = "000F"
            static let uuid = CBUUID(string: "00000000-\(id)\(common)")
            static let configControlUuid = CBUUID(string: "00000001-\(id)\(BlueUUID.common)")
            static let featureCommandUuid = CBUUID(string: "00000002-\(id)\(BlueUUID.common)")
        }
        
        struct BlueNrg {
            static let otaUuid = "669A0C20-0008-A7BA-E311-0685C0F7978A"
        }
    }
}

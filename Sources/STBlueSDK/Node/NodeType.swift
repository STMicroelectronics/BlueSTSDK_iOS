//
//  NodeType.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public enum NodeType: UInt8 {
    case generic = 0x00
    case stevalWesu1 = 0x01
    case sensorTile = 0x02
    case blueCoin = 0x03
    case stEvalIDB008VX = 0x04
    case stEvalBCN002V1 = 0x05
    case sensorTileBox = 0x06
    case discoveryIOT01A = 0x07
    case stEvalSTWINKIT1 = 0x08
    case stEvalSTWINKT1B = 0x09
    case bL475eIot01A = 0x0A
    case bU585iIot02A = 0x0B
    case polaris = 0x0C
    case sensorTileBoxPro = 0x0D
    case stWinBox = 0x0E
    case proteus = 0x0F
    case stdesCBMLoRaBLE = 0x10
    case sensorTileBoxProB = 0x11
    case stWinBoxB = 0x12
    case nucleoF401RE = 0x7F
    case nucleoL476RG = 0x7E
    case nucleoL053R8 = 0x7D
    case nucleoF446RE = 0x7C
    case wbBoard = 0x81
    case wbOtaBoard = 0x86
    case nucleo = 0x80
    case wbaBoard = 0x8B
}

public extension NodeType {
    var stringValue: String {
        switch self {
        case .generic:
            return "GENERIC"
        case .stevalWesu1:
            return "STEVAL_WESU1"
        case .sensorTile:
            return "SensorTile"
        case .blueCoin:
            return "BlueCoin"
        case .stEvalIDB008VX:
            return "STEVAL_IDB008VX"
        case .stEvalBCN002V1:
            return "STEVAL_BCN002V1"
        case .sensorTileBox:
            return "SensorTile.Box"
        case .discoveryIOT01A:
            return "DISCOVERY_IOT01A"
        case .stEvalSTWINKIT1:
            return "STEVAL_STWINKIT1"
        case .stEvalSTWINKT1B:
            return "STEVAL_STWINKT1B"
        case .bL475eIot01A:
            return "DISCOVERY_IOT01A" // TODO: not defined in old Objective-C code
        case .bU585iIot02A:
            return "DISCOVERY_IOT02A"
        case .polaris:
            return "POLARIS"
        case .sensorTileBoxPro:
            return "SENSOR_TILE_BOX_PRO"
        case .stWinBox:
            return "STWIN_BOX"
        case .proteus:
            return "PROTEUS"
        case .stdesCBMLoRaBLE:
            return "STDES-CBMLoRaBLE"
        case .sensorTileBoxProB:
            return "SENSOR_TILE_BOX_PRO_B"
        case .stWinBoxB:
            return "STWIN_BOX_B"
        case .nucleoF401RE:
            return "NUCLEO_F401RE"
        case .nucleoL476RG:
            return "NUCLEO_L476RG"
        case .nucleoL053R8:
            return "NUCLEO_L053R8"
        case .nucleoF446RE:
            return "NUCLEO_F446RE"
        case .wbBoard:
            return "WB_BOARD"
        case .wbaBoard:
            return "WBA_BOARD"
        case .wbOtaBoard:
            return "WB_OTA_BOARD"
        case .nucleo:
            return "Nucleo"
        }
    }

    var imageName: String? {
        switch self {
        case .generic:
            return "generic_board"
        case .discoveryIOT01A:
            return "real_board_b_l475e_iot01bx"
        case .stevalWesu1:
            return "real_board_wesu"
        case .sensorTile:
            return "real_board_sensortile"
        case .sensorTileBox:
            return "real_board_sensortilebox"
        case .blueCoin:
            return "real_board_bluecoin"
        case .stEvalIDB008VX:
            return "logo_steval_idb008VX"
        case .stEvalBCN002V1:
            return "logo_steval_bnc002V1"
        case .stEvalSTWINKIT1:
            return "real_board_stwinkt1"
        case .stEvalSTWINKT1B:
            return "real_board_stwinkt1b"
        case .nucleo:
            return "real_board_nucleo"
        case .bL475eIot01A:
            return "real_board_b_l4s5i_iot01a"
        case .bU585iIot02A:
            return "real_board_b_l475e_iot01bx"
        case .polaris:
            return "real_board_astra"
        case .sensorTileBoxPro:
            return "real_board_sensortilebox_pro"
        case .stWinBox:
            return "real_board_stwinbx1"
        case .proteus:
            return "real_board_proteus"
        case .stdesCBMLoRaBLE:
            return "real_board_stysys_sbu06"
        case .sensorTileBoxProB:
            return "real_board_sensortilebox_pro"
        case .stWinBoxB:
            return "real_board_stwinbx1"
        case .wbaBoard:
            return "real_board_wba"
        case .nucleoF401RE, .nucleoL476RG, .nucleoL053R8, .nucleoF446RE:
            return "real_board_nucleo"
        case .wbBoard:
            return "real_board_pnucleo_wb55"
        default:
            return "generic_board"
        }
    }
    
    var schemaImageName: String? {
        switch self {
        case .nucleo, .nucleoF401RE, .nucleoL053R8, .nucleoL476RG, .nucleoF446RE:
            return "schema_nucleo"
        case .sensorTile:
            return "schema_sensorTile"
        case .sensorTileBox:
            return "schema_sensorTileBox"
        case .blueCoin:
            return "schema_blueCoin"
        case .stEvalBCN002V1:
            return "schema_BlueNRGTile"
        default:
            return "schema_blueCoin"
        }
    }
}

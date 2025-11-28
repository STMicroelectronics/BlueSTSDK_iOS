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
    case astra = 0x0C
    case sensorTileBoxPro = 0x0D
    case stWinBox = 0x0E
    case proteus = 0x0F
    case stdesCBMLoRaBLE = 0x10
    case sensorTileBoxProB = 0x11
    case stWinBoxB = 0x12
    case sensorTileBoxProC = 0x13
    
    case robKit1 = 0xC3
    
    case nucleoF401RE = 0x7F
    case nucleoL476RG = 0x7E
    case nucleoL053R8 = 0x7D
    case nucleoF446RE = 0x7C
    case nucleoU575ZIQ = 0x7B
    case nucleoU5A5ZJQ = 0x7A
    
    case nucleo = 0x80
    
    //WB boards ex range 0x81->0x86
    case wb55NucleoBoard = 0x81
    case stm32wb5mmDkBoard = 0x82
    case wb55UsbDoungleBoard = 0x83
    case wb15CCNucleoBoard = 0x84
    case wb1mWpan1Board = 0x85
    case wbOtaBoard = 0x86
    
    //WBA boards ex range 0x8B -> 0x8C
    case wba55CGNucleoBoard = 0x8B
    case stm32Wba55gDk1Board = 0x8C
    case nucleoWB0X = 0x8D
    case wba65RiNucleoBoard = 0x8E
    case wb05NucleoBoard = 0x8F
    case wba2NucleoBoard = 0x90
    
    case wba5mWpanBoard = 0x91
    case stm32wba65iDk1Board = 0x92
    case st67w6x = 0x9A
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
            return "DISCOVERY_IOT01A"
        case .bU585iIot02A:
            return "DISCOVERY_IOT02A"
        case .astra:
            return "ASTRA"
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
        case .sensorTileBoxProC:
            return "SENSOR_TILE_BOX_PRO_C"
        case .robKit1:
            return "ROBKIT1"
        case .nucleoF401RE:
            return "NUCLEO_F401RE"
        case .nucleoL476RG:
            return "NUCLEO_L476RG"
        case .nucleoL053R8:
            return "NUCLEO_L053R8"
        case .nucleoF446RE:
            return "NUCLEO_F446RE"
        case .wb55NucleoBoard:
            return "WB55_NUCLEO_BOARD"
        case .wba55CGNucleoBoard:
            return "WB55CG_NUCLEO_BOARD"
        case .wbOtaBoard:
            return "WB_OTA_BOARD"
        case .nucleoWB0X:
            return "STM32WB09"
        case .nucleo:
            return "Nucleo"
        case .nucleoU575ZIQ:
            return "NUCLEO_U575ZIQ"
        case .nucleoU5A5ZJQ:
            return "NUCLEO_U5A5ZJQ"
        case .stm32wb5mmDkBoard:
            return "STM32WB5MM_DK"
        case .wb55UsbDoungleBoard:
            return "WB55_USB_DONGLE_BOARD"
        case .wb15CCNucleoBoard:
            return "WB15CC_NUCLEO_BOARD"
        case .wb1mWpan1Board:
            return "B_WB1M_WPAN1"
        case .stm32Wba55gDk1Board:
            return "STM32WBA55G_DK1"
        case .wba65RiNucleoBoard:
            return "WBA65RI_NUCLEO_BOARD"
        case .wb05NucleoBoard:
            return "WB05_NUCLEO_BOARD"
        case .wba2NucleoBoard:
            return "WBA2_NUCLEO_BOARD"
        case .wba5mWpanBoard:
            return "B_WBA5M_WPAN"
        case .stm32wba65iDk1Board:
            return "STM32WBA65I_DK1"
        case .st67w6x:
            return "ST67W6x"
        }
    }
    
    var friendlyName: String {
        switch self {
        case .generic:
            return "Generic"
        case .stevalWesu1:
            return "WESU"
        case .sensorTile:
            return "SensorTile"
        case .blueCoin:
            return "BlueCoin"
        case .stEvalIDB008VX:
            return "Steval IDB008VX"
        case .stEvalBCN002V1:
            return "Steval BCN002V1"
        case .sensorTileBox:
            return "SensorTile.box"
        case .discoveryIOT01A:
            return "Discovery-IOT01A"
        case .stEvalSTWINKIT1:
            return "STWIN kit"
        case .stEvalSTWINKT1B:
            return "STWIN kit"
        case .bL475eIot01A:
            return "Discovery IoT01A"
        case .bU585iIot02A:
            return "Discovery IoT02A"
        case .astra:
            return "Astra"
        case .sensorTileBoxPro:
            return "SensorTile.box PRO"
        case .stWinBox:
            return "STWIN.box"
        case .proteus:
            return "Proteus"
        case .stdesCBMLoRaBLE:
            return "CBMLoRaBLE"
        case .sensorTileBoxProB:
            return "SensorTile.box PRO"
        case .stWinBoxB:
            return "STWIN.box"
        case .sensorTileBoxProC:
            return "SensorTile.box PRO"
        case .robKit1:
            return "ROBKIT1"
        case .nucleoF401RE:
            return "Nucleo F401RE"
        case .nucleoL476RG:
            return "Nucleo L476RG"
        case .nucleoL053R8:
            return "Nucleo L053R8"
        case .nucleoF446RE:
            return "Nucleo F446RE"
        case .wb55NucleoBoard:
            return "Nucleo-WB55"
        case .wba55CGNucleoBoard:
            return "WB55CG NUCLEO"
        case .wbOtaBoard:
            return "WB Ota Board"
        case .nucleoWB0X:
            return "NUCLEO-WB0X Ultra-Low-Power"
        case .nucleo:
            return "Nucleo"
        case .nucleoU575ZIQ:
            return "Nucleo U575ZI-Q"
        case .nucleoU5A5ZJQ:
            return "Nucleo U5A5ZJ-Q"
        case .stm32wb5mmDkBoard:
            return "STM32WB5MM DK"
        case .wb55UsbDoungleBoard:
            return "USB-Dongle-WB55"
        case .wb15CCNucleoBoard:
            return "Nucleo-WB15"
        case .wb1mWpan1Board:
            return "WB1M"
        case .stm32Wba55gDk1Board:
            return "WBA 55G DK1"
        case .wba65RiNucleoBoard:
            return "Nucleo-WBA65 RI"
        case .wb05NucleoBoard:
            return "Nucleo-WB05"
        case .wba2NucleoBoard:
            return "Nucleo-WBA2"
        case .wba5mWpanBoard:
            return "Nucleo-WBA5M"
        case .stm32wba65iDk1Board:
            return "Nucleo-WBA65I"
        case .st67w6x:
            return "ST67W6x"
        }
    }

    var imageName: String? {
        switch self {
        case .generic, .wba2NucleoBoard:
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
        case .astra:
            return "real_board_astra"
        case .sensorTileBoxPro, .sensorTileBoxProB, .sensorTileBoxProC:
            return "real_board_sensortilebox_pro"
        case .stWinBox, .stWinBoxB:
            return "real_board_stwinbx1"
        case .proteus:
            return "real_board_proteus"
        case .stdesCBMLoRaBLE:
            return "real_board_stysys_sbu06"
        case .robKit1:
            return "real_board_robkit1"
        case .wba55CGNucleoBoard:
            return "real_board_nucleo_wba5x"
        case .nucleoF401RE, .nucleoL476RG, .nucleoL053R8, .nucleoF446RE:
            return "real_board_nucleo"
        case .wb55NucleoBoard:
            return "real_board_nucleo_wb55"
        case .nucleoWB0X:
            return "real_board_nucleo_wb0x"
        case .nucleoU575ZIQ,
                .nucleoU5A5ZJQ:
            return "real_board_nucleo_u5"
        case .stm32wb5mmDkBoard:
           return "real_board_discovery_kit_wb5m"
        case .wb55UsbDoungleBoard:
            return "real_board_usb_dongle_wb55"
        case .wb15CCNucleoBoard:
            return "real_board_nucleo_wb15"
        case .wb1mWpan1Board:
            return "real_board_discovery_kit_wb1m"
        case .wbOtaBoard:
            return "generic_board"
        case .stm32Wba55gDk1Board:
            return "real_board_discovery_kit_wba"
        case .wba65RiNucleoBoard:
            return "real_board_nucleo_wba6"
        case .wb05NucleoBoard:
            return "real_board_nucleo_wb05kn1"
        case .wba5mWpanBoard:
            return "real_board_wba5m_wpan"
        case .stm32wba65iDk1Board:
            return "real_board_wba651_dk1"
        case .st67w6x:
            return "real_board_nucleo_67w61m1"
        }
    }
    
    var sdCardImageName: String? {
        switch self {
        case .sensorTileBoxPro:
            return "img_sd_sensortileboxpro"
        case .sensorTileBoxProB:
            return "img_sd_sensortileboxpro"
        case .sensorTileBoxProC:
            return "img_sd_sensortileboxpro"
        case .stWinBox:
            return "img_sd_stwinbx1"
        case .stWinBoxB:
            return "img_sd_stwinbx1"
        case .stEvalSTWINKIT1:
            return "img_sd_stwinkt1"
        case .stEvalSTWINKT1B:
            return "img_sd_stwinkt1"
        default:
            return nil
        }
    }
    
    var schemaImageName: String? {
        switch self {
        case .nucleo, .nucleoF401RE, .nucleoL053R8, .nucleoL476RG, .nucleoF446RE, .nucleoU575ZIQ, .nucleoU5A5ZJQ:
            return "schema_nucleo"
        case .sensorTile:
            return "schema_sensorTile"
        case .sensorTileBox:
            return "schema_sensorTileBox"
        case .sensorTileBoxPro:
            return "schema_sensorTileBoxPro"
        case .sensorTileBoxProB:
            return "schema_sensorTileBoxPro"
        case .sensorTileBoxProC:
            return "schema_sensorTileBoxPro"
        case .blueCoin:
            return "schema_blueCoin"
        case .stEvalBCN002V1:
            return "schema_BlueNRGTile"
        default:
            return "schema_blueCoin"
        }
    }
    
    var family: NodeFamily {
        switch self {
        case .sensorTile,
             .wb05NucleoBoard,
             .blueCoin,
             .sensorTileBox,
             .stEvalSTWINKIT1,
             .stEvalSTWINKT1B,
             .sensorTileBoxPro,
             .sensorTileBoxProB,
             .sensorTileBoxProC,
             .stWinBox,
             .stWinBoxB,
             .robKit1:
            return NodeFamily.blueNRGFamily
            
        case .discoveryIOT01A,
             .bL475eIot01A,
             .bU585iIot02A:
            return NodeFamily.iotFamily
            
        case .astra,
             .stdesCBMLoRaBLE,
             .proteus:
            return NodeFamily.wbBasedFamily
            
        case .nucleo,
             .nucleoF401RE,
             .nucleoL476RG,
             .nucleoL053R8,
             .nucleoF446RE,
             .nucleoU575ZIQ,
             .nucleoU5A5ZJQ:
            return NodeFamily.nucleoFamily
            
        case .wb55NucleoBoard,
             .stm32wb5mmDkBoard,
             .wb55UsbDoungleBoard,
             .wb15CCNucleoBoard,
             .wb1mWpan1Board,
             .wbOtaBoard:
            return NodeFamily.wbFamily
            
        case .wba55CGNucleoBoard,
             .stm32Wba55gDk1Board,
             .stm32wba65iDk1Board,
             .wba65RiNucleoBoard,
             .wba2NucleoBoard,
             .st67w6x:
            return NodeFamily.wbaFamily
            
        case .generic,
             .nucleoWB0X,
             .stevalWesu1,
             .stEvalIDB008VX,
             .stEvalBCN002V1:
            return NodeFamily.otherFamily
            
        case .wba5mWpanBoard:
            return NodeFamily.wbNotYetSupported
        }
    }

    var isWifiPresent: Bool {
        switch self {
            case .sensorTileBoxPro,
                .sensorTileBoxProB,
                .sensorTileBoxProC,
                .stEvalSTWINKIT1,
                .stEvalSTWINKT1B:
            return false
        default:
            return true
		}
	}
}

public struct NodeMapper {
    private static let apiNameToNodeType: [String: NodeType] = [
        "steval-stwinkt1b": .stEvalSTWINKT1B,
        "steval-stwinbx1": .stWinBox,
        "steval-mkboxpro": .sensorTileBoxPro
    ]
    
    public static func nodeType(fromApiNodeName apiNodeName: String) -> NodeType? {
        guard let nodeType = apiNameToNodeType[apiNodeName] else {
            return nil
        }
        return nodeType
    }
}

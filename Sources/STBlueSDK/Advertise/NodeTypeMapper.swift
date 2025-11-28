//
//  NodeTypeMapper.swift
//
//  Copyright (c) 2025 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class NodeTypeMapper {
    public static func getNodeType(deviceId: UInt8, protocolVersion: UInt8) -> NodeType {
        if protocolVersion == 0x01 {
            //SDK V1
            switch deviceId {
            case 0x00:
                return .generic
            case 0x01:
                return .stevalWesu1
            case 0x02:
                return .sensorTile
            case 0x03:
                return .blueCoin
            case 0x04:
                return .stEvalIDB008VX
            case 0x05:
                return .stEvalBCN002V1
            case 0x06:
                return .sensorTileBox
            case 0x07:
                return .discoveryIOT01A
            case 0x08:
                return .stEvalSTWINKIT1
            case 0x09:
                return .stEvalSTWINKT1B
            case 0x0A:
                return .bL475eIot01A
            case 0x0B:
                return .bU585iIot02A
            case 0x0C:
                return .astra
            case 0x0D:
                return .sensorTileBoxPro
            case 0x0E:
                return .stWinBox
            case 0x0F:
                return .proteus
            case 0x10:
                return .stdesCBMLoRaBLE
            case 0x11:
                return .sensorTileBoxProB
            case 0x12:
                return .stWinBoxB
            case 0x13:
                return .sensorTileBoxProC
            case 0xC3:
                return .robKit1
            case 0x80:
                return .nucleo
            case 0x7F:
                return .nucleoF401RE
            case 0x7E:
                return .nucleoL476RG
            case 0x7D:
                return .nucleoL053R8
            case 0x7C:
                return .nucleoF446RE
            case 0x7B:
                return .nucleoU575ZIQ
            case 0x7A:
                return .nucleoU5A5ZJQ
            case 0x8D:
                return .nucleoWB0X
            case 0x8E:
                return .wba65RiNucleoBoard
            case 0x8F:
                return .wb05NucleoBoard
            case 0x90:
                return .wba2NucleoBoard
            case 0x91:
                return .wba5mWpanBoard
            case 0x92:
                return .stm32wba65iDk1Board
            case 0x9A:
                return .st67w6x
            case 0x86:
                return .wbOtaBoard
            case 0x81...0x8A:
                return .wb55NucleoBoard
            case 0x8B...0x8C:
                return .wba55CGNucleoBoard
            default:
                return .generic
            }
        } else {
            //SDK V2
            switch deviceId {
            case 0x00:
                return .generic
            case 0x01:
                return .stevalWesu1
            case 0x02:
                return .sensorTile
            case 0x03:
                return .blueCoin
            case 0x04:
                return .stEvalIDB008VX
            case 0x05:
                return .stEvalBCN002V1
            case 0x06:
                return .sensorTileBox
            case 0x07:
                return .discoveryIOT01A
            case 0x08:
                return .stEvalSTWINKIT1
            case 0x09:
                return .stEvalSTWINKT1B
            case 0x0A:
                return .bL475eIot01A
            case 0x0B:
                return .bU585iIot02A
            case 0x0C:
                return .astra
            case 0x0D:
                return .sensorTileBoxPro
            case 0x0E:
                return .stWinBox
            case 0x0F:
                return .proteus
            case 0x10:
                return .stdesCBMLoRaBLE
            case 0x11:
                return .sensorTileBoxProB
            case 0x12:
                return .stWinBoxB
            case 0x13:
                return .sensorTileBoxProC
            case 0xC3:
                return .robKit1
            case 0x80:
                return .nucleo
            case 0x7F:
                return .nucleoF401RE
            case 0x7E:
                return .nucleoL476RG
            case 0x7D:
                return .nucleoL053R8
            case 0x7C:
                return .nucleoF446RE
            case 0x7B:
                return .nucleoU575ZIQ
            case 0x7A:
                return .nucleoU5A5ZJQ
                
            //WB boards range 0x81->0x86
            case 0x81:
                return .wb55NucleoBoard
            case 0x82:
                return .stm32wb5mmDkBoard
            case 0x83:
                return .wb55UsbDoungleBoard
            case 0x84:
                return .wb15CCNucleoBoard
            case 0x85:
                return .wb1mWpan1Board
            case 0x86:
                return .wbOtaBoard
                
           //WBA5 boards  range 0x8B -> 0x8C
            case 0x8B:
                return .wba55CGNucleoBoard
            case 0x8C:
                return .stm32Wba55gDk1Board
            case 0x8D:
                return .nucleoWB0X
            case 0x8E:
                return .wba65RiNucleoBoard
            case 0x8F:
                return .wb05NucleoBoard
                
            case 0x90:
                return .wba2NucleoBoard
            case 0x91:
                return .wba5mWpanBoard
            case 0x92:
                return .stm32wba65iDk1Board
            case 0x9A:
                return .st67w6x
                
            default:
                return .generic
            }
        }
    }
}

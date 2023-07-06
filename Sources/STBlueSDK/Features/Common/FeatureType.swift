//
//  FeatureType.swift
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

public enum FeatureType: Equatable {
    case standard(identifier: UInt32)
    case tileBox(identifier: UInt32)
    case extended(identifier: UInt32)
    case generalPurpose(identifier: UInt32)
    
    case externalStandard(identifier: UInt32)
    case externalSTM32WBOta(identifier: UInt32)
    case externalBlueNRGOta(identifier: UInt32)
    case externalPeer2Peer(identifier: UInt32)
    
    private struct Mask {
        internal struct Standard {
            static let adpcmAudioSync: UInt32 = 0x40000000
            static let switchOnOff: UInt32 = 0x20000000
            static let directionOfArrival: UInt32 = 0x10000000
            static let adpcmAudio: UInt32 = 0x08000000
            static let micLevel: UInt32 = 0x04000000
            static let proximity: UInt32 = 0x02000000
            static let luminosity: UInt32 = 0x01000000
            static let acceleration: UInt32 = 0x00800000
            static let gyroscope: UInt32 = 0x00400000
            static let magnetometer: UInt32 = 0x00200000
            static let pressure: UInt32 = 0x00100000
            static let humidity: UInt32 = 0x00080000
            static let temperatureA: UInt32 = 0x00040000
            static let battery: UInt32 = 0x00020000
            static let temperatureB: UInt32 = 0x00010000
            static let coSensor: UInt32 = 0x00008000
            static let sdLogging: UInt32 = 0x00001000
            static let beamForming: UInt32 = 0x00000800
            static let accelerationEvent: UInt32 = 0x00000400
            static let freeFall: UInt32 = 0x00000200
            static let sensorFusionCompact: UInt32 = 0x00000100
            static let sensorFusion: UInt32 = 0x00000080
            static let motionIntensity: UInt32 = 0x00000020
            static let compass: UInt32 = 0x00000040
            static let activity: UInt32 = 0x00000010
            static let carryPosition: UInt32 = 0x00000008
            static let proximityGesture: UInt32 = 0x00000004
            static let memsGesture: UInt32 = 0x00000002
            static let pedometer: UInt32 = 0x00000001
            static let fftAmplitude: UInt32 = 0x80000000
            static let eulerAngle: UInt32 = 0x00004000
        }
        
        internal struct TileBox {
            static let memsNorm: UInt32 = 0x10000000
            static let audioClassification: UInt32 = 0x02000000
            static let eventCounter: UInt32 = 0x00000200
        }
        
        internal struct Extended {
            static let opusAudio: UInt32 = 0x00000001
            static let opusAudioConf: UInt32 = 0x00000002
            static let audioClassification: UInt32 = 0x00000003
            static let aiLogging: UInt32 = 0x00000004
            static let fftAmplitude: UInt32 = 0x00000005
            static let motorTimeParameters: UInt32 = 0x00000006
            static let predictiveSpeedStatus: UInt32 = 0x00000007
            static let predictiveAccelerationStatus: UInt32 = 0x00000008
            static let predictiveFrequencyDomainStatus: UInt32 = 0x00000009
            static let motionAlgorithm: UInt32 = 0x0000000A
            static let eulerAngle: UInt32 = 0x0000000D
            static let fitnessActivity: UInt32 = 0x0000000E
            static let machineLearningCore: UInt32 = 0x0000000F
            static let finiteStateMachine: UInt32 = 0x00000010
            static let highSpeedDataLog: UInt32 = 0x00000011
            static let tofMultiObject: UInt32 = 0x00000013
            static let extendedConfiguration: UInt32 = 0x00000014
            static let colorAmbientLight: UInt32 = 0x00000015
            // the 0x16 is reserved for BlueSTSDKFeatureQVAR
            static let stredl: UInt32 = 0x00000017
            static let gnss: UInt32 = 0x00000018
            static let neaiAnomalyDetection: UInt32 = 0x00000019
            static let neaiClassification: UInt32 = 0x0000001A
            static let pnpLike: UInt32 = 0x0000001B
            // the 0x1C is reserved for BlueSTSDKFeaturePiano
            static let eventCounter: UInt32 = 0x0000001D
            // the 0x1E is reserved for Quasar
            static let gestureNavigation: UInt32 = 0x0000001F
            static let jsonNfc: UInt32 = 0x00000020
            // the 0x21 is reserved for FeatureMemsNorm
            // the 0x22 is reserved for FeatureBinaryContent
        }
        
        internal struct External {
            internal struct Stm32 {
                static let rebootOtaMode: UInt32 = 0x0000FE11
                static let otaControl: UInt32 = 0x0000FE22
                static let otaWillReboot: UInt32 = 0x0000FE23
                static let otaUpload: UInt32 = 0x0000FE24
            }
            
            internal struct BlueNrg {
                static let otaMemoryInfo: UInt32 = 0x122E8CC0
                static let otaSettings: UInt32 = 0x210F99F0
                static let otaDataTransfer: UInt32 = 0x2691AA80
                static let otaAck: UInt32 = 0x2BDC5760
            }
            
            internal struct Peer2Peer {
                static let controlledLed: UInt32 = 0x0000FE41
                static let stm32SwitchStatus: UInt32 = 0x0000FE42
                static let stm32NetworkStatus: UInt32 = 0x0000FE51
            }
            
            internal static let heartRate: UInt32 = 0x00002a37
    
        }
    }
    
    private static let defaultFeatureTypes: [FeatureType] = [
        .standard(identifier: Mask.Standard.adpcmAudioSync),
        .standard(identifier: Mask.Standard.switchOnOff),
        .standard(identifier: Mask.Standard.directionOfArrival),
        .standard(identifier: Mask.Standard.adpcmAudio),
        .standard(identifier: Mask.Standard.micLevel),
        .standard(identifier: Mask.Standard.proximity),
        .standard(identifier: Mask.Standard.luminosity),
        .standard(identifier: Mask.Standard.acceleration),
        .standard(identifier: Mask.Standard.gyroscope),
        .standard(identifier: Mask.Standard.magnetometer),
        .standard(identifier: Mask.Standard.pressure),
        .standard(identifier: Mask.Standard.humidity),
        .standard(identifier: Mask.Standard.temperatureA),
        .standard(identifier: Mask.Standard.battery),
        .standard(identifier: Mask.Standard.temperatureB),
        .standard(identifier: Mask.Standard.coSensor),
        .standard(identifier: Mask.Standard.sdLogging),
        .standard(identifier: Mask.Standard.beamForming),
        .standard(identifier: Mask.Standard.accelerationEvent),
        .standard(identifier: Mask.Standard.freeFall),
        .standard(identifier: Mask.Standard.sensorFusionCompact),
        .standard(identifier: Mask.Standard.sensorFusion),
        .standard(identifier: Mask.Standard.motionIntensity),
        .standard(identifier: Mask.Standard.compass),
        .standard(identifier: Mask.Standard.activity),
        .standard(identifier: Mask.Standard.carryPosition),
        .standard(identifier: Mask.Standard.proximityGesture),
        .standard(identifier: Mask.Standard.memsGesture),
        .standard(identifier: Mask.Standard.pedometer)
    ];
    
    private static let sensorTileBoxFeatureTypes: [FeatureType] = [
        .standard(identifier: Mask.Standard.fftAmplitude),
        .standard(identifier: Mask.Standard.adpcmAudioSync),
        .standard(identifier: Mask.Standard.switchOnOff),
        .standard(identifier: Mask.Standard.adpcmAudio),
        .standard(identifier: Mask.Standard.micLevel),
        .standard(identifier: Mask.Standard.luminosity),
        .standard(identifier: Mask.Standard.acceleration),
        .standard(identifier: Mask.Standard.gyroscope),
        .standard(identifier: Mask.Standard.magnetometer),
        .standard(identifier: Mask.Standard.pressure),
        .standard(identifier: Mask.Standard.humidity),
        .standard(identifier: Mask.Standard.temperatureA),
        .standard(identifier: Mask.Standard.battery),
        .standard(identifier: Mask.Standard.temperatureB),
        .standard(identifier: Mask.Standard.eulerAngle),
        .standard(identifier: Mask.Standard.sdLogging),
        .standard(identifier: Mask.Standard.accelerationEvent),
        .standard(identifier: Mask.Standard.sensorFusionCompact),
        .standard(identifier: Mask.Standard.sensorFusion),
        .standard(identifier: Mask.Standard.compass),
        .standard(identifier: Mask.Standard.motionIntensity),
        .standard(identifier: Mask.Standard.activity),
        .standard(identifier: Mask.Standard.carryPosition),
        .standard(identifier: Mask.Standard.proximityGesture),
        .standard(identifier: Mask.Standard.memsGesture),
        .standard(identifier: Mask.Standard.pedometer),
        
        .tileBox(identifier: Mask.TileBox.memsNorm),
        .tileBox(identifier: Mask.TileBox.audioClassification),
        .tileBox(identifier: Mask.TileBox.eventCounter)
    ]
    
    private static let bleStarNucleoFeatureTypes: [FeatureType] = [
        .standard(identifier: Mask.Standard.switchOnOff),
        .standard(identifier: Mask.Standard.pressure),
        .standard(identifier: Mask.Standard.humidity),
        .standard(identifier: Mask.Standard.temperatureA)
    ]
    
    internal static let extentedTypes: [FeatureType] = [
        .extended(identifier: Mask.Extended.opusAudio),
        .extended(identifier: Mask.Extended.opusAudioConf),
        .extended(identifier: Mask.Extended.audioClassification),
        .extended(identifier: Mask.Extended.aiLogging),
        .extended(identifier: Mask.Extended.fftAmplitude),
        .extended(identifier: Mask.Extended.motorTimeParameters),
        .extended(identifier: Mask.Extended.predictiveSpeedStatus),
        .extended(identifier: Mask.Extended.predictiveAccelerationStatus),
        .extended(identifier: Mask.Extended.predictiveFrequencyDomainStatus),
        .extended(identifier: Mask.Extended.motionAlgorithm),
        .extended(identifier: Mask.Extended.eulerAngle),
        .extended(identifier: Mask.Extended.fitnessActivity),
        .extended(identifier: Mask.Extended.machineLearningCore),
        .extended(identifier: Mask.Extended.finiteStateMachine),
        .extended(identifier: Mask.Extended.highSpeedDataLog),
        .extended(identifier: Mask.Extended.tofMultiObject),
        .extended(identifier: Mask.Extended.extendedConfiguration),
        .extended(identifier: Mask.Extended.colorAmbientLight),
        .extended(identifier: Mask.Extended.stredl),
        .extended(identifier: Mask.Extended.gnss),
        .extended(identifier: Mask.Extended.neaiAnomalyDetection),
        .extended(identifier: Mask.Extended.neaiClassification),
        .extended(identifier: Mask.Extended.pnpLike),
        .extended(identifier: Mask.Extended.eventCounter),
        .extended(identifier: Mask.Extended.gestureNavigation),
        .extended(identifier: Mask.Extended.jsonNfc)
    ]
    
    internal static let externalTypes: [FeatureType] = [
        .externalStandard(identifier: Mask.External.heartRate),
        .externalSTM32WBOta(identifier: Mask.External.Stm32.rebootOtaMode),
        .externalSTM32WBOta(identifier: Mask.External.Stm32.otaControl),
        .externalSTM32WBOta(identifier: Mask.External.Stm32.otaWillReboot),
        .externalSTM32WBOta(identifier: Mask.External.Stm32.otaUpload),
        .externalBlueNRGOta(identifier: Mask.External.BlueNrg.otaMemoryInfo),
        .externalBlueNRGOta(identifier: Mask.External.BlueNrg.otaSettings),
        .externalBlueNRGOta(identifier: Mask.External.BlueNrg.otaDataTransfer),
        .externalBlueNRGOta(identifier: Mask.External.BlueNrg.otaAck),
        .externalPeer2Peer(identifier: Mask.External.Peer2Peer.controlledLed),
        .externalPeer2Peer(identifier: Mask.External.Peer2Peer.stm32SwitchStatus),
        .externalPeer2Peer(identifier: Mask.External.Peer2Peer.stm32NetworkStatus)
    ]
    
}

public extension FeatureType {
    var mask: UInt32 {
        switch self {
        case .standard(let identifier), .tileBox(let identifier), .extended(let identifier), .generalPurpose(let identifier), .externalStandard(let identifier), .externalSTM32WBOta(let identifier), .externalBlueNRGOta(let identifier), .externalPeer2Peer(let identifier):
            return identifier
        }
    }
    
    var uuid: CBUUID {
        switch self {
        case .generalPurpose(let identifier):
            return CBUUID.uuid(identifier, suffix: BlueUUID.Feature.generalPurpose)
        case .extended(let identifier):
            return CBUUID.uuid(identifier, suffix: BlueUUID.Feature.extended)
        case .externalStandard(let identifier):
            return CBUUID.uuid(identifier, suffix: BlueUUID.Feature.External.standard)
        case .externalSTM32WBOta(let identifier):
            return CBUUID.uuid(identifier, suffix: BlueUUID.Feature.External.stm32WBOta)
        case .externalBlueNRGOta(let identifier):
            return CBUUID.uuid(identifier, suffix: BlueUUID.Feature.External.blueNRGOta)
        case .externalPeer2Peer(let identifier):
            return CBUUID.uuid(identifier, suffix: BlueUUID.Feature.External.peerToPeer)
        case .standard(let identifier),
                .tileBox(let identifier):
            return CBUUID.uuid(identifier, suffix: BlueUUID.Feature.base)
        }
        
    }

    static func featureClasses(from uuids: [String]) -> [ Feature.Type ] {

        var list = Set<FeatureType>()

//        08000000-0001-11E1-AC36-0002A5D5C51B

        FeatureType.defaultFeatureTypes.filter { uuids.contains($0.uuid.uuidString.lowercased()) }.forEach { type in
            list.insert(type)
        }

        FeatureType.sensorTileBoxFeatureTypes.filter { uuids.contains($0.uuid.uuidString.lowercased()) }.forEach { type in
            list.insert(type)
        }

        FeatureType.bleStarNucleoFeatureTypes.filter { uuids.contains($0.uuid.uuidString.lowercased()) }.forEach { type in
            list.insert(type)
        }

        FeatureType.extentedTypes.filter { uuids.contains($0.uuid.uuidString.lowercased()) }.forEach { type in
            list.insert(type)
        }

        FeatureType.externalTypes.filter { uuids.contains($0.uuid.uuidString.lowercased()) }.forEach { type in
            list.insert(type)
        }

        return Array(list.map({ $0.descriptor.featureClass }))
    }
    
    var descriptor: (identifier: UInt32, featureClass: (AnyObject & Feature & Initializable).Type) {
        switch self {
        case .generalPurpose(let identifier):
            return (identifier, GeneralPurposeFeature.self)
        case .standard(let identifier):
            switch identifier {
            case Mask.Standard.adpcmAudioSync: return (identifier, ADPCMAudioSyncFeature.self)
            case Mask.Standard.switchOnOff: return (identifier, SwitchFeature.self)
            case Mask.Standard.directionOfArrival: return (identifier, DirectionOfArrivalFeature.self)
            case Mask.Standard.adpcmAudio: return (identifier, ADPCMAudioFeature.self)
            case Mask.Standard.micLevel: return (identifier, MicLevelFeature.self)
            case Mask.Standard.proximity: return (identifier, ProximityFeature.self)
            case Mask.Standard.luminosity: return (identifier, LuminosityFeature.self)
            case Mask.Standard.acceleration: return (identifier, AccelerationFeature.self)
            case Mask.Standard.gyroscope: return (identifier, GyroscopeFeature.self)
            case Mask.Standard.magnetometer: return (identifier, MagnetometerFeature.self)
            case Mask.Standard.pressure: return (identifier, PressureFeature.self)
            case Mask.Standard.humidity: return (identifier, HumidityFeature.self)
            case Mask.Standard.temperatureA: return (identifier, TemperatureFeature.self)
            case Mask.Standard.battery: return (identifier, BatteryFeature.self)
            case Mask.Standard.temperatureB: return (identifier, TemperatureFeature.self)
            case Mask.Standard.coSensor: return (identifier, COSensorFeature.self)
            case Mask.Standard.sdLogging: return (identifier, SDLoggingFeature.self)
            case Mask.Standard.beamForming: return (identifier, BeamFormingFeature.self)
            case Mask.Standard.accelerationEvent: return (identifier, AccelerationEventFeature.self)
            case Mask.Standard.freeFall: return (identifier, FreeFallFeature.self)
            case Mask.Standard.sensorFusionCompact: return (identifier, SensorFusionCompactFeature.self)
            case Mask.Standard.sensorFusion: return (identifier, SensorFusionFeature.self)
            case Mask.Standard.motionIntensity: return (identifier, MotionIntensityFeature.self)
            case Mask.Standard.compass: return (identifier, CompassFeature.self)
            case Mask.Standard.activity: return (identifier, ActivityFeature.self)
            case Mask.Standard.carryPosition: return (identifier, CarryPositionFeature.self)
            case Mask.Standard.proximityGesture: return (identifier, ProximityGestureFeature.self)
            case Mask.Standard.memsGesture: return (identifier, MemsGestureFeature.self)
            case Mask.Standard.pedometer: return (identifier, PedometerFeature.self)
            case Mask.Standard.fftAmplitude: return (identifier, FFTAmplitudeFeature.self)
            case Mask.Standard.eulerAngle: return (identifier, EulerAngleFeature.self)
                
            default:
                return (identifier, UnkownFeature.self)
            }
        case .tileBox(let identifier):
            switch identifier {
            case Mask.TileBox.memsNorm: return (identifier, MemsNormFeature.self)
            case Mask.TileBox.audioClassification: return (identifier, AudioClassificationFeature.self)
            case Mask.TileBox.eventCounter: return (identifier, EventCounterFeature.self)
                
            default:
                return (identifier, UnkownFeature.self)
            }
        case .extended(let identifier):
            // TODO: specialize extrended feature class
            switch identifier {
            case Mask.Extended.opusAudio: return (identifier, OpusAudioFeature.self)
            case Mask.Extended.opusAudioConf: return (identifier, OpusAudioConfFeature.self)
            case Mask.Extended.audioClassification: return (identifier, AudioClassificationFeature.self)
            case Mask.Extended.aiLogging: return (identifier, AILoggingFeature.self)
            case Mask.Extended.fftAmplitude: return (identifier, FFTAmplitudeFeature.self)
            case Mask.Extended.motorTimeParameters: return (identifier, MotorTimeParametersFeature.self)
            case Mask.Extended.predictiveSpeedStatus: return (identifier, PredictiveSpeedStatusFeature.self)
            case Mask.Extended.predictiveAccelerationStatus: return (identifier, PredictiveAccelerationStatusFeature.self)
            case Mask.Extended.predictiveFrequencyDomainStatus: return (identifier, PredictiveFrequencyDomainStatusFeature.self)
            case Mask.Extended.motionAlgorithm: return (identifier, MotionAlgorithmFeature.self)
            case Mask.Extended.eulerAngle: return (identifier, EulerAngleFeature.self)
            case Mask.Extended.fitnessActivity: return (identifier, FitnessActivityFeature.self)
            case Mask.Extended.machineLearningCore: return (identifier, MachineLearningCoreFeature.self)
            case Mask.Extended.finiteStateMachine: return (identifier, FiniteStateMachineFeature.self)
            case Mask.Extended.highSpeedDataLog: return (identifier, HSDFeature.self)
            case Mask.Extended.tofMultiObject: return (identifier, ToFMultiObjectFeature.self)
            case Mask.Extended.extendedConfiguration: return (identifier, ExtendedConfigurationFeature.self)
            case Mask.Extended.colorAmbientLight: return (identifier, ColorAmbientLightFeature.self)
            case Mask.Extended.stredl: return (identifier, STREDLFeature.self)
            case Mask.Extended.gnss: return (identifier, GNSSFeature.self)
            case Mask.Extended.neaiAnomalyDetection: return (identifier, NEAIAnomalyDetectionFeature.self)
            case Mask.Extended.neaiClassification: return (identifier, NEAIClassificationFeature.self)
            case Mask.Extended.pnpLike: return (identifier, PnPLFeature.self)
            case Mask.Extended.eventCounter: return (identifier, EventCounterFeature.self)
            case Mask.Extended.gestureNavigation: return (identifier, GestureNavigationFeature.self)
            case Mask.Extended.jsonNfc: return (identifier, JsonNFCFeature.self)
            default:
                return (identifier, UnkownFeature.self)
            }
            
        case .externalSTM32WBOta(let identifier):
            switch identifier {
            case Mask.External.Stm32.rebootOtaMode: return (identifier, STM32WBRebootOtaModeFeature.self)
            case Mask.External.Stm32.otaControl: return (identifier, STM32WBOtaControlFeature.self)
            case Mask.External.Stm32.otaWillReboot: return (identifier, STM32WBOtaWillRebootFeature.self)
            case Mask.External.Stm32.otaUpload: return (identifier, STM32WBOtaUploadFeature.self)
            default:
                return (identifier, UnkownFeature.self)
            }
            
        case .externalBlueNRGOta(let identifier):
            switch identifier {
            case Mask.External.BlueNrg.otaMemoryInfo: return (identifier, BlueNRGOtaMemoryInfoFeature.self)
            case Mask.External.BlueNrg.otaSettings: return (identifier, BlueNRGOtaSettingsFeature.self)
            case Mask.External.BlueNrg.otaDataTransfer: return (identifier, BlueNRGOtaDataTransferFeature.self)
            case Mask.External.BlueNrg.otaAck: return (identifier, BlueNRGOtaAckFeature.self)
            default:
                return (identifier, UnkownFeature.self)
            }
            
        case .externalStandard(let identifier):
            switch identifier {
            case Mask.External.heartRate: return (identifier, HeartRateFeature.self)
            default:
                return (identifier, UnkownFeature.self)
            }
        case .externalPeer2Peer(let identifier):
            switch identifier {
            case Mask.External.Peer2Peer.controlledLed: return (identifier, ControlLedFeature.self)
            case Mask.External.Peer2Peer.stm32SwitchStatus: return (identifier, STM32SwitchStatusFeature.self)
            case Mask.External.Peer2Peer.stm32NetworkStatus: return (identifier, UnkownFeature.self)
            default:
                return (identifier, UnkownFeature.self)
            }
        }
    }
    
    static func feature(from mask: FeatureMask,
                        types: [FeatureType]) -> Feature? {
        for type in types {
            
            let descriptor = type.descriptor
            
            if descriptor.identifier & mask != 0 {
                return descriptor.featureClass.init(name: String(describing: descriptor.featureClass), type: type)
            }
        }
        
        return nil
    }
    
    static func nodeFeatureTypes(_ nodeType: NodeType) -> [FeatureType] {
        switch nodeType {
        case .sensorTileBox:
            return FeatureType.sensorTileBoxFeatureTypes
        case .nucleo:
            return FeatureType.bleStarNucleoFeatureTypes
        default:
            return FeatureType.defaultFeatureTypes
        }
    }
    
    static func feature(from mask: FeatureMask) -> Feature? {
        
        var allTypes = [FeatureType]()
        
        allTypes.append(contentsOf: FeatureType.sensorTileBoxFeatureTypes)
        allTypes.append(contentsOf: FeatureType.bleStarNucleoFeatureTypes)
        allTypes.append(contentsOf: FeatureType.defaultFeatureTypes)
        allTypes.append(contentsOf: FeatureType.extentedTypes)
        
        for type in allTypes {
            
            let descriptor = type.descriptor
            
            if descriptor.identifier & mask != 0 {
                return descriptor.featureClass.init(name: "", type: type)
            }
        }
        
        return nil
    }
}

extension FeatureType: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(uuid.uuidString)
    }
}

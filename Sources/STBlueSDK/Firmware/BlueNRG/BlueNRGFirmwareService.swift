//
//  BlueNRGFirmwareService.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal enum FirmwareUpgradeState {
    case empty
    case checkMemory(param: FirmwareUpgradeParam)
    case checkUpgradeParameters(settings: FirmwareUpgradeSettings, retry: Int)
    case startUpload(settings: FirmwareUpgradeSettings)
    case upload(settings: FirmwareUpgradeSettings, requestSequence: UInt16)
    case end(url: URL)
    case error(url: URL, error: FirmwareUpgradeError)
}

internal class BlueNRGFirmwareService: BaseFirmwareService {
    
    let memoryInfo: BlueNRGOtaMemoryInfoFeature
    let otaSettings: BlueNRGOtaSettingsFeature
    let dataTransfer: BlueNRGOtaDataTransferFeature
    let ack: BlueNRGOtaAckFeature
    
    var versioneDelegate: VersionInfoDelegate?
    var checkMemoryAddressDelegate: CheckMemoryAddressDelegate?
    var checkUpgradeSettingsDelegate :CheckUpgradeSettingsDelegate?
    var ackUpgradeFirmwareDelegate: AckUpgradeFirmwareDelegate?
    
    var nodeService: NodeService
    var maxDataLength: UInt {
        // -4 for the crc + sequence + ack
        let maxDataLenght = UInt(nodeService.node.mtu) - 4
        let (numberOfBlock,_) = maxDataLenght.quotientAndRemainder(dividingBy: 16)
        return 16 * numberOfBlock
    }
    
    var initialUpgradeParam: FirmwareUpgradeParam?
    
    var currentState: FirmwareUpgradeState {
        didSet {
            switch currentState {
            case .empty:
                break
            case .checkMemory(let param):
                readMemoryFeature(with: param)
            case .checkUpgradeParameters(let settings, let retry):
                readOtaSettingsFeature(with: settings, retry: retry)
            case .startUpload(let settings):
                enableNotificationForAckFeature(with: settings)
            case .upload(let settings, let requestSequence):
                upload(settings: settings, requestSequence: requestSequence)
            case .end(let file):
                guard let callback = callback else { return }
                callback.completion(file, nil)
            case .error(let file, let error):
                guard let callback = callback else { return }
                callback.completion(file, error)
            }
        }
    }
    
    init?(with nodeService: NodeService) {
        if let memoryInfo = nodeService.node.characteristics.first(with: BlueNRGOtaMemoryInfoFeature.self) as? BlueNRGOtaMemoryInfoFeature,
           let otaSettings = nodeService.node.characteristics.first(with: BlueNRGOtaSettingsFeature.self) as? BlueNRGOtaSettingsFeature,
           let dataTransfer = nodeService.node.characteristics.first(with: BlueNRGOtaDataTransferFeature.self) as? BlueNRGOtaDataTransferFeature,
           let ack = nodeService.node.characteristics.first(with: BlueNRGOtaAckFeature.self) as? BlueNRGOtaAckFeature {
            self.memoryInfo = memoryInfo
            self.otaSettings = otaSettings
            self.dataTransfer = dataTransfer
            self.ack = ack
            self.nodeService = nodeService
            self.currentState = .empty
        } else {
            return nil
        }
    }
    
    override func currentVersion(_ completion: @escaping FirmwareVersionCompletion) {
        
        BlueManager.shared.enableNotifications(for: nodeService.node,
                                               feature: self.memoryInfo)
        
        versioneDelegate = VersionInfoDelegate(completion: completion)
        
        guard let versioneDelegate = versioneDelegate else {
            return
        }
        
        BlueManager.shared.read(feature: memoryInfo,
                                for: nodeService.node,
                                delegate: versioneDelegate)
    }
    
    override func startLoading(with url: URL, type: FirmwareType, firmwareData: Data, callback: FirmwareUpgradeCallback) {
        
        super.startLoading(with: url, type: type, firmwareData: firmwareData, callback: callback)
        
        switch type {
        case .custom(let startSector, _, _):
            switch currentState {
            case .empty:
                initialUpgradeParam = FirmwareUpgradeParam(file: url,
                                                           baseAddress: startSector == nil ? nil : UInt32(startSector!),
                                                           packageSize: maxDataLength)
                
                guard let initialUpgradeParam = initialUpgradeParam else { return }
                
                currentState = .checkMemory(param: initialUpgradeParam)
            default:
                callback.completion(url, .unsupportedOperation)
            }
        default:
            callback.completion(url, .unsupportedOperation)
        }
    }
}

private extension BlueNRGFirmwareService {
    
    func readMemoryFeature(with param: FirmwareUpgradeParam) {
        
        checkMemoryAddressDelegate = CheckMemoryAddressDelegate(param: param) { [weak self] state in
            self?.currentState = state
        }
        
        guard let checkMemoryAddressDelegate = checkMemoryAddressDelegate else { return }
        
        BlueManager.shared.read(feature: memoryInfo,
                                for: nodeService.node,
                                delegate: checkMemoryAddressDelegate)
    }
    
    func readOtaSettingsFeature(with settings: FirmwareUpgradeSettings, retry: Int) {
        
        nodeService.write(value: settings.parameterData, for: otaSettings)
        
        checkUpgradeSettingsDelegate = CheckUpgradeSettingsDelegate(param: settings,
                                                                    currentRetry: retry,
                                                                    completion: { [weak self] state in
            self?.currentState = state
        })
        
        guard let checkUpgradeSettingsDelegate = checkUpgradeSettingsDelegate else { return }
        
        BlueManager.shared.read(feature: otaSettings,
                                for: nodeService.node,
                                delegate: checkUpgradeSettingsDelegate)
    }
    
    func enableNotificationForAckFeature(with settings: FirmwareUpgradeSettings) {
        guard let initialUpgradeParam = initialUpgradeParam else { return }
        
        ackUpgradeFirmwareDelegate = AckUpgradeFirmwareDelegate(settings: settings,
                                                                initialUpgradeParam: initialUpgradeParam,
                                                                completion: { [weak self] state in
            self?.currentState = state
        })
        
        guard let ackUpgradeFirmwareDelegate = ackUpgradeFirmwareDelegate else { return }
        
        BlueManager.shared.addDelegate(ackUpgradeFirmwareDelegate)
        
        BlueManager.shared.enableNotifications(for: nodeService.node, feature: ack)
    }
    
    func sendLastPackage(data: Data, sequence: UInt16, packageSize: Int) {
        var pckData = Data(count: packageSize)
        let fistByteToSend = Int(sequence)*packageSize
        let dataToSend = data.count - fistByteToSend
        //copy the values
        pckData[0..<dataToSend] = data[fistByteToSend...]
        
        guard let data = pckData.data(with: sequence, needAck: true, mtu: nodeService.node.mtu) else { return }
        nodeService.write(value: data, for: dataTransfer)
    }
    
    private func upload( settings: FirmwareUpgradeSettings, requestSequence: UInt16) {
        let lastSequenceId = requestSequence + UInt16(settings.ackInterval - 1)
        let intPackageSize = Int(settings.packageSize)
        
        guard let callback = callback else { return }
        
        callback.progress(settings.file, Int(requestSequence) * intPackageSize, settings.data.count)
        
        for seqId in requestSequence...lastSequenceId {
            let fistByteIndex = Int(seqId) * intPackageSize
            let lastByteIndex = fistByteIndex + intPackageSize
            
            if lastByteIndex>settings.data.count {
                sendLastPackage(data:settings.data, sequence:seqId,packageSize: intPackageSize)
                return
            }
            //else
            let data = settings.data[fistByteIndex..<lastByteIndex]
            guard let data = data.data(with: seqId, needAck: seqId == lastSequenceId, mtu: nodeService.node.mtu) else { return }
            nodeService.write(value: data, for: dataTransfer)
        }
    }
    
}

fileprivate extension Data {
    func data(with sequenceId: UInt16, needAck: Bool, mtu: Int) -> Data? {
        guard count + 4 <= mtu else {
            return nil
        }
        guard count % 16 == 0 else {
            return nil
        }
        var dataToSend = Data(capacity: count + 4)
        
        dataToSend.append(0) //crc
        dataToSend.append(contentsOf: self)
        dataToSend.append(needAck ? 1 : 0)
        
        Swift.withUnsafeBytes(of: sequenceId.littleEndian) { dataToSend.append(contentsOf: $0) }
        
        dataToSend[0] = dataToSend.xor
        
        return dataToSend
    }
}


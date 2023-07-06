//
//  AckUpgradeFirmwareDelegate.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal class AckUpgradeFirmwareDelegate: BlueDelegate {
    
    private static let maxErrorRetry = 4
    private static let ackTimeout: TimeInterval = 20.0
    
    private var numberOfWrongSequence = 0
    private var numberOfWrongWrite1 = 0
    private var numberOfWrongWrite2 = 0
    private var numberOfWrongCrc = 0
    
    private let settings: FirmwareUpgradeSettings
    private let initialUpgradeParam: FirmwareUpgradeParam
    private let completion: FirmwareUpgradeStateCompletion
    
    private let timerQueue: DispatchQueue
    private var currentTimeOut: DispatchWorkItem? = nil
    
    init(settings: FirmwareUpgradeSettings, initialUpgradeParam: FirmwareUpgradeParam, completion: @escaping FirmwareUpgradeStateCompletion) {
        timerQueue = DispatchQueue(label: "AckUpgradeFirmwareDelegate")
        self.settings = settings
        self.initialUpgradeParam = initialUpgradeParam
        self.completion = completion
    }

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {
        
    }

    func manager(_ manager: BlueManager, didDiscover node: Node) {
        
    }
    
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {
        
    }
    
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        
    }
    
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        if let ackFeature = feature as? BlueNRGOtaAckFeature {
            guard let ackData = ackFeature.sample?.data,
                  let expetedSequence = ackData.expetedSequence.value,
                  let error = ackData.error.value else {
                completion(.error(url: settings.file, error: .invalidFwFile))
                return
            }
            
            if error != .none {
                manageError(error, feature: feature, node: node, requestPacakge: expetedSequence)
            } else {
                manageSuccess(feature: feature, node: node, requestPacakge: expetedSequence)
            }
        }
    }
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        
    }
    
}

private extension AckUpgradeFirmwareDelegate {
    
    func isUploadCompleted(_ nextSequence: UInt16) -> Bool {
        return Int(nextSequence) * Int(settings.packageSize) >= settings.data.count
    }
    
    func resetErrorCount() {
        numberOfWrongCrc = 0
        numberOfWrongWrite2 = 0
        numberOfWrongWrite1 = 0
        numberOfWrongSequence = 0
    }
    
    func setupTimeoutTimer(with feature: Feature, node: Node) {
        currentTimeOut?.cancel()
        currentTimeOut = DispatchWorkItem { [weak self] in
            guard let self = self else { return }
            
            BlueManager.shared.removeDelegate(self)
            BlueManager.shared.disableNotifications(for: node, feature: feature)
            self.completion(.error(url: self.settings.file, error: .trasmissionError))
        }
        
        guard let currentTimeOut = currentTimeOut else { return }
        
        timerQueue.asyncAfter(deadline: .now() + AckUpgradeFirmwareDelegate.ackTimeout, execute: currentTimeOut)
    }
    
    func abortTransmission(with feature: Feature, node: Node) {
        currentTimeOut?.cancel()
        BlueManager.shared.removeDelegate(self)
        BlueManager.shared.disableNotifications(for: node, feature: feature)
    }
    
    func manageError( _ error: BlueNRGAckError, feature: Feature, node: Node, requestPacakge: UInt16) {
        switch error {
        case .writeFail_1:
            numberOfWrongWrite1 += 1
        case .writeFail_2:
            numberOfWrongWrite2 += 1
        case .wrongCrc:
            numberOfWrongCrc += 1
        case .wrongSequence:
            numberOfWrongSequence += 1
        default:
            break
        }
        
        if numberOfWrongCrc > AckUpgradeFirmwareDelegate.maxErrorRetry ||
            numberOfWrongWrite1 > AckUpgradeFirmwareDelegate.maxErrorRetry ||
            numberOfWrongWrite2 > AckUpgradeFirmwareDelegate.maxErrorRetry {
            abortTransmission(with: feature, node: node)
            completion(.error(url: settings.file, error: .trasmissionError))
        } else if numberOfWrongSequence > AckUpgradeFirmwareDelegate.maxErrorRetry {
            if requestPacakge == 0 { // the upload never starts
                abortTransmission(with: feature, node: node)
                //restart with the safe parameters
                
                completion(.checkMemory(param: FirmwareUpgradeParam.buildSafeParamFrom(param: initialUpgradeParam)))
            } else {
                abortTransmission(with: feature, node: node)
                completion(.error(url: settings.file, error: .trasmissionError))
            }
        } else {
            setupTimeoutTimer(with: feature, node: node)
            completion(.upload(settings: settings, requestSequence: requestPacakge))
        }
    }
    
    func manageSuccess(feature: Feature, node: Node, requestPacakge: UInt16) {
        if isUploadCompleted(requestPacakge) {
            BlueManager.shared.removeDelegate(self)
            BlueManager.shared.disableNotifications(for: node, feature: feature)
            currentTimeOut?.cancel()
            completion(.end(url: settings.file))
        } else {
            setupTimeoutTimer(with: feature, node: node)
            completion(.upload(settings: settings, requestSequence: requestPacakge))
        }
    }
}

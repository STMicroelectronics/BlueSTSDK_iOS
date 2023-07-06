//
//  CheckUpgradeSettingsDelegate.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal class CheckUpgradeSettingsDelegate: BlueDelegate {
    
    private static let maxReadRetry = 10
    private static let readDelay: TimeInterval = 0.1
    
    private let settings: FirmwareUpgradeSettings
    private let completion: FirmwareUpgradeStateCompletion
    
    private let currentRetry: Int
    
    init(param: FirmwareUpgradeSettings, currentRetry: Int, completion: @escaping FirmwareUpgradeStateCompletion) {
        self.settings = param
        self.currentRetry = currentRetry
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
        if let settingsFeature = feature as? BlueNRGOtaSettingsFeature {
            manager.removeDelegate(self)
            
            guard let settingsData = settingsFeature.sample?.data,
                  let ackInterval = settingsData.ackInterval.value,
                  let baseAddres = settingsData.baseAddress.value,
                  let imageSize = settingsData.imageSize.value else {
                completion(.error(url: settings.file, error: .trasmissionError))
                return
            }
            
            if ackInterval != settings.ackInterval ||
                baseAddres != settings.baseAddress ||
                imageSize != settings.uploadSize {
                if currentRetry + 1 > CheckUpgradeSettingsDelegate.maxReadRetry {
                    completion(.error(url: settings.file, error: .trasmissionError))
                } else {
                    completion(.checkUpgradeParameters(settings: settings, retry: currentRetry + 1))
                }
            } else {
                completion(.startUpload(settings: settings))
            }
        }
    }
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        
    }
    
}

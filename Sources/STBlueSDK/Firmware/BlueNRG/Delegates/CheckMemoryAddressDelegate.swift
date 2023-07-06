//
//  CheckMemoryAddressDelegate.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

typealias FirmwareUpgradeStateCompletion = (_ state: FirmwareUpgradeState) -> Void

internal class CheckMemoryAddressDelegate: BlueDelegate {
    
    private let param: FirmwareUpgradeParam
    private let completion: FirmwareUpgradeStateCompletion
    
    init(param: FirmwareUpgradeParam, completion: @escaping FirmwareUpgradeStateCompletion) {
        self.param = param
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
        if let memoryInfoFeature = feature as? BlueNRGOtaMemoryInfoFeature {
            manager.removeDelegate(self)
            
            guard let memoryInfoData = memoryInfoFeature.sample?.data,
                  let flashUpperBound = memoryInfoData.flashUpperBound.value else {
                completion(.error(url: param.file, error: .invalidFwFile))
                return
            }
            
            let flashLowerBound = param.baseAddress ?? (memoryInfoData.flashLowerBound.value ?? UInt32.max)
            let availableSpace = flashUpperBound - flashLowerBound
            
            guard let dataToUpload = param.file.readFileContent() else {
                completion(.error(url: param.file, error: .invalidFwFile))
                return
            }
            
            guard flashLowerBound % 512 == 0 else {
                completion(.error(url: param.file, error: .unsupportedOperation))
                return
            }
            
            let byteToUpload = dataToUpload.count.roundToBeMultipleOf(Int(param.packageSize))
            
            guard availableSpace >= byteToUpload else {
                completion(.error(url: param.file, error: .invalidFwFile))
                return
            }
            
            let param = FirmwareUpgradeSettings(file: param.file,
                                                data: dataToUpload,
                                                ackInterval: FirmwareUpgradeSettings.defaultAckInterval,
                                                uploadSize: UInt32(byteToUpload),
                                                baseAddress: flashLowerBound,
                                                packageSize: param.packageSize)
            
            completion(.checkUpgradeParameters(settings: param, retry: 0))
        }
    }
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        
    }
    
}

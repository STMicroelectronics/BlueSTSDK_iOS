//
//  VersionInfoDelegate.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

internal class VersionInfoDelegate: BlueDelegate {
    
    private static let defaultBoardName = "BLUENRG OTA";
    private static let defaultMcuName = "BLUENRG";
    
    private let completion: FirmwareVersionCompletion
    
    init(completion: @escaping ((FirmwareVersion?) -> ()) ){
        self.completion = completion
    }

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool) {

    }
    
    func manager(_ manager: BlueManager, didDiscover node: Node) {
        // N
    }
    
    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {
        
    }
    
    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        
    }
    
    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        if let memoryInfoFeature = feature as? BlueNRGOtaMemoryInfoFeature {
            manager.removeDelegate(self)
            
            guard let memoryInfoData = memoryInfoFeature.sample?.data,
                  let major = memoryInfoData.versionMajor.value,
                  let minor = memoryInfoData.versionMinor.value else {
                completion(nil)
                return
            }
            
            let version = FirmwareVersion(name: VersionInfoDelegate.defaultBoardName,
                                          mcuType: VersionInfoDelegate.defaultMcuName,
                                          major: Int(major),
                                          minor: Int(minor),
                                          patch: 0)
            
            completion(version)
        }
    }
    
    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        
    }
}

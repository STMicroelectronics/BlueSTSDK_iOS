//
//  BlueDelegate.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public protocol BlueDelegate: AnyObject {
    /**
     *  Function called when a new node is discovered
     *
     *  @param manager manager that discovered the node (the manger is a singleton,
     *    so this parameter is only for have a consistent method sign with the others delegate)
     *  @param node new node discovered
     */

    func manager(_ manager: BlueManager, discoveringStatus isDiscovering: Bool)

    func manager(_ manager: BlueManager, didDiscover node: Node)

    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node])

    func manager(_ manager: BlueManager, didChangeStateFor node: Node)

    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?)

    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse)
    
}

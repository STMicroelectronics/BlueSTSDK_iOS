//
//  BaseNodeViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import STBlueSDK
import STCore

class BaseNodeViewController: UIViewController, BlueDelegate {
    func manager(_ manager: STBlueSDK.BlueManager, discoveringStatus isDiscovering: Bool) { }
    

    var node: Node

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        BlueManager.shared.addDelegate(self)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        BlueManager.shared.removeDelegate(self)
    }

    init(with node: Node) {
        self.node = node
        
        super.init(nibName: nil, bundle: nil)
    }

    init(with node: Node, nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        self.node = node

        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    deinit {
        BlueManager.shared.removeDelegate(self)
        Logger.debug(text: "DEINIT: \(String(describing: self))")
        deinitController()
    }

    public func deinitController() {

    }

    func manager(_ manager: BlueManager, didDiscover node: Node) {

    }

    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {
        
    }

    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {

    }

    func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {

    }

    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {
        Logger.debug(text: "\(response.description)")
    }
}

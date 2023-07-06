//
//  NodeListViewController.swift
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

class NodeListViewController: UIViewController, LoadableView {

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "NODE LIST"

        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leftAnchor.constraint(equalTo: view.leftAnchor),
            tableView.rightAnchor.constraint(equalTo: view.rightAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        tableView.delegate = self
        tableView.dataSource = self

        tableView.register(NodeCell.self, forCellReuseIdentifier: "NodeCell")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BlueManager.shared.addDelegate(self)
        BlueManager.shared.discoveryStart()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BlueManager.shared.removeDelegate(self)
        BlueManager.shared.discoveryStop()
    }

    deinit {
        BlueManager.shared.removeDelegate(self)
        BlueManager.shared.resetDiscovery()
        Logger.debug(text: "DEINIT: \(String(describing: self))")
    }
}

extension NodeListViewController: UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showLoadingView()
        let node = BlueManager.shared.discoveredNodes[indexPath.row]
        BlueManager.shared.discoveryStop()
        BlueManager.shared.connect(node)
    }

}

extension NodeListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return BlueManager.shared.discoveredNodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeCell",
                                                 for: indexPath)

        let node = BlueManager.shared.discoveredNodes[indexPath.row]

        cell.textLabel?.text = node.name
        cell.detailTextLabel?.text = node.address

        return cell
    }
}

extension NodeListViewController: BlueDelegate {
    func manager(_ manager: STBlueSDK.BlueManager, discoveringStatus isDiscovering: Bool) {}
    
    func manager(_ manager: BlueManager, didDiscover node: Node) {
        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }
            self.tableView.reloadData()

            if let node = BlueManager.shared.discoveredNodes.first,
               let catalog = BlueManager.shared.catalog,
               let firmware = catalog.v2Firmware(with: node.deviceId.longHex,
                                                 firmwareId: UInt32(node.bleFirmwareVersion).longHex) {

                BlueManager.shared.updateDtmi(with: .prod, firmware: firmware) { result, error in


                    Logger.debug(text: "\(result.count)")

                    //
                    //                if let error = error {
                    //                    Logger.debug(text: error.localizedDescription)
                    //                } else if let catalog = catalog {
                    //                    Logger.debug(text: "Catalog version: \(catalog.version), cheksum: \(catalog.checksum)")
                    //                }
                }

            }
        }
    }

    func manager(_ manager: BlueManager, didRemoveDiscovered nodes: [Node]) {
        DispatchQueue.main.async { [weak self] in

            guard let self = self else { return }
            self.tableView.reloadData()
        }
    }

    func manager(_ manager: BlueManager, didChangeStateFor node: Node) {
        if node.state == .connected {
            DispatchQueue.main.async { [weak self] in

                guard let self = self else { return }
                
                self.hideLoadingView()
                
                let controller = NodeDetailViewController(with: node)
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }

    func manager(_ manager: BlueManager, didUpdateValueFor: Node, feature: Feature, sample: AnyFeatureSample?) {

    }

    func manager(_ manager: BlueManager, didReceiveCommandResponseFor node: Node, feature: Feature, response: FeatureCommandResponse) {

    }
}



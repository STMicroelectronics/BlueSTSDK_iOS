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

    var nodes: [Any] {
        switch currentDeviceScanSelection {
        case .classic:
            return BlueManager.shared.discoveredNodes
        case .le:
            return BlueManager.shared.discoverLeNodes
        }
    }
    
    var currentDeviceScanSelection = BlueManager.shared.scanMode
    
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
        
        let leNodelistItem = UIBarButtonItem(title: currentDeviceScanSelection.title,
                                             style: .plain,
                                             target: self,
                                             action: #selector(changeScanMode))
        
        navigationItem.rightBarButtonItems = [ leNodelistItem ]
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        BlueManager.shared.addDelegate(self)
        BlueManager.shared.addLeDelegate(self)
        BlueManager.shared.discoveryStart()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        BlueManager.shared.removeDelegate(self)
        BlueManager.shared.discoveryStop()
    }

    deinit {
        BlueManager.shared.removeDelegate(self)
        BlueManager.shared.removeLeDelegate(self)
        BlueManager.shared.resetDiscovery(true)
        Logger.debug(text: "DEINIT: \(String(describing: self))")
    }
    
    @objc
    func changeScanMode() {
        switch currentDeviceScanSelection {
        case .classic:
            BlueManager.shared.discoveryStop()
            BlueManager.shared.resetDiscovery(true)
        case .le:
            BlueManager.shared.discoveryLeStop()
            BlueManager.shared.resetDiscoveredLeNodes()
        }

        currentDeviceScanSelection = (currentDeviceScanSelection == .classic) ? .le : .classic

        if let button = navigationItem.rightBarButtonItems?.first {
            button.title = currentDeviceScanSelection.title
        }

        switch currentDeviceScanSelection {
        case .classic:
            BlueManager.shared.scanMode = .classic
            BlueManager.shared.discoveryStart()
        case .le:
            BlueManager.shared.scanMode = .le
            BlueManager.shared.discoveryLeStart { [weak self] manager, leNode in
                guard let self = self else { return }
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            }
        }
        
        tableView.reloadData()
    }
}

extension NodeListViewController: UITableViewDelegate {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        OLD METHOD -->
//        tableView.deselectRow(at: indexPath, animated: true)
//        showLoadingView()
//        let node = BlueManager.shared.discoveredNodes[indexPath.row]
//        BlueManager.shared.discoveryStop()
//        BlueManager.shared.connect(node)
//        <--
        tableView.deselectRow(at: indexPath, animated: true)
        
        if let node = nodes[indexPath.row] as? Node {
            showLoadingView()
            BlueManager.shared.discoveryStop()
            BlueManager.shared.connect(node)
        }
    }

}

extension NodeListViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60.0
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return BlueManager.shared.discoveredNodes.count
        return nodes.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        OLD METHOD -->
//        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeCell",
//                                                 for: indexPath)
//
//        let node = BlueManager.shared.discoveredNodes[indexPath.row]
//
//        cell.textLabel?.text = node.name
//        cell.detailTextLabel?.text = node.address
//
//        return cell
//        <--
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "NodeCell", for: indexPath)
        
        if let node = nodes[indexPath.row] as? Node {
            cell.textLabel?.text = node.name ?? "Unknown Node"
            cell.detailTextLabel?.text = node.address
        } else if let leNode = nodes[indexPath.row] as? LeNode {
            cell.textLabel?.text = leNode.name ?? "Unknown LeNode"
            cell.detailTextLabel?.numberOfLines = 0
            cell.detailTextLabel?.text = "deviceId: \(leNode.deviceId.longHex) • firmwareId: \(leNode.firmwareId.longHex) • protocolId: \(leNode.protocolId.longHex) • payload: \(leNode.payloadData.hex)"
        }
        
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
                    
                    if result.isEmpty || error != nil {
                        BlueManager.shared.updateDtmi(with: .dev, firmware: firmware) { dtmiElements, error in }
                    }
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

// MARK: - NodeListViewController Extension to support LeNodes
extension NodeListViewController: BlueDelegateLeExtension {
    func manager(_ manager: BlueManager, didDiscoverLeNode leNode: LeNode) {
        guard currentDeviceScanSelection == .le else { return }
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    func manager(_ manager: BlueManager, didUpdateLeNodePayload leNode: LeNode) {
        guard currentDeviceScanSelection == .le else { return }
        if let index = nodes.firstIndex(where: { ($0 as? LeNode)?.peripheral.identifier == leNode.peripheral.identifier }) {
            let indexPath = IndexPath(row: index, section: 0)
            DispatchQueue.main.async {
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            }
        }
    }
}

//
//  NodeDetailViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import UIKit
import MessageUI
import STBlueSDK

class NodeDetailViewController: BaseNodeViewController {

    let tableView = UITableView()

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "FEATURE LIST"

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
        
        tableView.register(NodeCell.self, forCellReuseIdentifier: "FeatureCell")
        
        let debugConsoleItem = UIBarButtonItem(image: UIImage(systemName: "ladybug"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(openDebugConsole))
        
        let firmwareUpgradeConsoleItem = UIBarButtonItem(image: UIImage(systemName: "cpu"),
                                                         style: .plain,
                                                         target: self,
                                                         action: #selector(firmwareUpgrade))
        
        let logItem = UIBarButtonItem(image: UIImage(systemName: "terminal"),
                                               style: .plain,
                                               target: self,
                                               action: #selector(enableDisableLog))
        
        navigationItem.rightBarButtonItems = [ firmwareUpgradeConsoleItem, debugConsoleItem, logItem ]
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }

    override func deinitController() {
        BlueManager.shared.disconnect(node)
    }

    @objc
    func openDebugConsole() {
        let controller = DebugConsoleViewController(with: node, nibNameOrNil: "DebugConsoleViewController", bundle: nil)
        navigationController?.show(controller, sender: nil)
    }

    @objc
    func firmwareUpgrade() {
        let controller = FirmwareSelectViewController(with: node, nibNameOrNil: nil, bundle: nil)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc
    func enableDisableLog() {
        if BlueManager.shared.featureLogger.isEnabled {
            BlueManager.shared.featureLogger.stop()
            
            let loggedUrls = BlueManager.shared.featureLogger.loggedFile
            
            if loggedUrls.isEmpty {
                return
            }
            
            if MFMailComposeViewController.canSendMail() {
                let mail = MFMailComposeViewController()
                mail.mailComposeDelegate = self
                
                for url in loggedUrls {
                    if let fileData = try? Data(contentsOf: url) {
                        mail.addAttachmentData(fileData as Data, mimeType: "text/txt", fileName: url.lastPathComponent)
                    }
                }
                
                present(mail, animated: true)
            } else {
                // show failure alert
            }
        } else {
            BlueManager.shared.featureLogger.start()
        }
        
    }
    
    

}

extension NodeDetailViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        if error == nil {
            BlueManager.shared.featureLogger.clear()
        }
        controller.dismiss(animated: true)
    }
}

extension NodeDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let feature = node.characteristics.allFeatures()[indexPath.row]
        
        if feature is ADPCMAudioFeature || feature is ADPCMAudioSyncFeature ||
        feature is OpusAudioFeature || feature is OpusAudioConfFeature {
            let controller = BlueVoiceViewController(with: node)
            self.navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = FeatureLogViewController(with: node, feature: feature)
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension NodeDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        node.characteristics.allFeatures().count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeatureCell",
                                                 for: indexPath)

        let feature = node.characteristics.allFeatures()[indexPath.row]

        cell.textLabel?.text = String(describing: type(of: feature))
        cell.detailTextLabel?.text = feature.type.uuid.uuidString

        return cell
    }


}

//
//  DiscoveryViewController.swift
//
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation
import UIKit

class DiscoveryViewController: UIViewController {
    
    @objc
    private func showLicenseAgreement() {
        let controller: LicenseAgreement = LicenseAgreement(hideTextDescription: true, hideButtons: true)
        let navController = UINavigationController(rootViewController: controller)
        present(navController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let licenseAgreementAccepted = UserDefaults.standard.bool(forKey: "licenseAgreementAccepted")
        
        if !licenseAgreementAccepted {
            let controller: LicenseAgreement = LicenseAgreement(hideTextDescription: false, hideButtons: false)
            let navController = UINavigationController(rootViewController: controller)
            controller.isModalInPresentation = true
            present(navController, animated: true, completion: nil)
        }
        
        navigationItem.rightBarButtonItem = UIBarButtonItem.init(image: UIImage(systemName: "questionmark.circle.fill"), style: .plain, target: self, action: #selector(showLicenseAgreement))
        
    }

}

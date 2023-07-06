//
//  LicenseAgreement.swift
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

class LicenseAgreement: UIViewController {
    
    public var descriptionLA = """
    Please read carefully the license agreement. If you accept the terms below click "I agree"otherwise click "I do not agree" and quit the application.
    """
    
    public var licenseAgreement = """
    This software component is provided to you as part of a software package and
    applicable license terms are in the Package_license file. If you received this
    software component outside of a package or without applicable license terms,
    the terms of the SLA0095 license shall apply and are fully reproduced below:

    SLA0095 Rev2/Nov 2020

    Software license agreement

    Mix ODE+OSS+3rd-party Software License Agreement
    BY INSTALLING COPYING, DOWNLOADING, ACCESSING OR OTHERWISE USING THIS SOFTWARE PACKAGE OR ANY
    PART THEREOF (AND THE RELATED DOCUMENTATION) FROM STMICROELECTRONICS INTERNATIONAL N.V, SWISS
    BRANCH AND/OR ITS AFFILIATED COMPANIES (STMICROELECTRONICS), THE RECIPIENT, ON BEHALF OF HIMSELF
    OR HERSELF, OR ON BEHALF OF ANY ENTITY BY WHICH SUCH RECIPIENT IS EMPLOYED AND/OR ENGAGED
    AGREES TO BE BOUND BY THIS SOFTWARE PACKAGE LICENSE AGREEMENT.
    Under STMicroelectronics’ intellectual property rights and subject to applicable licensing terms for any third-party software
    incorporated in this software package and applicable Open Source Terms (as defined here below), the redistribution,
    reproduction and use in source and binary forms of the software package or any part thereof, with or without modification,
    are permitted provided that the following conditions are met:

    1. Redistribution of source code (modified or not) must retain any copyright notice, this list of conditions and the following disclaimer.

    2. Redistributions in binary form, except as embedded into microcontroller or microprocessor device manufactured by or for STMicroelectronics or a software update for such device, must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

    3. Neither the name of STMicroelectronics nor the names of other contributors to this software package may be used to endorse or promote products derived from this software package or part thereof without specific written permission.

    4. This software package or any part thereof, including modifications and/or derivative works of this software package, must be used and execute solely and exclusively on or in combination with a microcontroller or a microprocessor devices manufactured by or for STMicroelectronics.

    5. No use, reproduction or redistribution of this software package partially or totally may be done in any manner that would subject this software package to any Open Source Terms (as defined below).

    6. Some portion of the software package may contain software subject to Open Source Terms (as defined below) applicable for each such portion (“Open Source Software”), as further specified in the software package. Such Open Source Software is supplied under the applicable Open Source Terms and is not subject to the terms and conditions of license hereunder. “Open Source Terms” shall mean any open source license which requires as part of distribution of software that the source code of such software is distributed therewith or otherwise made available, or open source license that substantially complies with the Open Source definition specified at www.opensource.org and any other comparable open source license such as for example GNU General Public License (GPL), Eclipse Public License (EPL), Apache Software License, BSD license and MIT license.

    7. This software package may also include third party software as expressly specified in the software package subject to specific license terms from such third parties. Such third party software is supplied under such specific license terms and is not subject to the terms and conditions of license hereunder. By installing copying, downloading, accessing or otherwise using this software package, the recipient agrees to be bound by such license terms with regard to such third party software.

    8. STMicroelectronics has no obligation to provide any maintenance, support or updates for the software package.

    9. The software package is and will remain the exclusive property of STMicroelectronics and its licensors. The recipient will not take any action that jeopardizes STMicroelectronics and its licensors' proprietary rights or acquire any rights in the software package, except the limited rights specified hereunder.

    10. The recipient shall comply with all applicable laws and regulations affecting the use of the software package or any part thereof including any applicable export control law or regulation.

    11. Redistribution and use of this software package partially or any part thereof other than as permitted under this license is void and will automatically terminate your rights under this license.

    THIS SOFTWARE PACKAGE IS PROVIDED BY STMICROELECTRONICS AND CONTRIBUTORS "AS IS" AND ANY
    EXPRESS, IMPLIED OR STATUTORY WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
    OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT OF THIRD PARTY
    INTELLECTUAL PROPERTY RIGHTS ARE DISCLAIMED TO THE FULLEST EXTENT PERMITTED BY LAW. IN NO EVENT
    SHALL STMICROELECTRONICS OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
    EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
    GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
    ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
    OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE PACKAGE, EVEN IF ADVISED OF THE
    POSSIBILITY OF SUCH DAMAGE.
    EXCEPT AS EXPRESSLY PERMITTED HEREUNDER AND SUBJECT TO THE APPLICABLE LICENSING TERMS FOR
    ANY THIRD-PARTY SOFTWARE INCORPORATED IN THE SOFTWARE PACKAGE AND OPEN SOURCE TERMS AS
    APPLICABLE, NO LICENSE OR OTHER RIGHTS, WHETHER EXPRESS OR IMPLIED, ARE GRANTED UNDER ANY
    PATENT OR OTHER INTELLECTUAL PROPERTY RIGHTS OF STMICROELECTRONICS OR ANY THIRD PARTY.
    """
    
    @IBOutlet weak var textDescription: UILabel!
    @IBOutlet weak var licenseAgreementLabel: UILabel!
    @IBOutlet weak var buttonsStackView: UIStackView!

    public var hideTextDescription: Bool
    public var hideButtons: Bool
    
    @IBAction func dontAgreeButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(false, forKey: "licenseAgreementAccepted")
        let alert = UIAlertController(title: "License Agreement", message: "If you do not agree, please close the application.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func agreeButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(true, forKey: "licenseAgreementAccepted")
        navigationController?.dismiss(animated: true)
    }
    
    init(hideTextDescription: Bool, hideButtons: Bool) {
        self.hideTextDescription = hideTextDescription
        self.hideButtons = hideButtons
        super.init(nibName: "LicenseAgreement", bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc
    private func dismissModal() {
        navigationController?.dismiss(animated: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "License Agreement"
        
        licenseAgreementLabel.text = licenseAgreement
        textDescription.text = descriptionLA
        
        textDescription.isHidden = hideTextDescription
        buttonsStackView.isHidden = hideButtons
        
        if (hideButtons){
            navigationItem.leftBarButtonItem = UIBarButtonItem.init(barButtonSystemItem: .cancel, target: self, action: #selector(dismissModal))
        }
        
    }

}

//
//  DebugConsoleViewController.swift
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

class DebugConsoleViewController: BaseNodeViewController {

    @IBOutlet weak var commandTextField: UITextField!
    @IBOutlet weak var logTextView: UITextView!

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "DEBUG CONSOLE"

        logTextView.isEditable = false
        logTextView.isSelectable = false
        logTextView.text = nil

        commandTextField.delegate = self
    }

    @IBAction func sendButtonTouched(_ sender: Any) {
        guard let commandText = commandTextField.text else { return }
        
        BlueManager.shared.sendMessage(commandText,
                                       to: node,
                                       completion: DebugConsoleCallback(timeOut: 1.0,
                                                                        onCommandResponds: { [weak self] text in
            guard let self = self else { return }

            self.logTextView.text = text + "\n\n" + self.logTextView.text
        }, onCommandError: {
            Logger.debug(text: "!!! DEBUG CONSOLE ERROR !!!")
        }))
    }
}

extension DebugConsoleViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        commandTextField.resignFirstResponder()
        return true
    }
}

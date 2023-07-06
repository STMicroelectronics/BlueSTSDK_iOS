//
//  DebugConsoleDelegate.swift
//  
//  Copyright (c) 2022 STMicroelectronics.
//  All rights reserved.
//
//  This software is licensed under terms that can be found in the LICENSE file in
//  the root directory of this software component.
//  If no LICENSE file comes with this software, it is provided AS-IS.
//

import Foundation

public class DebugConsoleCallback {

    private let onCommandResponse: (String) -> Void
    private let onCommandError: () -> ()
    private var rensponseBuffer: String = ""
    private var firstInput = true
    private let timerTimeout: TimeInterval
    private var timer: Timer?

    public init(timeOut: TimeInterval, onCommandResponds: @escaping (String) -> (),
         onCommandError: @escaping () -> ()) {
        self.timerTimeout = timeOut
        self.onCommandResponse = onCommandResponds
        self.onCommandError = onCommandError
    }
}

private extension DebugConsoleCallback {
    @objc func onTimeoutFire(_ timer: Timer) {

        guard let console = timer.userInfo as? DebugConsole else { return }
        console.removeDelegate(self)

        if rensponseBuffer.isEmpty {
            onCommandError()
        } else {
            onCommandResponse(rensponseBuffer)
        }
    }
}

extension DebugConsoleCallback: DebugConsoleDelegate {
    func console(_ console: DebugConsole, didReceiveTerminalMessage message: String) {
        rensponseBuffer.append(message)
    }

    func console(_ console: DebugConsole, didReceiveErrorMessage message: String) {
        // NOT USED
    }

    func console(_ console: DebugConsole, didSendMessage message: String?, error: Error?) {
        guard error == nil else{
            console.removeDelegate(self)
            onCommandError()
            return
        }

        if firstInput {
            firstInput = false
            timer = Timer.scheduledTimer(timeInterval: timerTimeout,
                                         target: self,
                                         selector: #selector(onTimeoutFire(_:)),
                                         userInfo: console,
                                         repeats: false)
        }
    }
}

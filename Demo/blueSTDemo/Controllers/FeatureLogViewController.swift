//
//  FeatureLogViewController.swift
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

class FeatureLogViewController: BaseNodeViewController {
    
    let feature: Feature

    let textView: UITextView = {
        let text = UITextView()
        text.translatesAutoresizingMaskIntoConstraints = false
        text.isEditable = false
        text.isSelectable = false
        text.font = UIFont.systemFont(ofSize: 20.0)
        return text
    }()
    
    let commandsStackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.spacing = 5.0
        stack.distribution = .equalSpacing
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let scrollView: UIScrollView = {
        let scroll = UIScrollView()
        scroll.translatesAutoresizingMaskIntoConstraints = false
        return scroll
    }()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        BlueManager.shared.enableNotifications(for: node, feature: feature)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        BlueManager.shared.disableNotifications(for: node, feature: feature)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "FEATURE DETAIL"
        
        view.backgroundColor = .systemBackground
        view.addSubview(textView)
        view.addSubview(scrollView)
        scrollView.addSubview(commandsStackView)
        
        NSLayoutConstraint.activate([
            textView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            textView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            textView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            
            scrollView.topAnchor.constraint(equalTo: textView.bottomAnchor),
            scrollView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            scrollView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            scrollView.heightAnchor.constraint(equalToConstant: 300.0),
            
            commandsStackView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            commandsStackView.leftAnchor.constraint(equalTo: scrollView.leftAnchor),
            commandsStackView.rightAnchor.constraint(equalTo: scrollView.rightAnchor),
            commandsStackView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            commandsStackView.widthAnchor.constraint(equalTo: scrollView.widthAnchor)
        ])
        
        guard let autoConfFeature = feature as? CommandFeature else { return }
        
        for command in autoConfFeature.commands {
            let button = UIButton(type: .custom)
            button.setTitle(command.description, for: .normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.addAction(UIAction(handler: { [weak self] action in
                
                guard let self = self else { return }
                
                let command = FeatureCommand(type: command, data: command.payload)
                Logger.debug(text: "\(command.description) - Message: \(command.message(with: self.feature.type.mask, nodeId: self.node.deviceId).hex)")
                BlueManager.shared.sendCommand(command, to: self.node, feature: self.feature)
            }), for: .touchUpInside)
            
            commandsStackView.addArrangedSubview(button)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

//        BlueManager.shared.sendPnpLCommand(PnpLCommand.status,
//                                           to: self.node,
//                                           completion: ExtendedCommandCallback(timeOut: 1.0,
//                                                                               onCommandResponds: { [weak self] feature in
//            guard let self = self else { return }
//
//            let description = feature.description(with: feature.lastSample)
//
//            self.textView.text = description
//            Logger.debug(text: description)
//        }, onCommandError: {
//            self.textView.text = "Error"
//            Logger.debug(text: "Error")
//        }))
    }
    
    init(with node: Node, feature: Feature) {
        self.feature = feature
        
        super.init(with: node)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func manager(_ manager: BlueManager, didUpdateValueFor node: Node, feature: Feature, sample: AnyFeatureSample?) {
        DispatchQueue.main.async { [weak self] in
            
            guard let self = self else { return }
            if type(of: self.feature) != type(of: feature) ||
                feature.type.mask != self.feature.type.mask {
                return
            }
            
            let description = feature.description(with: sample)
            
            Logger.debug(text: "\(description)")
            self.textView.text = description
        }
    }
}

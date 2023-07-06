//
//  FirmwareSelectViewController.swift
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
import JGProgressHUD

class FirmwareSelectViewController: BaseNodeViewController {
    
    let stackView: UIStackView = {
        let stack = UIStackView()
        stack.axis = .vertical
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    var firmwareSelectType: FirmwareServiceType = .unknown
    var firmwareType: FirmwareType = .application(board: .other)
    var typeView: STM32FirmwareTypeView?
    var url: URL?
    
    let hud = JGProgressHUD()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hud.textLabel.text = "Upgrading..."
        hud.detailTextLabel.text = "0% Complete"
        hud.indicatorView = JGProgressHUDPieIndicatorView()
        hud.interactionType = .blockAllTouches
        
        view.backgroundColor = .systemBackground
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            stackView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor),
            stackView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor),
            stackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        firmwareSelectType = BlueManager.shared.firmwareServiceType(for: node)
        
//      
        
        if firmwareSelectType == .stm32 {
            if let typeView = Bundle.main.loadNibNamed("STM32FirmwareTypeView", owner: self)?.first as? STM32FirmwareTypeView {
                typeView.configure(with: .application(board: (node.type == .wbaBoard) ? .wba : .wb55))
                typeView.translatesAutoresizingMaskIntoConstraints = false
                
                stackView.addArrangedSubview(typeView)
                typeView.heightAnchor.constraint(equalToConstant: 320.0).isActive = true
                self.typeView = typeView
            }
        } else if firmwareSelectType == .blueNrg {
            firmwareType = .custom(startSector: nil, numberOfSectors: 0, sectorSize: 0)
        }
        
        let firmwareSelectButton = UIButton(frame: .zero)
        firmwareSelectButton.setTitle("SELECT FIRMWARE", for: .normal)
        firmwareSelectButton.setTitleColor(.systemBlue, for: .normal)
        firmwareSelectButton.addAction(UIAction(handler: { action in
            
            FilePicker.shared.pickFile(with: .bin) { [weak self] url in
                
                guard let self = self,
                let url = url else { return }
                
                self.url = url
            
                firmwareSelectButton.setTitle(url.lastPathComponent, for: .normal)
                
            }
            
        }), for: .touchUpInside)
        
        firmwareSelectButton.translatesAutoresizingMaskIntoConstraints = false
        firmwareSelectButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        stackView.addArrangedSubview(firmwareSelectButton)
        
        let upgradeButton = UIButton(frame: .zero)
        upgradeButton.setTitle("UPGRADE", for: .normal)
        upgradeButton.backgroundColor = UIColor(hex: "#FF03234B")
        upgradeButton.layer.cornerRadius = 4.0
        upgradeButton.addAction(UIAction(handler: { [weak self] action in
            
            guard let self = self else { return }
            
            if let typeView = self.typeView,
               let firmwareType = typeView.firmwareType {
                self.firmwareUpgrade(with: firmwareType)
            } else {
                self.firmwareUpgrade(with: self.firmwareType)
            }
            
        }), for: .touchUpInside)
        
        upgradeButton.translatesAutoresizingMaskIntoConstraints = false
        upgradeButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        stackView.addArrangedSubview(upgradeButton)
        
        stackView.addArrangedSubview(UIView())
        
    }
    
    func firmwareUpgrade(with type: FirmwareType) {
        if let catalog = BlueManager.shared.catalog {
            guard let url = self.url else { return }
            
            self.hud.progress = 0.0
            self.hud.show(in: self.view)
            
            self.navigationController?.navigationBar.isUserInteractionEnabled = false
            
            BlueManager.shared.firmwareUpgrade(for: self.node,
                                               type: type,
                                               url: url,
                                               catalog: catalog,
                                               callback: DefaultFirmwareUpgradeCallback(completion: { [weak self] url, error in
                
                guard let self = self else { return }
                
                DispatchQueue.main.async {
                    
                    self.navigationController?.navigationBar.isUserInteractionEnabled = true

                    self.hud.dismiss(afterDelay: 0.5, animated: true) {
                        self.hud.indicatorView = nil
                        self.hud.textLabel.text = "Firmware upgrade success"
                        self.hud.show(in: self.view)
                        self.hud.dismiss(afterDelay: 2.0)
                    }
                    
                    if let error = error {
                        Logger.debug(text: "[Firmware upgrade] Fail with error: \(error.localizedDescription)")
                        self.navigationController?.popToRootViewController(animated: true)
                        return
                    }
                    
                    Logger.debug(text: "[Firmware upgrade] Complete with success")
                    
                    self.navigationController?.popToRootViewController(animated: true)
                }
                
            }, progress: { [weak self] url, bytes, totalBytes in
                
                guard let self = self else { return }
                
                Logger.debug(text: "[Firmware upgrade] Remaining bytes: \(bytes)/\(totalBytes)")
                let percentage = Float(bytes) / Float(totalBytes)
                
                DispatchQueue.main.async {
                    self.hud.progress = percentage
                    self.hud.detailTextLabel.text = String(format: "%.2f%% Complete", percentage * 100.0)
                }
            }))
        }
        
        
    }
    
}

public extension UIColor {
    convenience init(hex: String) {
        let red, green, blue, alpha: CGFloat

        if hex.hasPrefix("#") {
            let start = hex.index(hex.startIndex, offsetBy: 1)
            let hexColor = String(hex[start...])

            if hexColor.count == 8 {
                let scanner = Scanner(string: hexColor)
                var hexNumber: UInt64 = 0

                if scanner.scanHexInt64(&hexNumber) {
                    alpha = CGFloat((hexNumber & 0xff000000) >> 24) / 255
                    red = CGFloat((hexNumber & 0x00ff0000) >> 16) / 255
                    green = CGFloat((hexNumber & 0x0000ff00) >> 8) / 255
                    blue = CGFloat(hexNumber & 0x000000ff) / 255

                    self.init(red: red, green: green, blue: blue, alpha: alpha)
                    return
                }
            }
        }

        self.init(hex: "#FFFF0000")
        return
    }
}

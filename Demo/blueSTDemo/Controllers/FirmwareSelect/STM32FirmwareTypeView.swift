//
//  STM32FirmwareTypeView.swift
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

class STM32FirmwareTypeView: UIView {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var sectorToUpdateLabel: UILabel!
    @IBOutlet weak var firstSectorToDeleteLabel: UILabel!
    @IBOutlet weak var numberOfSectorToDeleteLabel: UILabel!
    
    @IBOutlet weak var boardTypeSegmentedControl: UISegmentedControl!
    @IBOutlet weak var sectorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var firstSectorToDeleteTextField: UITextField!
    @IBOutlet weak var numberOfSectorToDeleteTextField: UITextField!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    private(set) var firmwareType: FirmwareType? {
        get {
            let boardFamily:BoardFamily
            let sectorSize:UInt16
            
            switch boardTypeSegmentedControl.selectedSegmentIndex {
                case 0: boardFamily = BoardFamily.wba ; sectorSize = 0x2000 ; sectorSegmentedControl.setTitle("User conf", forSegmentAt: 1)
                case 1: boardFamily = BoardFamily.wb55 ; sectorSize = 0x1000 ; sectorSegmentedControl.setTitle("Radio", forSegmentAt: 1)
                default: boardFamily = BoardFamily.wb15 ; sectorSize = 0x800 ; sectorSegmentedControl.setTitle("Radio", forSegmentAt: 1)
            }
            
            guard let startSectorText = firstSectorToDeleteTextField.text,
                  let startSector = UInt8(startSectorText),
                  let numberOfSectorsText = numberOfSectorToDeleteTextField.text,
                  let numberOfSectors = UInt8(numberOfSectorsText) else {
                return nil
            }

            if sectorSegmentedControl.selectedSegmentIndex == 0 {
                return .application(board: boardFamily)
            } else if sectorSegmentedControl.selectedSegmentIndex == 1 {
                return .radio(board: boardFamily)
            } else {
                return .custom(startSector: startSector,
                               numberOfSectors: numberOfSectors,
                               sectorSize: sectorSize)
            }
        }
        
        set {
         
        }
        
    }
    
    func configure(with firmwareType: FirmwareType) {
        firstSectorToDeleteTextField.isEnabled = false
        numberOfSectorToDeleteTextField.isEnabled = false
        
        switch firmwareType {
        case .application(let board):
            sectorSegmentedControl.selectedSegmentIndex = 0
            boardTypeSegmentedControl.selectedSegmentIndex = board == .wba ? 0 : (board == .wb55 ? 1 : 2)
            hideCustom(true)
        case .radio(let board):
            sectorSegmentedControl.selectedSegmentIndex = 1
            boardTypeSegmentedControl.selectedSegmentIndex = board == .wba ? 0 : (board == .wb55 ? 1 : 2)
            hideCustom(true)
        case .custom:
            sectorSegmentedControl.selectedSegmentIndex = 2
            firstSectorToDeleteTextField.isEnabled = true
            numberOfSectorToDeleteTextField.isEnabled = true
            hideCustom(false)
        case .undefined:
            break
        }
        
        firstSectorToDeleteTextField.text = "\(firmwareType.firstSector ?? 0)"
        numberOfSectorToDeleteTextField.text = "\(firmwareType.layout.numberOfSectors)"

    }
    
    private func hideCustom(_ isHidden: Bool) {
        firstSectorToDeleteLabel.isHidden = isHidden
        firstSectorToDeleteTextField.isHidden = isHidden
        numberOfSectorToDeleteLabel.isHidden = isHidden
        numberOfSectorToDeleteTextField.isHidden = isHidden
    }
    
    @IBAction func boardTypeValueChanged(_ sender: Any) {
        guard let firmwareType = firmwareType else {
            return
        }
        configure(with: firmwareType)
    }
    
    @IBAction func sectorValueChanged(_ sender: Any) {
        guard let firmwareType = firmwareType else {
            return
        }
        configure(with: firmwareType)
    }
    
}

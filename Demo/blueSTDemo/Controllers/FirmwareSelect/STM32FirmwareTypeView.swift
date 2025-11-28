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
    
    @IBOutlet weak var sectorSegmentedControl: UISegmentedControl!
    @IBOutlet weak var firstSectorToDeleteTextField: UITextField!
    @IBOutlet weak var numberOfSectorToDeleteTextField: UITextField!
    
    @IBOutlet weak var boardSelectionButton: UIButton!
    
    override class func awakeFromNib() {
        super.awakeFromNib()
    }
    
    let options = ["WBA5x", "WB5x/WB3x", "WB0x", "WB1x", "WBA6x","WBA2x","ST67W6x"]
    private var selectedBoardTypeName = "WBA5x"
    private var selectedBoardTypeIndex = 0
    
    func configureButton() {
        boardSelectionButton.showsMenuAsPrimaryAction = true
        boardSelectionButton.menu = createMenu()
    }
    
    func createMenu() -> UIMenu {
        
        self.boardSelectionButton.setTitle(selectedBoardTypeName, for: .normal)
        
        let actions = options.map { option in
            UIAction(
                title: option,
                state: option == selectedBoardTypeName ? .on : .off,
                handler: { [weak self] action in
                    guard let self = self else { return }
                    
                    self.selectedBoardTypeName = action.title
                    self.selectedBoardTypeIndex = options.firstIndex(of: action.title)!
                    self.boardSelectionButton.setTitle(action.title, for: .normal)
                    self.boardSelectionButton.menu = self.createMenu()
                    
                    guard let firmwareType = firmwareType else {
                        return
                    }
                    configure(with: firmwareType)
                }
            )
        }
        
        return UIMenu(title: "Board type", options: .singleSelection, children: actions)
    }
    
    private(set) var firmwareType: FirmwareType? {
        get {
            let boardFamily:WbBoardType
            
            switch selectedBoardTypeIndex {
            case 0: boardFamily = WbBoardType.wba5 ;  sectorSegmentedControl.setTitle("User conf", forSegmentAt: 1)
            case 1: boardFamily = WbBoardType.wb55 ; sectorSegmentedControl.setTitle("Radio", forSegmentAt: 1)
            case 2: boardFamily = WbBoardType.wb09 ; sectorSegmentedControl.setTitle("User conf", forSegmentAt: 1)
            case 4: boardFamily = WbBoardType.wba6 ; sectorSegmentedControl.setTitle("User conf", forSegmentAt: 1)
            case 5: boardFamily = WbBoardType.wba2 ; sectorSegmentedControl.setTitle("User conf", forSegmentAt: 1)
            case 6: boardFamily = WbBoardType.st67w6x ; sectorSegmentedControl.setTitle("Network", forSegmentAt: 1)
            default: boardFamily = WbBoardType.wb15 ; sectorSegmentedControl.setTitle("Radio", forSegmentAt: 1)
            }
            
            if sectorSegmentedControl.selectedSegmentIndex == 0 {
                return .application(board: boardFamily)
            } else if sectorSegmentedControl.selectedSegmentIndex == 1 {
                return .radio(board: boardFamily)
            } else {
                return .application(board: boardFamily)
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
            
            let selectedSegmentIndex = switch board {
            case .wba5:
                0
            case .wb55:
                1
            case .wb09:
                2
            case .wba6:
                4
            case .wba2:
                5
            case .st67w6x:
                6
            default:
                3
            }
            
            switch board {
            case .wba5:
                sectorSegmentedControl.setTitle("User conf", forSegmentAt: 1)
            case .wb55:
                sectorSegmentedControl.setTitle("Radio", forSegmentAt: 1)
            case .wb09:
                sectorSegmentedControl.setTitle("User conf", forSegmentAt: 1)
            case .wba6:
                sectorSegmentedControl.setTitle("User conf", forSegmentAt: 1)
            case .wba2:
                sectorSegmentedControl.setTitle("User conf", forSegmentAt: 1)
            case .st67w6x:
                sectorSegmentedControl.setTitle("Network", forSegmentAt: 1)
            default:
                sectorSegmentedControl.setTitle("Radio", forSegmentAt: 1)
            }
           
            sectorSegmentedControl.selectedSegmentIndex = 0
            //boardTypeSegmentedControl.selectedSegmentIndex = selectedSegmentIndex
            
            self.selectedBoardTypeName =  options[selectedSegmentIndex]
            self.selectedBoardTypeIndex = selectedSegmentIndex
            self.boardSelectionButton.setTitle(options[selectedSegmentIndex], for: .normal)
            self.boardSelectionButton.menu = self.createMenu()
            
            hideCustom(true)
        case .radio(let board):
            
            let selectedSegmentIndex = switch board {
            case .wba5:
                0
            case .wb55:
                1
            case .wb09:
                2
            case .wba6:
                4
            case .wba2:
                5
            case .st67w6x:
                6
            default:
                3
            }
            
            sectorSegmentedControl.selectedSegmentIndex = 1
            //boardTypeSegmentedControl.selectedSegmentIndex = selectedSegmentIndex
            self.selectedBoardTypeName =  options[selectedSegmentIndex]
            self.selectedBoardTypeIndex = selectedSegmentIndex
            self.boardSelectionButton.setTitle(options[selectedSegmentIndex], for: .normal)
            self.boardSelectionButton.menu = self.createMenu()
            hideCustom(true)
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
    
    @IBAction func sectorValueChanged(_ sender: Any) {
        guard let firmwareType = firmwareType else {
            return
        }
        configure(with: firmwareType)
    }
    
}


//
//  NeighborhoodInputTextTableViewCell.swift
//  entourage
//
//  Created by Jerome on 07/04/2022.
//

import UIKit

class NeighborhoodCreateNameCell: UITableViewCell, UITextFieldDelegate {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_textfield: UITextField!
    
    @IBOutlet weak var ui_error_view: MJErrorInputTextView!
    
    weak var delegate:NeighborhoodCreateNameCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let stringAttr = Utils.formatString(messageTxt: "neighborhoodCreateNameTitle".localized, messageTxtHighlight: "neighborhoodCreateNameSubtitle".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
        ui_title.attributedText = stringAttr
        
        ui_textfield.delegate = self
        ui_textfield.placeholder = "neighborhoodCreateNamePlaceholderName".localized
        ui_textfield.font = ApplicationTheme.getFontChampDefault().font
        ui_textfield.textColor = .black
        
        ui_error_view.isHidden = true
        self.ui_error_view.setupView(title: "neighborhoodCreateInputErrorMinCharName".localized)
    }
    
    func populateCell(delegate:NeighborhoodCreateNameCellDelegate, name:String? = nil) {
        self.delegate = delegate
        self.ui_textfield.text = name
    }
    
    func checkErrorInput() -> Bool {
        var returnValidate = true
        if  ui_textfield.text?.count ?? 0 >= ApplicationTheme.minGroupNameChars {
            self.ui_error_view.isHidden = true
        }
        else {
            ui_error_view.isHidden = false
            returnValidate = false
        }
        
        ui_textfield.resignFirstResponder()
        delegate?.updateFromGroupNameTF(text: ui_textfield.text)
        return returnValidate
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        ui_textfield.resignFirstResponder()
        return true
    }
    
    func textFieldShouldEndEditing(_ textField: UITextField) -> Bool {
        _ = checkErrorInput()
        return true
    }
}

//MARK: - NeighborhoodCreateNameCellDelegate Protocol -
protocol NeighborhoodCreateNameCellDelegate:AnyObject {
    func updateFromGroupNameTF(text:String?)
}

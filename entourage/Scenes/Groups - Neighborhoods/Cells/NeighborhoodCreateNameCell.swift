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
    @IBOutlet weak var ui_subtitle: UILabel?
    
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
        
        ui_subtitle?.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        
        ui_error_view.isHidden = true
        self.ui_error_view.setupView(title: "neighborhoodCreateInputErrorMinCharName".localized)
    }
    
    func populateCell(delegate:NeighborhoodCreateNameCellDelegate, name:String? = nil, isEvent:Bool, isAction:Bool = false, isContrib:Bool = false) {
        self.delegate = delegate
        self.ui_textfield.text = name
        
        if isEvent {
            let stringAttr = Utils.formatString(messageTxt: "event_create_phase_1_name".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
            ui_title.attributedText = stringAttr
            ui_textfield.placeholder = "event_create_phase_1_name_placeholder".localized
            self.ui_error_view.setupView(title: "event_create_phase_1_name_error".localized)
        }
        
        if isAction {
            let stringAttr = Utils.formatString(messageTxt: "action_create_phase_1_name".localized, messageTxtHighlight: "action_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
            ui_title.attributedText = stringAttr
            
            let _placeh = String.init(format: "action_create_phase_1_name_placeholder".localized, isContrib ? "action_contrib".localized : "action_solicitation".localized)
            ui_textfield.placeholder = _placeh
            
            let _err = String.init(format: "action_create_phase_1_name_error".localized, isContrib ? "action_contrib".localized : "action_solicitation".localized)
            self.ui_error_view.setupView(title: _err)
            
            let _subt = String.init(format: "action_create_phase_1_name_subtitle".localized, isContrib ? "action_contrib".localized : "action_solicitation".localized)
            ui_subtitle?.text = _subt
        }
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

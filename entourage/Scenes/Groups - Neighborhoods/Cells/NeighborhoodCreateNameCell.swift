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
    func populateCell(delegate: NeighborhoodCreateNameCellDelegate, name: String? = nil, isEvent: Bool, isAction: Bool = false, isContrib: Bool = false, placeholder: String? = nil) {
        self.delegate = delegate
        self.ui_textfield.text = name ?? "" // Le texte entré, sinon vide
        
        if isEvent {
            // Ancien comportement pour un événement
            let stringAttr = Utils.formatString(messageTxt: "event_create_phase_1_name".localized, messageTxtHighlight: "event_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
            ui_title.attributedText = stringAttr
            ui_textfield.placeholder = "event_create_phase_1_name_placeholder".localized
            self.ui_error_view.setupView(title: "event_create_phase_1_name_error".localized)
            
        } else if isAction {
            // Ancien comportement pour une action
            let stringAttr = Utils.formatString(messageTxt: "action_create_phase_1_name".localized, messageTxtHighlight: "action_create_mandatory".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
            ui_title.attributedText = stringAttr
            
            // Utiliser le placeholder passé en paramètre (spécifique aux actions)
            if let actionPlaceholder = placeholder {
                ui_textfield.placeholder = actionPlaceholder
            }
            
            // Gestion du texte d'erreur
            let _err = String.init(format: "action_create_phase_1_name_error".localized, isContrib ? "action_contrib".localized : "action_solicitation".localized)
            self.ui_error_view.setupView(title: _err)

            // Mise à jour du sous-titre si nécessaire
            let _subt = String.init(format: "action_create_phase_1_name_subtitle".localized, isContrib ? "action_contrib".localized : "action_solicitation".localized)
            ui_subtitle?.text = _subt
        } else {
            // Ancien comportement pour les groupes
            let stringAttr = Utils.formatString(messageTxt: "neighborhoodCreateNameTitle".localized, messageTxtHighlight: "neighborhoodCreateNameSubtitle".localized, fontColorType: ApplicationTheme.getFontH2Noir(size: 15), fontColorTypeHighlight: ApplicationTheme.getFontLegend(size: 13))
            ui_title.attributedText = stringAttr
            ui_textfield.placeholder = "neighborhoodCreateNamePlaceholderName".localized
            self.ui_error_view.setupView(title: "neighborhoodCreateInputErrorMinCharName".localized)
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

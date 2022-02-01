//
//  OTOnboardingNamesViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTOnboardingNamesViewController: UIViewController {
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_tf_firstname: OTCustomTextfield!
    @IBOutlet weak var ui_tf_lastname: OTCustomTextfield!
    @IBOutlet weak var ui_label_info: UILabel!
    @IBOutlet weak var ui_label_error: UILabel!
    
    weak var delegate:OnboardV2Delegate? = nil
    var userFirstname:String? = nil
    var userLastname:String? = nil
    
    let minimumCharacters = 2
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_label_error.text = ""
        ui_label_error.isHidden = true
        ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_welcome_title")
        ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_welcome_sub")
        ui_label_info.attributedText = Utilitaires.formatStringItalicOnly(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_welcome_info"), color: .appBlack30, fontSize: 11)
        
        ui_tf_firstname.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_welcome_placeholder_firstname")
        ui_tf_lastname.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_welcome_placeholder_lastname")
        
        ui_tf_firstname.text = userFirstname
        ui_tf_lastname.text = userLastname
        ui_tf_lastname.returnKeyType = .continue
        
        if userFirstname?.count ?? 0 >= minimumCharacters && userLastname?.count ?? 0 >= minimumCharacters {
            delegate?.updateButtonNext(isValid: true)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
        }
        OTLogger.logEvent(View_Onboarding_Names)
    }
    
    @IBAction func action_tap(_ sender: Any) {
        ui_tf_firstname.resignFirstResponder()
        ui_tf_lastname.resignFirstResponder()
    }
}

//MARK: - UITextfieldDelegate -
extension OTOnboardingNamesViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if checkAndValidateInputs() {
            delegate?.updateButtonNext(isValid: true)
            delegate?.validateFirstLastname(firstName: ui_tf_firstname.text, lastname: ui_tf_lastname.text)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
            delegate?.validateFirstLastname(firstName: nil, lastname: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ui_tf_firstname {
            ui_tf_lastname.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            if checkAndValidateInputs() {
                delegate?.goNextManually()
            }
        }
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == ui_tf_lastname {
            let inputLength = string.count > 0 ? 1 : -1
            if ((textField.text?.count ?? 0) + inputLength) >= 2 {
                textField.returnKeyType = .done
            }
            else {
                textField.returnKeyType = .continue
            }
            textField.reloadInputViews()
        }
        
        return true
    }
    
    func checkAndValidateInputs() -> Bool {
        if ui_tf_firstname.text?.count ?? 0 >= minimumCharacters && ui_tf_lastname.text?.count ?? 0 >= minimumCharacters {
            ui_label_error.isHidden = true
            return true
        }
        
        if ui_tf_firstname.text?.count ?? 0 < minimumCharacters {
            ui_label_error.text = OTLocalisationService.getLocalizedValue(forKey: "onboarding_error_firstname")
        }
        else {
            ui_label_error.text = OTLocalisationService.getLocalizedValue(forKey: "onboarding_error_lastname")
        }
        ui_label_error.isHidden = false
        return false
    }
}

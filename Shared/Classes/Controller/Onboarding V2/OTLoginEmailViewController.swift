//
//  OTLoginEmailViewController.swift
//  entourage
//
//  Created by Jr on 15/07/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTLoginEmailViewController: UIViewController {

    weak var delegate:LoginDelegate? = nil
    
    @IBOutlet weak var ui_label_title: UILabel!
        @IBOutlet weak var ui_label_description: UILabel!
        
        @IBOutlet weak var ui_tf_email: OTCustomTextfield!
        
        let minimumCharactersForPassword = 8
        
        override func viewDidLoad() {
            super.viewDidLoad()
            
            ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "login_email_pwd_title")
            ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "login_email_pwd_description")
            ui_tf_email.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_email_pwd_placeholder_email")
            
            delegate?.updateButtonNext(isValid: false)
            
            OTLogger.logEvent(View_Login_Input_Email)
        }
        
        @IBAction func action_tap(_ sender: Any) {
            ui_tf_email.resignFirstResponder()
        }
    }

    //MARK: - UITextfieldDelegate -
    extension OTLoginEmailViewController: UITextFieldDelegate {
        func textFieldDidEndEditing(_ textField: UITextField) {
            var email = ""
            var isValid = false
            if let _email = ui_tf_email.text, _email.count > 0 {
                isValid = true
                email = _email
            }
            delegate?.updateEmail(email: email)
            delegate?.updateButtonNext(isValid: isValid)
        }
        
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            textField.resignFirstResponder()
            return true
        }
        
    }

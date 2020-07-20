//
//  OTOnboardingEmailPwdViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTOnboardingEmailPwdViewController: UIViewController {
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    
    @IBOutlet weak var ui_label_info_pwd: UILabel!
    @IBOutlet weak var ui_tf_email: OTCustomTextfield!
    
    @IBOutlet weak var ui_tf_pwd: OTCustomTextfield!
    @IBOutlet weak var ui_tf_pwd_confirm: OTCustomTextfield!
    
    
    weak var delegate:OnboardV2Delegate? = nil
    var tempEmail = ""
    
    let minimumCharactersForPassword = 8
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_email_pwd_title")
        ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_email_pwd_description")
        ui_label_info_pwd.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_email_pwd_info_length")
        
        ui_tf_email.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_email_pwd_placeholder_email")
        ui_tf_pwd.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_email_pwd_placeholder_pwd")
        ui_tf_pwd_confirm.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_email_pwd_placeholder_confirm_pwd")
        
        ui_tf_email.text = tempEmail
        
        if tempEmail.isValidEmail {
            delegate?.updateButtonNext(isValid: true)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
        }
        
        OTLogger.logEvent(View_Onboarding_Input_Email)
    }
    
    @IBAction func action_tap(_ sender: Any) {
        ui_tf_email.resignFirstResponder()
        ui_tf_pwd.resignFirstResponder()
        ui_tf_pwd_confirm.resignFirstResponder()
    }
}

//MARK: - UITextfieldDelegate -
extension OTOnboardingEmailPwdViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        var email = ""
        var pwd = ""
        var pwdConfirm = ""
        var isValid = false
        //TODO: à remettre lorsque le WS sera ok pour le PWD
        if let _email = ui_tf_email.text,let _pwd = ui_tf_pwd.text, let _pwdConfirm = ui_tf_pwd_confirm.text, _email.count > 0
            //            , _pwd.count >= minimumCharactersForPassword, _pwdConfirm.count >= minimumCharactersForPassword
        {
            isValid = true
            email = _email
            pwd = _pwd
            pwdConfirm = _pwdConfirm
        }
        delegate?.updateEmailPwd(email: email, pwd: pwd, pwdConfirm: pwdConfirm)
        delegate?.updateButtonNext(isValid: isValid)
        
        if ui_tf_email.text?.isValidEmail ?? false {
            delegate?.goNextManually()
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //TODO: à remettre lorsque le WS sera ok pour le PWD
        //        if textField == ui_tf_email {
        //            ui_tf_pwd.becomeFirstResponder()
        //        }
        //        else if textField == ui_tf_pwd {
        //            ui_tf_pwd_confirm.becomeFirstResponder()
        //        }
        //        else {
        //            textField.resignFirstResponder()
        //        }
        return true
    }
    
}

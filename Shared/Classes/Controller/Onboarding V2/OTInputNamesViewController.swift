//
//  OTUsernameViewController.swift
//  entourage
//
//  Created by Jr on 25/11/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTInputNamesViewController: UIViewController {

    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_tf_firstname: OTCustomTextfield!
    @IBOutlet weak var ui_tf_lastname: OTCustomTextfield!
    @IBOutlet weak var ui_label_info: UILabel!
    @IBOutlet weak var ui_bt_validate: UIButton!
    
    var userFirstname:String? = nil
    var userLastname:String? = nil
    
    let minimumCharacters = 2
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "input_username")
        ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "input_sub")
        ui_label_info.attributedText = Utilitaires.formatStringItalicOnly(stringMessage: OTLocalisationService.getLocalizedValue(forKey: "onboard_welcome_info"), color: .appBlack30, fontSize: 11)
        
        ui_tf_firstname.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_welcome_placeholder_firstname")
        ui_tf_lastname.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_welcome_placeholder_lastname")
        
        ui_tf_firstname.text = userFirstname
        ui_tf_lastname.text = userLastname
        ui_tf_lastname.returnKeyType = .continue
        
        if userFirstname?.count ?? 0 >= minimumCharacters && userLastname?.count ?? 0 >= minimumCharacters {
            updateButton(isValid: true)
        }
        else {
            updateButton(isValid: false)
        }
        OTLogger.logEvent(View_Onboarding_Names)
    }
    
    func updateButton(isValid:Bool) {
      
    }
    
    func validateFirstLastname(firstName: String?, lastname: String?) {
        self.userFirstname = firstName == nil ? "" : firstName!
        self.userLastname = lastname == nil ? "" : lastname!
    }
    
    func checkAndSendUpdate() {
        SVProgressHUD.show()
        let _currentUser = UserDefaults.standard.currentUser
        _currentUser?.firstName = userFirstname
        _currentUser?.lastName = userLastname
        
        OTLogger.logEvent(Action_Add_username_Submit)
        OTAuthService().updateUserInformation(with: _currentUser, success: { (newUser) in
            newUser?.phone = _currentUser?.phone
            UserDefaults.standard.currentUser = newUser
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.dismiss(animated: true, completion: nil)
            }
        }) { (error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.dismiss(animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func action_tap(_ sender: Any) {
        ui_tf_firstname.resignFirstResponder()
        ui_tf_lastname.resignFirstResponder()
    }
    @IBAction func action_save(_ sender: Any) {
        if checkAndValidateInputs() {
            checkAndSendUpdate()
        }
        else {
            let message = String.init(format: OTLocalisationService.getLocalizedValue(forKey:"input_username_error"), minimumCharacters)
            let alertvc = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "error"), message: message, preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey:"OK"), style: .default, handler: nil)
            alertvc.addAction(action)
            
            self.present(alertvc, animated: true, completion: nil)
        }
    }
}

//MARK: - UITextfieldDelegate -
extension OTInputNamesViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if checkAndValidateInputs() {
            updateButton(isValid: true)
            validateFirstLastname(firstName: ui_tf_firstname.text, lastname: ui_tf_lastname.text)
        }
        else {
            updateButton(isValid: false)
            validateFirstLastname(firstName: nil, lastname: nil)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ui_tf_firstname {
            ui_tf_lastname.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            if checkAndValidateInputs() {
                checkAndSendUpdate()
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
            return true
        }
        return false
    }
}

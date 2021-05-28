//
//  OTLoginChangePhoneViewController.swift
//  entourage
//
//  Created by Jr on 28/05/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTLoginChangePhoneViewController: UIViewController {

    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_old_number: UILabel!
    @IBOutlet weak var ui_label_new_number: UILabel!
    @IBOutlet weak var ui_label_email: UILabel!
    
    @IBOutlet weak var ui_tf_old_phone: OTCustomTextfield!
    @IBOutlet weak var ui_tf_new_phone: OTCustomTextfield!
    @IBOutlet weak var ui_tf_email: OTCustomTextfield!
    
    @IBOutlet weak var ui_button_validate: UIButton!
    
    @IBOutlet weak var ui_button_back: UIButton!
    @IBOutlet weak var ui_label_info_send: UILabel!
    @IBOutlet weak var ui_view_send_ok: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "login_change_phone_title")
        ui_label_old_number.text = OTLocalisationService.getLocalizedValue(forKey: "login_change_phone_old_number")
        ui_label_new_number.text = OTLocalisationService.getLocalizedValue(forKey: "login_change_phone_new_number")
        ui_label_email.text = OTLocalisationService.getLocalizedValue(forKey: "login_change_phone_email")
        ui_label_info_send.text = OTLocalisationService.getLocalizedValue(forKey: "login_change_send_ok")
        
        ui_tf_old_phone.placeholder = OTLocalisationService.getLocalizedValue(forKey: "login_change_phone_old_number_placeholder")
        ui_tf_new_phone.placeholder = OTLocalisationService.getLocalizedValue(forKey: "login_change_phone_new_number_placeholder")
        ui_tf_email.placeholder = OTLocalisationService.getLocalizedValue(forKey: "login_change_phone_email_placeholder")
        
        ui_button_validate.setTitle(OTLocalisationService.getLocalizedValue(forKey: "login_change_phone_bt_validate"), for: .normal)
        ui_button_back.setTitle(OTLocalisationService.getLocalizedValue(forKey: "login_change_bt_return"), for: .normal)
        
        
        ui_view_send_ok.isHidden = true
        ui_button_validate.layer.cornerRadius = 8
        
        ui_button_back.layer.cornerRadius = 8
        ui_button_back.layer.borderWidth = 1
        ui_button_back.layer.borderColor = UIColor.appOrange().cgColor
        
        roundView(textfield: ui_tf_old_phone)
        roundView(textfield: ui_tf_new_phone)
        roundView(textfield: ui_tf_email)
        ui_tf_email.hasDoneButton = true
    }
    
    func roundView(textfield: UITextField) {
        textfield.backgroundColor = UIColor.white
        textfield.layer.cornerRadius = 4
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.init(red: 225 / 255.0, green: 228 / 255.0, blue: 232 / 255.0, alpha: 1).cgColor
    }
    
    func checkAndSend() {
        var isPhoneOK = true
        var oldPhone = ""
        var newPhone = ""
        var email:String? = nil
        
        if  ui_tf_old_phone?.text?.count ?? 0 <= 9 {
            isPhoneOK = false
        }
        if  ui_tf_new_phone?.text?.count ?? 0 <= 9 {
            isPhoneOK = false
        }
        
        if !isPhoneOK {
            self.showError(title: OTLocalisationService.getLocalizedValue(forKey:"login_change_warning_title"), message: OTLocalisationService.getLocalizedValue(forKey:"login_change_error_phone"))
           
            return
        }
        
        oldPhone = ui_tf_old_phone.text!
        newPhone = ui_tf_new_phone.text!
        
        if let _email = ui_tf_email?.text, _email.count > 0 {
            if !_email.isValidEmail {
                showError(title: OTLocalisationService.getLocalizedValue(forKey:"login_change_warning_title"), message: OTLocalisationService.getLocalizedValue(forKey:"login_change_error_mail"))
                return
            }
            email = _email
        }
        
        OTLoginChangeService.postChangePhone(oldPhone: oldPhone, newPhone: newPhone, email: email) { isOk in
            if isOk {
                self.ui_view_send_ok.isHidden = false
            }
            else {
                self.showError(title: OTLocalisationService.getLocalizedValue(forKey:"login_change_error_return"), message: OTLocalisationService.getLocalizedValue(forKey: "login_change_error_return_detail"))
            }
        }
    }
    
    func showError(title:String,message:String) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { action in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        
        self.navigationController?.present(alertVC, animated: true, completion: nil)
    }
    
    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func action_send_change(_ sender: Any) {
        checkAndSend()
    }
}

//MARK: - UITextfieldDelegate -
extension OTLoginChangePhoneViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ui_tf_email {
            textField.resignFirstResponder()
        }
        return true
    }
}


//MARK: - Network OTLoginChangeService -
struct OTLoginChangeService {
    static func postChangePhone(oldPhone:String, newPhone:String,email:String?, completion: @escaping (_ isOk: Bool)->()) {
        let manager = OTHTTPRequestManager.sharedInstance()
        
        let url = API_URL_SEND_CHANGE_CODE
        
        var params:[String:Any]
        
        if let _email = email {
            params = ["user":["current_phone":oldPhone,"requested_phone":newPhone,"email":_email]]
        }
        else {
            params = ["user":["current_phone":oldPhone,"requested_phone":newPhone]]
        }
        
        manager?.post(withUrl: url, andParameters: params, andSuccess: { (response) in
            completion(true)
        }, andFailure: { (error) in
            Logger.print("***** return post Share error \(String(describing: error))")
            completion(false)
        })
    }
}

//
//  OTLoginChangePhoneViewController.swift
//  entourage
//
//  Created by Jr on 28/05/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit

class OTLoginChangePhoneViewController: UIViewController {

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
    
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_main_container_view: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_main_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius

        ui_top_view.populateCustom(title: "login_change_phone_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 24), titleColor: .white, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
        ui_label_old_number.text =  "login_change_phone_old_number".localized
        ui_label_new_number.text =  "login_change_phone_new_number".localized
        ui_label_email.text =  "login_change_phone_email".localized
        ui_label_info_send.text =  "login_change_send_ok".localized
        
        ui_tf_old_phone.placeholder =  "login_change_phone_old_number_placeholder".localized
        ui_tf_new_phone.placeholder =  "login_change_phone_new_number_placeholder".localized
        ui_tf_email.placeholder =  "login_change_phone_email_placeholder".localized
        
        ui_button_validate.setTitle( "login_change_phone_bt_validate".localized, for: .normal)
        ui_button_back.setTitle( "login_change_bt_return".localized, for: .normal)
        
        ui_view_send_ok.isHidden = true
        ui_button_validate.layer.cornerRadius = ui_button_validate.frame.height / 2
        
        ui_button_back.layer.cornerRadius = 8
        ui_button_back.layer.borderWidth = 1
        ui_button_back.layer.borderColor = UIColor.appOrange.cgColor
        
        ui_tf_email.hasDoneButton = true
        ui_tf_old_phone.hasDoneButton = true
        ui_tf_new_phone.hasDoneButton = true
        
        ui_label_info_send.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        
        ui_label_old_number.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_label_new_number.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_label_email.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        
        ui_tf_new_phone.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        ui_tf_old_phone.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        ui_tf_email.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        
        ui_button_validate.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc(size: 15))
        configureOrangeButton(ui_button_validate, withTitle: "login_change_phone_bt_validate".localized)
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
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
            self.showError(title: "login_change_warning_title".localized, message: "login_change_error_phone".localized)
           
            return
        }
        
        oldPhone = ui_tf_old_phone.text!
        newPhone = ui_tf_new_phone.text!
        
        if let _email = ui_tf_email?.text, _email.count > 0 {
            if !_email.isValidEmail {
                showError(title: "login_change_warning_title".localized, message: "login_change_error_mail".localized)
                return
            }
            email = _email
        }
        
        OTLoginChangeService.postChangePhone(oldPhone: oldPhone, newPhone: newPhone, email: email) { [weak self] errorStr in
            if let errorStr = errorStr {
                self?.showError(title: "login_change_error_return".localized, message: errorStr)
            }
            else {
                DispatchQueue.main.async {
                    self?.ui_view_send_ok.isHidden = false
                    self?.ui_button_validate.isHidden = true
                }
            }
        }
    }
    
    func showError(title:String,message:String) {
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction.init(title: "OK", style: .default, handler: { action in
            alertVC.dismiss(animated: true, completion: nil)
        }))
        
        DispatchQueue.main.async {
            self.navigationController?.present(alertVC, animated: true, completion: nil)
        }
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
    static func postChangePhone(oldPhone:String, newPhone:String,email:String?, completion: @escaping (_ error: String?)->()) {

        var params:[String:Any]
        
        if let _email = email {
            params = ["user":["current_phone":oldPhone,"requested_phone":newPhone,"email":_email]]
        }
        else {
            params = ["user":["current_phone":oldPhone,"requested_phone":newPhone]]
        }
        let bodyData = try! JSONSerialization.data(withJSONObject: params, options: [])
        
        NetworkManager.sharedInstance.requestPost(endPoint: kAPIChangePhone, headers: nil, body: bodyData) { (data, resp, error) in
           
            if let error = error {
                completion(checkPhoneChangeError(error: error.code))
            }
            else {
                completion(nil)
            }
        }
    }
    
    private static func checkPhoneChangeError(error:String) -> String {
        var message = ""
        
        if error.contains("USER_NOT_FOUND") {
            message = "login_change_error_not_found".localized
        }
        else if error.contains("USER_DELETED") {
            message = "login_change_error_deleted".localized
        }
        else if error.contains("USER_BLOCKED") {
            message = "login_change_error_blocked".localized
        }
        else if error.contains("IDENTICAL_PHONES") {
            message = "login_change_error_identical".localized
        }
        else {
            message = "login_change_error_generic".localized
        }
        
        return message
    }
}

//MARK: - MJNavBackViewDelegate -
extension OTLoginChangePhoneViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
    func didTapEvent() {
        //Nothing yet
    }
}

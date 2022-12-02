//
//  OTLoginV2ViewController.swift
//  entourage
//
//  Created by Jr on 14/05/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import IHProgressHUD
import IQKeyboardManagerSwift

class OTLoginV2ViewController: UIViewController {
    
    @IBOutlet weak var ui_constraint_top: NSLayoutConstraint!
    @IBOutlet weak var ui_constraint_height_logo: NSLayoutConstraint!
    @IBOutlet weak var ui_view_container: UIView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_country: UILabel!
    @IBOutlet weak var ui_label_phone: UILabel!
    @IBOutlet weak var ui_label_code: UILabel!
    @IBOutlet weak var ui_bt_validate: UIButton!
    
    @IBOutlet weak var ui_bt_demand_code: UIButton!
    @IBOutlet weak var ui_tf_country: OTCustomTextfield!
    @IBOutlet weak var ui_tf_phone: OTCustomTextfield!
    
    @IBOutlet weak var ui_tf_code: OTCustomTextfield!
    @IBOutlet weak var ui_pickerView: UIPickerView!
    
    @IBOutlet weak var ui_button_change_phone: UIButton!
    var deeplink:URL? = nil
    
    var pickerDataSource: OTCountryCodePickerViewDataSource!
    var countryCode = "+33"
    var tempPhone = ""
    let minimumCharacters = 9
    
    var isLoading = false
    
    let timeOutLength = 60
    var timeOut = 60
    var countDownTimer:Timer? = nil
    
    //MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        pickerDataSource = OTCountryCodePickerViewDataSource.sharedInstance()
        
        ui_tf_country.activateToolBarWithTitle()
        ui_tf_country.text = countryCode
        ui_tf_country.inputView = ui_pickerView
        
        for i in 0...pickerDataSource.count() {
            if pickerDataSource.getCountryCode(forRow: i) == countryCode {
                ui_pickerView.selectRow(i, inComponent: 0, animated: false)
                break
            }
        }
        
        setupViews()
//        OTLogger.logEvent(View_Login_Login)
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = true
    }
    
    override func viewWillLayoutSubviews() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
    }
    
    deinit {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    //MARK: - Methods -
    
    func setupViews() {
        ui_bt_validate.layer.cornerRadius = 8
        ui_view_container.layer.cornerRadius = 8
        ui_view_container.layer.borderWidth = 1
        ui_view_container.layer.borderColor = UIColor.init(red: 245 / 255.0, green: 95 / 255.0, blue: 36 / 255.0, alpha: 1.0).cgColor
        
        roundView(textfield: ui_tf_code)
        roundView(textfield: ui_tf_phone)
        roundView(textfield: ui_tf_country)
        //ui_tf_code.hasDoneButton = true
        
        if view.frame.height <= 667 {
            ui_constraint_height_logo.constant = 140
            
            if view.frame.height <= 568 {
                ui_constraint_top.constant = 20
                ui_constraint_height_logo.constant = 80
            }
            self.view.layoutIfNeeded()
        }
        
        ui_tf_phone.placeholder =  "login_phone_placeholder".localized
        ui_tf_code.placeholder =  "login_placeholder_code".localized
        ui_bt_validate.setTitle( "login_button_connect".localized.uppercased(), for: .normal)
        ui_bt_demand_code.setTitle( "login_button_resend_code".localized, for: .normal)
        ui_label_title.text =  "login_title".localized
        ui_label_country.text =  "login_label_country".localized
        ui_label_phone.text =  "login_label_phone".localized
        ui_label_code.text =  "login_label_code".localized
        
        ui_button_change_phone.setTitle( "login_button_change_phone".localized, for: .normal)
    }
    
    func roundView(textfield: UITextField) {
        textfield.backgroundColor = UIColor.white
        textfield.layer.cornerRadius = 4
        textfield.layer.borderWidth = 1
        textfield.layer.borderColor = UIColor.init(red: 225 / 255.0, green: 228 / 255.0, blue: 232 / 255.0, alpha: 1).cgColor
    }
    
    func checkAndValidate() {
        var isValidated = true
        var message = ""
        if ui_tf_phone.text?.count ?? 0 < minimumCharacters {
            isValidated = false
            message = String.init(format:  "error_login_phone_length".localized, minimumCharacters)
        }
        
        if isValidated && ui_tf_code.text?.count != 6 {
            isValidated = false
            message = "error_login_code_lenght".localized
        }
        
        if !isValidated {
            let alertVC = UIAlertController.init(title:  "attention_pop_title".localized, message: message, preferredStyle: .alert)
            let action = UIAlertAction.init(title:  "close".localized, style: .default, handler: nil)
            
            alertVC.addAction(action)
            self.navigationController?.present(alertVC, animated: true, completion: nil)
            return
        }
        
        var phone = ""
        if let _phone = ui_tf_phone.text {
            phone = Utils.validatePhoneFormat(countryCode: countryCode, phone: _phone)
        }
        
        if !isLoading {
            isLoading = true
            login(phone: phone, code: ui_tf_code.text!)
            stopTimer()
        }
    }
    
    func checkAndResendCode() {
        if ui_tf_phone.text?.count ?? 0 < minimumCharacters {
            let message = String.init(format:  "error_login_phone_length".localized, minimumCharacters)
            let alertVC = UIAlertController.init(title:  "attention_pop_title".localized, message: message, preferredStyle: .alert)
            let action = UIAlertAction.init(title:  "close".localized, style: .default, handler: nil)
            
            alertVC.addAction(action)
            self.navigationController?.present(alertVC, animated: true, completion: nil)
            return
        }
        
        if timeOut > 0 && timeOut != timeOutLength {
            let alertvc = UIAlertController.init(title:  "attention_pop_title".localized, message: String.init(format:  "onboard_sms_pop_alert".localized, timeOut), preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
            alertvc.addAction(action)
            
            self.navigationController?.present(alertvc, animated: true, completion: nil)
        }
        else {
            var phone = ""
            if let _phone = ui_tf_phone.text {
                phone = _phone.trimmingCharacters(in: .whitespaces)
                if !phone.hasPrefix("+") && phone.hasPrefix("0") {
                    phone.remove(at: .init(encodedOffset: 0))
                }
                phone = "\(countryCode)\(phone)"
            }
            resendCode(phone: phone)
        }
    }
    
    @objc func updateTimer() {
        timeOut = timeOut - 1
        if timeOut == 0 {
            stopTimer()
        }
        Logger.print("Update Timer")
    }
    
    func stopTimer() {
        countDownTimer?.invalidate()
        countDownTimer = nil
    }
    
    func startTimer() {
        timeOut = timeOutLength
        countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    func goalRealMain() {
        AppState.continueFromLoginVC()
        
        if (self.deeplink != nil) {
            //TODO: a faire
           // OTDeepLinkService.init().handleDeepLink(self.deeplink)
            self.deeplink = nil;
        }
    }
    
    //MARK: - Network -
    func login(phone:String, code:String) {
        
        IHProgressHUD.show()
//        OTLogger.logEvent(Action_Login_Submit)//TODO: a faire
        
        AuthService.postLogin(phone: phone, password: code) { [weak self] (user, error, isFirstLogin) in
            IHProgressHUD.dismiss()
            
            if let error = error {
                Logger.print("Erreur Network login: \(String(describing: error))")
                self?.isLoading = false
                
                self?.parseErrorLogin(error: error)
            }
            else {
                Logger.print("login return user ok  : \(user) first login ? \(isFirstLogin)")
                if user == nil {
                    self?.parseErrorLogin(error: EntourageNetworkError())
                    return //TODO
                }
                var newUser = user
                
                self?.isLoading = false
                newUser?.phone = phone
                UserDefaults.currentUser = newUser
                UserDefaults.temporaryUser = nil
                //TODO: a voir
                //            OTLogger.logEvent(Action_Login_Success)
                
                self?.goalRealMain()
            }
        }
    }
    
    func parseErrorLogin(error:EntourageNetworkError) {
        var alertTitle =  "error".localized
        var alertText =  "connection_error".localized
        var buttonTitle =  "ok".localized
        
        if error.code.contains("UNAUTHORIZED") {
            alertTitle =  "tryAgain".localized
            alertText =  "error_login_phoneNumberOrCode".localized
            buttonTitle =  "tryAgain_short".localized
            
            //                    OTLogger.logEvent(Error_Login_Fail)
        }
        else if  error.code.contains("INVALID_PHONE_FORMAT") {
            alertTitle =  "tryAgain".localized
            alertText =  "error_login_phoneNumberFormat".localized
            buttonTitle =  "tryAgain_short".localized
            
            //                    OTLogger.logEvent(Error_Login_Phone)
        }
        else if let errorCode = error.error as NSError?, errorCode.code == NSURLErrorNotConnectedToInternet {
            alertTitle =  "tryAgain".localized
            alertText = errorCode.localizedDescription
            buttonTitle =  "tryAgain_short".localized
            
            //                    OTLogger.logEvent(Error_Login_Error)
        }
        
        let alertvc = UIAlertController.init(title: alertTitle, message: alertText, preferredStyle: .alert)
        
        let action = UIAlertAction.init(title: buttonTitle, style: .default, handler: nil)
        alertvc.addAction(action)
        DispatchQueue.main.async {
            self.navigationController?.present(alertvc, animated: true, completion: nil)
        }
    }
    
    func resendCode(phone:String) {
        IHProgressHUD.show()
        //        OTLogger.logEvent(Action_Login_SMS)
        
        AuthService.regenerateSecretCode(phone: phone) { [weak self] error in
            Logger.print("***** return resned code ;) error? \(error)")
            if let error = error {
                IHProgressHUD.dismiss()
                var _message =  "requestNotSent".localized
                if error.code.contains("USER_NOT_FOUND") {
                    _message =  "error_login_resendCode_unknow".localized
                }
                
                let alertvc = UIAlertController.init(title:  "error".localized, message: _message, preferredStyle: .alert)
                
                let action = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
                alertvc.addAction(action)
                
                self?.navigationController?.present(alertvc, animated: true, completion: nil)
            }
            else {
                IHProgressHUD.dismiss()
                IHProgressHUD.showSuccesswithStatus( "requestSent".localized)
                self?.startTimer()
            }
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_validate(_ sender: Any) {
        checkAndValidate()
    }
    
    @IBAction func action_tapview(_ sender: Any) {
        ui_tf_country.resignFirstResponder()
        ui_tf_phone.resignFirstResponder()
        ui_tf_code.resignFirstResponder()
    }
    
    @IBAction func action_demand_code(_ sender: Any) {
        checkAndResendCode()
    }
    
    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func action_show_change_phone(_ sender: UIButton) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "ChangePhoneVC") {
        self.navigationController?.pushViewController(vc, animated: true)
        }
        
    }
}

//MARK: - UITextfieldDelegate -
extension OTLoginV2ViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ui_tf_code {
            textField.resignFirstResponder()
            checkAndValidate()
        }
        return true
    }
}

//MARK: - uipickerView datasource / Delegate -
extension OTLoginV2ViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerDataSource.count()
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerDataSource.getTitleForRow(row)
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = self.pickerDataSource.getTitleForRow(row)!
        let attrString = NSAttributedString.init(string: title, attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
        return attrString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        ui_tf_country.text = pickerDataSource.getCountryCode(forRow: row)
        countryCode = pickerDataSource.getCountryCode(forRow: row)
    }
}

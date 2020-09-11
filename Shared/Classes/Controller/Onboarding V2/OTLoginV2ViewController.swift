//
//  OTLoginV2ViewController.swift
//  entourage
//
//  Created by Jr on 14/05/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit
import SVProgressHUD

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
    
    @objc var fromLink:URL? = nil
    
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
        OTLogger.logEvent(View_Login_Login)
    }
    
    override func viewWillLayoutSubviews() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        stopTimer()
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
        ui_tf_code.hasDoneButton = true
        
        if view.frame.height <= 667 {
            ui_constraint_height_logo.constant = 140
            
            if view.frame.height <= 568 {
                ui_constraint_top.constant = 20
                ui_constraint_height_logo.constant = 80
            }
            self.view.layoutIfNeeded()
        }
        
        ui_tf_phone.placeholder = OTLocalisationService.getLocalizedValue(forKey: "login_phone_placeholder")
        ui_tf_code.placeholder = OTLocalisationService.getLocalizedValue(forKey: "login_placeholder_code")
        ui_bt_validate.setTitle(OTLocalisationService.getLocalizedValue(forKey: "login_button_connect")?.uppercased(), for: .normal)
        ui_bt_demand_code.setTitle(OTLocalisationService.getLocalizedValue(forKey: "login_button_resend_code"), for: .normal)
        ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "login_title")
        ui_label_country.text = OTLocalisationService.getLocalizedValue(forKey: "login_label_country")
        ui_label_phone.text = OTLocalisationService.getLocalizedValue(forKey: "login_label_phone")
        ui_label_code.text = OTLocalisationService.getLocalizedValue(forKey: "login_label_code")
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
            message = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "error_login_phone_length"), minimumCharacters)
        }
        
        if isValidated && ui_tf_code.text?.count != 6 {
            isValidated = false
            message = OTLocalisationService.getLocalizedValue(forKey:"error_login_code_lenght")
        }
        
        if !isValidated {
            let alertVC = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "attention_pop_title"), message: message, preferredStyle: .alert)
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "close"), style: .default, handler: nil)
            
            alertVC.addAction(action)
            self.navigationController?.present(alertVC, animated: true, completion: nil)
            return
        }
        
        var phone = ""
        if let _phone = ui_tf_phone.text {
            phone = Utilitaires.validatePhoneFormat(countryCode: countryCode, phone: _phone)
        }
        
        if !isLoading {
            isLoading = true
            login(phone: phone, code: ui_tf_code.text!)
            stopTimer()
        }
    }
    
    func checkAndResendCode() {
        if ui_tf_phone.text?.count ?? 0 < minimumCharacters {
            let message = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "error_login_phone_length"), minimumCharacters)
            let alertVC = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "attention_pop_title"), message: message, preferredStyle: .alert)
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "close"), style: .default, handler: nil)
            
            alertVC.addAction(action)
            self.navigationController?.present(alertVC, animated: true, completion: nil)
            return
        }
        
        if timeOut > 0 && timeOut != timeOutLength {
            let alertvc = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "attention_pop_title"), message: String.init(format: OTLocalisationService.getLocalizedValue(forKey: "onboard_sms_pop_alert"), timeOut), preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey:"OK"), style: .default, handler: nil)
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
    
    func goLoginNext(user:OTUser?) {
        let vc = storyboard?.instantiateViewController(withIdentifier: "LoginNextVC") as! OTLoginNextViewController
        vc.currentUser = user
        if let appDelegate = UIApplication.shared.delegate, let window = appDelegate.window {
            window?.rootViewController = vc
            window?.makeKeyAndVisible()
        }
    }
    
    func goalRealMain() {
        OTAppState.continueFromLoginVC()
        
        if (self.fromLink != nil) {
            OTDeepLinkService.init().handleDeepLink(self.fromLink)
            self.fromLink = nil;
        }
    }
    
    //MARK: - Network -
    func login(phone:String, code:String) {
        
        SVProgressHUD.show()
        OTLogger.logEvent(Action_Login_Submit)
        OTAuthService.init().auth(withPhone: phone, password: code, success: { (user, isFirstlogin) in
            SVProgressHUD.dismiss()
            self.isLoading = false
            user?.phone = phone
            UserDefaults.standard.currentUser = user
            UserDefaults.standard.temporaryUser = nil
            UserDefaults.standard.setFirstLoginState(!isFirstlogin)
            
            UserDefaults.standard.set(true, forKey: "checkAfterLogin")
            
            OTLogger.logEvent(Action_Login_Success)
            
            if OTAppConfiguration.supportsTourFunctionality() {
                UserDefaults.standard.set(false, forKey: "user_tours_only")
            }
            
            if user?.addressPrimary == nil || user?.email?.count == 0 {
                self.goLoginNext(user:user)
            }
            else {
                self.goalRealMain()
            }
            
        }) { (error) in
            self.isLoading = false
            SVProgressHUD.dismiss()
            if let _err = error as NSError? {
                var alertTitle = OTLocalisationService.getLocalizedValue(forKey: "error")
                var alertText = OTLocalisationService.getLocalizedValue(forKey: "connection_error")
                var buttonTitle = OTLocalisationService.getLocalizedValue(forKey: "ok")
                
                var _errString = ""
                if let _string = _err.userInfo["JSONResponseSerializerFullKey"] as? String {
                    _errString = _string
                }
                
                if _errString.contains("UNAUTHORIZED") {
                    alertTitle = OTLocalisationService.getLocalizedValue(forKey: "tryAgain")
                    alertText = OTLocalisationService.getLocalizedValue(forKey: "invalidPhoneNumberOrCode")
                    buttonTitle = OTLocalisationService.getLocalizedValue(forKey: "tryAgain_short")
                    
                    OTLogger.logEvent(Error_Login_Fail)
                }
                else if _errString.contains("INVALID_PHONE_FORMAT") {
                    alertTitle = OTLocalisationService.getLocalizedValue(forKey: "tryAgain")
                    alertText = OTLocalisationService.getLocalizedValue(forKey: "invalidPhoneNumberFormat")
                    buttonTitle = OTLocalisationService.getLocalizedValue(forKey: "tryAgain_short")
                    
                    OTLogger.logEvent(Error_Login_Phone)
                }
                else if _err.code == NSURLErrorNotConnectedToInternet {
                    alertTitle = OTLocalisationService.getLocalizedValue(forKey: "tryAgain")
                    alertText = _err.localizedDescription
                    buttonTitle = OTLocalisationService.getLocalizedValue(forKey: "tryAgain_short")
                    
                    OTLogger.logEvent(Error_Login_Error)
                }
                
                let alertvc = UIAlertController.init(title: alertTitle, message: alertText, preferredStyle: .alert)
                
                let action = UIAlertAction.init(title: buttonTitle, style: .default, handler: nil)
                alertvc.addAction(action)
                DispatchQueue.main.async {
                    self.navigationController?.present(alertvc, animated: true, completion: nil)
                }
            }
        }
    }
    
    func resendCode(phone:String) {
        SVProgressHUD.show()
        OTLogger.logEvent(Action_Login_SMS)
        
        OTAuthService.init().regenerateSecretCode(phone, success: { (user) in
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: OTLocalisationService.getLocalizedValue(forKey: "requestSent"))
            self.startTimer()
        }) { (error) in
            SVProgressHUD.dismiss()
            var _message = OTLocalisationService.getLocalizedValue(forKey: "requestNotSent")
            if let _err = error as NSError?, let _string = _err.userInfo["JSONResponseSerializerFullKey"] as? String {
                if _string.contains("USER_NOT_FOUND") {
                    _message = OTLocalisationService.getLocalizedValue(forKey: "error_login_resendCode_unknow")
                }
            }
            
            let alertvc = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "error"), message: _message, preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey:"OK"), style: .default, handler: nil)
            alertvc.addAction(action)
            DispatchQueue.main.async {
                self.navigationController?.present(alertvc, animated: true, completion: nil)
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

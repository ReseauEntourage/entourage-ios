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
import SimpleKeychain

class OTLoginV2ViewController: UIViewController {
    
    @IBOutlet weak var ui_label_country: UILabel!
    @IBOutlet weak var ui_label_phone: UILabel!
    @IBOutlet weak var ui_label_code: UILabel!
    @IBOutlet weak var ui_bt_validate: UIButton!
    
    @IBOutlet weak var ui_bt_demand_code: UIButton!
    @IBOutlet weak var ui_tf_country: OTCustomTextfield!
    @IBOutlet weak var ui_tf_phone: OTCustomTextfield!
    
    @IBOutlet weak var ui_tf_code: OTCustomTextfield!
    @IBOutlet weak var ui_pickerView: UIPickerView!
    
    @IBOutlet weak var ui_main_container_view: UIView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    @IBOutlet weak var ui_button_change_phone: UIButton!
    var deeplink:URL? = nil
    
    let pickerDatas:[CountryCode] = [CountryCode(country: "France",code: "+33",flag:"🇫🇷"),CountryCode(country: "Belgique",code: "+32",flag: "🇧🇪")]
    
    var countryCode:CountryCode = defaultCountryCode
    var tempPhone = ""
    let minimumCharacters = 9
    var phoneNumberString = ""
    
    var isLoading = false
    
    let timeOutLength = 60
    var timeOut = 60
    var countDownTimer:Timer? = nil
    
    var hasKeychain = false
    
    //MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_main_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_top_view.populateCustom(title: "login_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 24), titleColor: .white, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
        
        ui_tf_phone.activateToolBarWithTitle( "close".localized)
        ui_tf_code.activateToolBarWithTitle( "close".localized)
        ui_tf_country.activateToolBarWithTitle()
        ui_tf_country.text = countryCode.flag
        ui_tf_country.inputView = ui_pickerView
        
        setupViews()
        
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
        
        selectPickerCountry()
        
        if hasKeychain {
            let phone = A0SimpleKeychain().string(forKey:kKeychainPhone)
            let pwd = A0SimpleKeychain().string(forKey:kKeychainPassword)
            
            if let phone = phone, let pwd = pwd {
                ui_tf_phone.text = phone
                ui_tf_code.text = pwd
            }
        }
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
    
    private func selectPickerCountry() {
        for i in 0...pickerDatas.count {
            if pickerDatas[i].code == countryCode.code {
                ui_pickerView.selectRow(i, inComponent: 0, animated: false)
                break
            }
        }
    }
    
    func setupViews() {
        ui_bt_validate.layer.cornerRadius = ui_bt_validate.frame.height / 2
        ui_bt_validate.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc(size: 15))
        
        ui_tf_phone.placeholder =  "login_phone_placeholder".localized
        ui_tf_code.placeholder =  "login_placeholder_code".localized
        ui_bt_validate.setTitle( "login_button_connect".localized, for: .normal)
        
        ui_bt_demand_code.setAttributedTitle(Utils.formatStringUnderline(textString: "login_button_resend_code".localized, textColor: .appOrange,font: ApplicationTheme.getFontNunitoRegular(size: 14)), for: .normal)

        ui_label_country.text =  "login_label_country".localized
        ui_label_phone.text =  "login_label_phone".localized
        ui_label_code.text =  "login_label_code".localized
        ui_label_country.isHidden = true

        ui_button_change_phone.setAttributedTitle(Utils.formatStringUnderline(textString: "login_button_change_phone".localized, textColor: .appGrisSombre40, font: ApplicationTheme.getFontNunitoRegular(size: 14)), for: .normal)
        
        
        ui_tf_country.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        ui_tf_phone.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        ui_tf_code.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        
        ui_label_country.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_label_phone.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_label_code.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
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
            phone = Utils.validatePhoneFormat(countryCode: countryCode.code, phone: _phone)
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
                phone = "\(countryCode.code)\(phone)"
            }
            phoneNumberString = phone
            alertForResent()
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
        }
        else if  error.code.contains("INVALID_PHONE_FORMAT") {
            alertTitle =  "tryAgain".localized
            alertText =  "error_login_phoneNumberFormat".localized
            buttonTitle =  "tryAgain_short".localized
        }
        else if let errorCode = error.error as NSError?, errorCode.code == NSURLErrorNotConnectedToInternet {
            alertTitle =  "tryAgain".localized
            alertText = errorCode.localizedDescription
            buttonTitle =  "tryAgain_short".localized
        }
        
        let alertvc = UIAlertController.init(title: alertTitle, message: alertText, preferredStyle: .alert)
        
        let action = UIAlertAction.init(title: buttonTitle, style: .default, handler: nil)
        alertvc.addAction(action)
        DispatchQueue.main.async {
            self.navigationController?.present(alertvc, animated: true, completion: nil)
        }
    }
    
    func alertForResent(){
        let message = "login_resend_code_message".localized + phoneNumberString
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "login_resend_code_button_no".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "login_resend_code_button_yes".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: "login_resend_code_title".localized, message: message, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        
        alertVC.delegate = self
        alertVC.show()
    }
    
    func resendCode(phone:String) {
        IHProgressHUD.show()
        
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
        return pickerDatas.count
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return "\(pickerDatas[row].flag) \(pickerDatas[row].country)"
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = "\(pickerDatas[row].flag) \(pickerDatas[row].country)"
        let attrString = NSAttributedString.init(string: title, attributes: [NSAttributedString.Key.foregroundColor:UIColor.black])
        return attrString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        ui_tf_country.text = pickerDatas[row].flag
        countryCode = pickerDatas[row]
    }
}

//MARK: - MJNavBackViewDelegate -
extension OTLoginV2ViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

extension OTLoginV2ViewController:MJAlertControllerDelegate{
    func validateLeftButton(alertTag: MJAlertTAG) {
        self.dismiss(animated: true)
    }
    
    func validateRightButton(alertTag: MJAlertTAG) {
        resendCode(phone: phoneNumberString)

    }
    
    
}

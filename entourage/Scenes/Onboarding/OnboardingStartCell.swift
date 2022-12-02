//
//  OnboardingStartCell.swift
//  entourage
//
//  Created by You on 01/12/2022.
//

import UIKit


class OnboardingStartCell: UITableViewCell {

    @IBOutlet weak var ui_title_firstname: UILabel!
    @IBOutlet weak var ui_title_lastname: UILabel!
    @IBOutlet weak var ui_title_country: UILabel!
    @IBOutlet weak var ui_title_phone: UILabel!
    @IBOutlet weak var ui_title_email: UILabel!
    
    @IBOutlet weak var ui_info_mailing: UILabel!
    
    @IBOutlet weak var ui_info_lastname: UILabel!
    @IBOutlet weak var ui_tf_firstname: UITextField!
    @IBOutlet weak var ui_tf_lastname: UITextField!
    @IBOutlet weak var ui_tf_country: OTCustomTextfield!
    @IBOutlet weak var ui_tf_phone: OTCustomTextfield!
    @IBOutlet weak var ui_tf_email: UITextField!
    
    @IBOutlet weak var ui_error_firstname: MJErrorInputTextView!
    @IBOutlet weak var ui_error_lastname: MJErrorInputTextView!
    @IBOutlet weak var ui_error_phone: MJErrorInputTextView!
    @IBOutlet weak var ui_error_email: MJErrorInputTextView!
    @IBOutlet weak var ui_iv_check: UIImageView!
    
    @IBOutlet weak var ui_pickerView: UIPickerView!
    
    @IBOutlet weak var ui_view_info_mandatory: UIView!
    
    @IBOutlet weak var ui_label_mandatory: UILabel!
    
    weak var delegate:OnboardingStartDelegate? = nil
    let minimumCharacters = 2
    

        //PHone
    var countryCode:CountryCode = defaultCountryCode
    var tempPhone = ""
    let minimumPhoneCharacters = 9
    
    let pickerDatas:[CountryCode] = [CountryCode(country: "France",code: "+33",flag:"🇫🇷"),CountryCode(country: "Belgique",code: "+32",flag: "🇧🇪")]
    
    var isChecked = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupTitles()
        
        ui_tf_firstname.delegate = self
        ui_tf_lastname.delegate = self
        ui_tf_email.delegate = self
        ui_tf_phone.delegate = self
        
        ui_error_firstname.isHidden = true
        ui_error_lastname.isHidden = true
        ui_error_phone.isHidden = true
        ui_error_email.isHidden = true
        
        ui_error_firstname.setupView(title: "onboard_error_firstname".localized)
        ui_error_lastname.setupView(title: "onboard_error_lastname".localized)
        ui_error_phone.setupView(title: "onboard_error_phone".localized)
        ui_error_email.setupView(title: "onboard_error_email".localized)
        
        
        ui_tf_phone.activateToolBarWithTitle( "close".localized)
        ui_tf_country.activateToolBarWithTitle()
        ui_tf_phone.text = tempPhone
        ui_tf_country.text = countryCode.flag
        ui_tf_country.inputView = ui_pickerView
        
       selectPickerCountry()
        
        ui_pickerView.dataSource = self
        ui_pickerView.delegate = self
    }
    
    private func setupTitles() {
        ui_title_firstname.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_title_lastname.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_title_country.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_title_phone.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 17))
        ui_info_mailing.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
        ui_info_lastname.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
        ui_label_mandatory.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 12))
        
        ui_info_lastname.text = "onboard_welcome_info".localized
        
        ui_title_firstname.text = "onboard_welcome_firstname".localized
        ui_title_lastname.text = "onboard_welcome_lastname".localized
    
        ui_tf_firstname.placeholder = "onboard_welcome_placeholder_firstname".localized
        ui_tf_lastname.placeholder = "onboard_welcome_placeholder_lastname".localized
        
        ui_title_country.text = "onboard_welcome_country".localized
        ui_title_phone.text = "onboard_welcome_phone".localized
        ui_title_email.text = "onboard_welcome_mail".localized
        ui_info_mailing.text = "onboard_welcome_consent".localized
        ui_tf_phone.placeholder = "0600000000"
        ui_tf_email.placeholder = "onboard_welcome_placeholder_mail".localized
        ui_label_mandatory.text = "onboard_welcome_info_mandatory".localized
        
        ui_view_info_mandatory.layer.cornerRadius = 15
    }

    func populateCell(username:String?, lastname:String?,countryCode:CountryCode?, phone:String?,email:String?, isCheck:Bool, delegate:OnboardingStartDelegate) {
        self.delegate = delegate
        
        ui_tf_firstname.text = username
        ui_tf_lastname.text = lastname
        ui_tf_phone.text = phone
        ui_tf_email.text = email
        
        if let countryCode = countryCode {
            self.countryCode = countryCode
        }
        selectPickerCountry()
        _ = checkAndValidateFirstLastnames()
        _ = checkAndValidatePhone()
        _ = checkAndValidateEmail()
        
        self.isChecked = isCheck
        updateCheckImage()
    }
    
    private func selectPickerCountry() {
        for i in 0...pickerDatas.count {
            if pickerDatas[i].code == countryCode.code {
                ui_pickerView.selectRow(i, inComponent: 0, animated: false)
                break
            }
        }
    }
    @IBAction func action_check_unchek(_ sender: Any) {
        isChecked = !isChecked
        updateCheckImage()
        delegate?.validateConsent(isChecked: isChecked)
    }
    
    private func updateCheckImage() {
        ui_iv_check.image = isChecked ? UIImage.init(named: "checkbox_checked") : UIImage.init(named: "checkbox_unchecked")
    }
}


//MARK: - UITextfieldDelegate -
extension OnboardingStartCell: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == ui_tf_firstname || textField == ui_tf_lastname {
            if checkAndValidateFirstLastnames() {
                delegate?.validateFirstLastname(firstName: ui_tf_firstname.text, lastname: ui_tf_lastname.text)
            }
            else {
                delegate?.validateFirstLastname(firstName: nil, lastname: nil)
            }
        }
        
        else if textField == ui_tf_phone {
            if checkAndValidatePhone() {
                delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: ui_tf_phone.text)
            }
            else {
                delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: nil)
            }
        }
       else if checkAndValidateEmail() {
            delegate?.validateEmail(email: ui_tf_email.text)
        }
        else {
            delegate?.validateEmail(email: nil)
        }
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ui_tf_firstname {
            ui_tf_lastname.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
            if textField == ui_tf_lastname {
                if checkAndValidateFirstLastnames() {
                    delegate?.validateFirstLastname(firstName: ui_tf_firstname.text, lastname: ui_tf_lastname.text)
                }
                else {
                    delegate?.validateFirstLastname(firstName: nil, lastname: nil)
                }
            }
            else if textField == ui_tf_phone {
                if checkAndValidatePhone() {
                    delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: ui_tf_phone.text)
                }
                else {
                    delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: nil)
                }
            }
            else if textField == ui_tf_email {
                delegate?.validateEmail(email: ui_tf_email.text)
            }
            
            
        }
        return true
    }
    
    func checkAndValidateFirstLastnames() -> Bool {
        let firstCount = ui_tf_firstname.text?.count ?? 0
        let lastCount = ui_tf_lastname.text?.count ?? 0
        
        if firstCount >= minimumCharacters && lastCount >= minimumCharacters {
            ui_error_firstname.isHidden = true
            ui_error_lastname.isHidden = true
            return true
        }
        
        
        if firstCount >= minimumCharacters || firstCount == 0 {
            ui_error_firstname.isHidden = true
        }
        else {
            ui_error_firstname.isHidden = false
        }
        
        if lastCount >= minimumCharacters || lastCount == 0 {
            ui_error_lastname.isHidden = true
        }
        else {
            ui_error_lastname.isHidden = false
        }
        
        return false
    }
    
    func checkAndValidatePhone() -> Bool {
        
        if ui_tf_phone.text?.count ?? 0 >= minimumPhoneCharacters {
            ui_error_phone.isHidden = true
            return true
        }
        
        if ui_tf_phone.text?.count ?? 0 > 0 {
            ui_error_phone.isHidden = false
        }
        
        return false
    }
    
    func checkAndValidateEmail() -> Bool {
        
        if ui_tf_email.text?.isValidEmail ?? false  {
            ui_error_email.isHidden = true
            return true
        }
        
        if ui_tf_email.text?.count ?? 0 > 0 {
            ui_error_email.isHidden = false
        }
        else {
            ui_error_email.isHidden = true
        }
        
        return false
    }
}


//MARK: - uipickerView datasource / Delegate -
extension OnboardingStartCell: UIPickerViewDelegate,UIPickerViewDataSource {
    
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
        _ = checkAndValidatePhone()
        delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: ui_tf_phone.text)
    }
}


protocol OnboardingStartDelegate: AnyObject {
    func validateFirstLastname(firstName:String?,lastname:String?)
    func validatePhoneNumber(prefix:CountryCode,phoneNumber:String?)
    func validateEmail(email:String?)
    func validateConsent(isChecked:Bool)
}

//Phone
struct CountryCode {
    var country = ""
    var code = ""
    var flag = ""
}

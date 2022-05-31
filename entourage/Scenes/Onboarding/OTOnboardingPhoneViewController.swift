//
//  OTOnboardingPhoneViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTOnboardingPhoneViewController: UIViewController {
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_label_info: UILabel!
    @IBOutlet weak var ui_tf_phone_prefix: OTCustomTextfield!
    @IBOutlet weak var ui_tf_phone: OTCustomTextfield!
    @IBOutlet weak var ui_pickerView: UIPickerView!
    @IBOutlet weak var ui_label_error: UILabel!
    
    var pickerDataSource: OTCountryCodePickerViewDataSource!
    
    weak var delegate:OnboardV2Delegate? = nil
    var countryCode = "+33"
    var tempPhone = ""
    let minimumCharacters = 9
    var firstname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_label_error.text =  "onboarding_error_phone".localized
        ui_label_error.isHidden = true
        pickerDataSource = OTCountryCodePickerViewDataSource.sharedInstance()
        
        ui_tf_phone.activateToolBarWithTitle( "close".localized)
        ui_tf_phone_prefix.activateToolBarWithTitle()
        ui_tf_phone.text = tempPhone
        ui_tf_phone_prefix.text = countryCode
        ui_tf_phone_prefix.inputView = ui_pickerView
        
        for i in 0...pickerDataSource.count() {
            if pickerDataSource.getCountryCode(forRow: i) == countryCode {
                ui_pickerView.selectRow(i, inComponent: 0, animated: false)
                break
            }
        }
        
        if tempPhone.count  >= minimumCharacters {
            delegate?.updateButtonNext(isValid: true)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
        }
        
        populateViews()
//        OTLogger.logEvent(View_Onboarding_Phone)//TODO:  Analytics
        
        NotificationCenter.default.addObserver(self, selector: #selector(validateTf), name: NSNotification.Name(rawValue: OTCustomTextfield.validateNotif), object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func populateViews() {
        ui_label_title.text =
            String.init(format:  "onboard_phone_title".localized, firstname)
        ui_label_description.text =  "onboard_phone_sub".localized
        ui_tf_phone.placeholder =  "onboard_phone_placeholder_phone".localized
        ui_label_info.text =  "onboard_phone_info".localized
    }
    
    @IBAction func action_tap(_ sender: Any) {
        ui_tf_phone_prefix.resignFirstResponder()
        ui_tf_phone.resignFirstResponder()
    }
    
    @objc func validateTf() {
        if ui_tf_phone.text?.count ?? 0 >= minimumCharacters  {
            delegate?.updateButtonNext(isValid: true)
            delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber:ui_tf_phone.text)
            delegate?.goNextManually()
        }
    }
}

//MARK: - UITextfieldDelegate -
extension OTOnboardingPhoneViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ui_tf_phone.text?.count ?? 0 >= minimumCharacters  {
            delegate?.updateButtonNext(isValid: true)
            delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber:ui_tf_phone.text)
            ui_label_error.isHidden = true
        }
        else {
            delegate?.updateButtonNext(isValid: false)
            delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: nil)
            ui_label_error.isHidden = false
        }
        if view.frame.height <= 568 {
            view.frame.origin.y = view.frame.origin.y + 40
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if view.frame.height <= 568 {
            view.frame.origin.y = view.frame.origin.y - 40
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == ui_tf_phone {
            let inputLength = string.count > 0 ? 1 : -1
            if ((textField.text?.count ?? 0) + inputLength) >= 9 {
                ui_tf_phone.buttonToolBar?.title =  "next".localized
            }
            else {
                ui_tf_phone.buttonToolBar?.title =  "close".localized
            }
            textField.reloadInputViews()
        }
        
        return true
    }
}

//MARK: - uipickerView datasource / Delegate -
extension OTOnboardingPhoneViewController: UIPickerViewDelegate,UIPickerViewDataSource {
    
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
        
        ui_tf_phone_prefix.text = pickerDataSource.getCountryCode(forRow: row)
        countryCode = pickerDataSource.getCountryCode(forRow: row)
    }
}
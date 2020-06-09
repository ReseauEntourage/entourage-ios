//
//  OTOnboardingPhoneViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTOnboardingPhoneViewController: UIViewController {
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    @IBOutlet weak var ui_label_info: UILabel!
    @IBOutlet weak var ui_tf_phone_prefix: OTCustomTextfield!
    @IBOutlet weak var ui_tf_phone: OTCustomTextfield!
    @IBOutlet weak var ui_pickerView: UIPickerView!
    
    var pickerDataSource: OTCountryCodePickerViewDataSource!
    
    weak var delegate:OnboardV2Delegate? = nil
    var countryCode = "+33"
    var tempPhone = ""
    let minimumCharacters = 9
    var firstname = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerDataSource = OTCountryCodePickerViewDataSource.sharedInstance()
        
        ui_tf_phone.activateToolBarWithTitle(OTLocalisationService.getLocalizedValue(forKey: "close"))
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
        OTLogger.logEvent(View_Onboarding_Phone)
    }
    
    func populateViews() {
        ui_label_title.text =
            String.init(format: OTLocalisationService.getLocalizedValue(forKey: "onboard_phone_title"), firstname)
        ui_label_description.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_phone_sub")
        ui_tf_phone.placeholder = OTLocalisationService.getLocalizedValue(forKey: "onboard_phone_placeholder_phone")
        ui_label_info.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_phone_info")
    }
    
    @IBAction func action_tap(_ sender: Any) {
        ui_tf_phone_prefix.resignFirstResponder()
        ui_tf_phone.resignFirstResponder()
    }
}

//MARK: - UITextfieldDelegate -
extension OTOnboardingPhoneViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        if ui_tf_phone.text?.count ?? 0 >= minimumCharacters  {
            delegate?.updateButtonNext(isValid: true)
            delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber:ui_tf_phone.text)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
            delegate?.validatePhoneNumber(prefix: countryCode, phoneNumber: nil)
        }
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

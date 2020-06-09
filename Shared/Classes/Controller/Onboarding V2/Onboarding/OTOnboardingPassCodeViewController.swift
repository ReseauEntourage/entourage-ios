//
//  OTOnboardingPassCodeViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTOnboardingPassCodeViewController: UIViewController {
    
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    
    @IBOutlet weak var ui_line_6: UIView!
    @IBOutlet weak var ui_line_5: UIView!
    @IBOutlet weak var ui_line_4: UIView!
    @IBOutlet weak var ui_line_3: UIView!
    @IBOutlet weak var ui_line_2: UIView!
    @IBOutlet weak var ui_line_1: UIView!
    @IBOutlet weak var ui_tf_number1: UITextField!
    @IBOutlet weak var ui_tf_number2: UITextField!
    @IBOutlet weak var ui_tf_number3: UITextField!
    @IBOutlet weak var ui_tf_number4: UITextField!
    @IBOutlet weak var ui_tf_number5: UITextField!
    @IBOutlet weak var ui_tf_number6: UITextField!
    @IBOutlet weak var ui_bt_nocode: UIButton!
    
    weak var delegate:OnboardV2Delegate? = nil
    var tempPasscode = ""
    var tempPhone = ""
    
    var timeOut = 60
    var countDownTimer:Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        ui_bt_nocode.setTitle(OTLocalisationService.getLocalizedValue(forKey: "onboard_sms_wait_retry"), for: .normal)
        
        populateViews()
        OTLogger.logEvent(View_Onboarding_Passcode)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        countDownTimer?.invalidate()
        countDownTimer = nil
    }
    
    //MARK: - Methods -
    @objc func updateTimer() {
        timeOut = timeOut - 1
        if timeOut == 0 {
            countDownTimer?.invalidate()
            countDownTimer = nil
        }
    }
    
    func populateViews() {
        ui_label_title.text = OTLocalisationService.getLocalizedValue(forKey: "onboard_sms_title")
        
        let _nb = String(tempPhone.suffix(2))
        let titleTxt = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "onboard_sms_sub"), _nb)
        let fontSize = ui_label_description.font.pointSize
        let _txt = Utilitaires.formatString(stringMessage: titleTxt, coloredTxt: "** ** ** ** \(_nb)", color:UIColor.appBlack30 , colorHighlight: UIColor.appBlack30, fontSize: fontSize, fontWeight: .light, fontColoredWeight: .bold)
        ui_label_description.attributedText = _txt
    }
    
    //MARK: - IBActions -
    @IBAction func action_nocode(_ sender: Any) {
        if timeOut > 0 {
            let alertvc = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "attention_pop_title"), message: String.init(format: OTLocalisationService.getLocalizedValue(forKey: "onboard_sms_pop_alert"), timeOut), preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey:"OK"), style: .default, handler: nil)
            alertvc.addAction(action)
            
            self.navigationController?.present(alertvc, animated: true, completion: nil)
        }
        else {
            delegate?.requestNewcode()
        }
    }
    
    @IBAction func tap_background(_ sender: Any) {
        _ = [ui_tf_number1, ui_tf_number2, ui_tf_number3,
             ui_tf_number4, ui_tf_number5, ui_tf_number6].map() { $0.resignFirstResponder() }
    }
}

//MARK: - UITextfieldDelegate -
extension OTOnboardingPassCodeViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        textField.text = ""
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if range.location == 0 {
            changeTextfield(fromTextField: textField,string:string)
            return true
        }
        return false
    }
    
    func changeTextfield(fromTextField:UITextField,string:String) {
        switch fromTextField {
        case ui_tf_number1:
            ui_tf_number1.text = string
            ui_tf_number2.becomeFirstResponder()
            ui_line_2.backgroundColor = UIColor.appOrange()
        case ui_tf_number2:
            ui_tf_number2.text = string
            ui_tf_number3.becomeFirstResponder()
            ui_line_3.backgroundColor = UIColor.appOrange()
        case ui_tf_number3:
            ui_tf_number3.text = string
            ui_tf_number4.becomeFirstResponder()
            ui_line_4.backgroundColor = UIColor.appOrange()
        case ui_tf_number4:
            ui_tf_number4.text = string
            ui_tf_number5.becomeFirstResponder()
            ui_line_5.backgroundColor = UIColor.appOrange()
        case ui_tf_number5:
            ui_tf_number5.text = string
            ui_tf_number6.becomeFirstResponder()
            ui_line_6.backgroundColor = UIColor.appOrange()
        case ui_tf_number6:
            ui_tf_number6.text = string
            ui_tf_number6.resignFirstResponder()
            
            self.tempPasscode = "\(ui_tf_number1.text!)\(ui_tf_number2.text!)\(ui_tf_number3.text!)\(ui_tf_number4.text!)\(ui_tf_number5.text!)\(ui_tf_number6.text!)"
            
            delegate?.updateButtonNext(isValid: true)
            delegate?.validatePasscode(password: self.tempPasscode)
            
        default:
            break
        }
    }
}

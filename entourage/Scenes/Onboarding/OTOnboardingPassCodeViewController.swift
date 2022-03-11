//
//  OTOnboardingPassCodeViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import MessageUI
import IHProgressHUD

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
    @IBOutlet weak var ui_label_phoneNb: UILabel!
    @IBOutlet weak var ui_label_countdown: UILabel!
    @IBOutlet weak var ui_bt_modify: UIButton!
    @IBOutlet weak var ui_label_help: UILabel!
    
    weak var delegate:OnboardV2Delegate? = nil
    var tempPasscode = ""
    var tempPhone = ""
    
    var timeOut = 60
    var countDownTimer:Timer? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        
        populateViews()
//        OTLogger.logEvent(View_Onboarding_Passcode)//TODO:  Analytics
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
            DispatchQueue.main.async {
                UIView.performWithoutAnimation {
                    self.ui_bt_nocode.setTitle( "onboard_sms_wait_retry_end".localized, for: .normal)
                }
                self.ui_bt_modify.isHidden = false
                self.ui_bt_nocode.isHidden = false
                self.ui_label_countdown.isHidden = true
            }
        }
        else {
            let _time = timeOut < 10 ? "00:0\(timeOut)" : "00:\(timeOut)"
            let _retyTxt = String.init(format:  "onboard_sms_wait_retry".localized , _time)
            DispatchQueue.main.async {
                self.ui_label_countdown.text = _retyTxt
            }
        }
    }
    
    func populateViews() {
         
        self.ui_bt_nocode.isHidden = true
        
        let _retyTxt = String.init(format:  "onboard_sms_wait_retry".localized , "00:\(timeOut)".localized)
        ui_label_countdown.text = _retyTxt
        
        ui_bt_modify.setTitle( "onboard_sms_modify".localized, for: .normal)
        ui_bt_modify.isHidden = true
        
        ui_label_title.text =  "onboard_sms_title".localized
        ui_label_description.text =  "onboard_sms_sub".localized
        ui_label_phoneNb.text = tempPhone
        
        ui_label_help.text =  "onboarding_help_label".localized
    }
    
    //MARK: - IBActions -
    @IBAction func action_nocode(_ sender: Any) {
        if timeOut > 0 {
            let alertvc = UIAlertController.init(title:  "attention_pop_title".localized, message: String.init(format:  "onboard_sms_pop_alert".localized, timeOut), preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
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
    
    @IBAction func action_modify(_ sender: Any) {
        delegate?.goPreviousManually()
    }
    
    @IBAction func action_help(_ sender: Any) {
        if MFMailComposeViewController.canSendMail()  {
            
            let controller = MFMailComposeViewController()
            controller.setMessageBody("", isHTML: true)
            controller.setToRecipients(["contact_email_adress".localized])
            controller.mailComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else {
            IHProgressHUD.showError(withStatus:  "about_email_notavailable".localized)
        }
    }
}

extension OTOnboardingPassCodeViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
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
            ui_line_2.backgroundColor = UIColor.appOrange
        case ui_tf_number2:
            ui_tf_number2.text = string
            ui_tf_number3.becomeFirstResponder()
            ui_line_3.backgroundColor = UIColor.appOrange
        case ui_tf_number3:
            ui_tf_number3.text = string
            ui_tf_number4.becomeFirstResponder()
            ui_line_4.backgroundColor = UIColor.appOrange
        case ui_tf_number4:
            ui_tf_number4.text = string
            ui_tf_number5.becomeFirstResponder()
            ui_line_5.backgroundColor = UIColor.appOrange
        case ui_tf_number5:
            ui_tf_number5.text = string
            ui_tf_number6.becomeFirstResponder()
            ui_line_6.backgroundColor = UIColor.appOrange
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

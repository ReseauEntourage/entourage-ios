//
//  OnboardingPhase2ViewController.swift
//  entourage
//
//  Created by You on 30/11/2022.
//

import UIKit
import MessageUI
import IHProgressHUD

class OnboardingPhase2ViewController: UIViewController {

    @IBOutlet weak var ui_label_description: UILabel!
    
    @IBOutlet weak var ui_tf_code: OTCustomTextfield!
    @IBOutlet weak var ui_bt_nocode: UIButton!
    @IBOutlet weak var ui_label_phoneNb: UILabel!
    @IBOutlet weak var ui_label_countdown: UILabel!
    @IBOutlet weak var ui_bt_modify: UIButton!
    @IBOutlet weak var ui_label_help: UILabel!
    
    @IBOutlet weak var ui_view_bt_help: UIView!
    
    var tempCode:String? = nil
    var tempPhone = ""
    let timeoutInfo = 60
    var timeOut = 60
    var countDownTimer:Timer? = nil
    
    weak var pageDelegate:OnboardingDelegate? = nil
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_tf_code.activateToolBarWithTitle( "close".localized)
        ui_tf_code.delegate = self
        ui_tf_code.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 13))
        
        ui_label_description.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15))
        ui_label_phoneNb.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 15))
        ui_bt_modify.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15,color: .appOrangeLight))
        
        ui_bt_nocode.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 14,color: .appOrange))
        ui_label_countdown.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 14,color: .appGris112))

        
        ui_bt_nocode.layer.cornerRadius = ui_bt_nocode.frame.height / 2
        ui_bt_nocode.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_nocode.layer.borderWidth = 1
        
        timeOut = timeoutInfo
        countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if timeOut == 0 || !((countDownTimer?.isValid) != nil)  {
            timeOut = timeOut == 0 ? timeoutInfo : timeOut
            self.ui_label_countdown.isHidden = false
            countDownTimer?.invalidate()
            countDownTimer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        }
        
        populateViews()
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
        
        let _time = timeOut < 10 ? "00:0\(timeOut)" : "00:\(timeOut)"
        let _retyTxt = String.init(format:  "onboard_sms_wait_retry".localized , "00:\(_time)".localized)
        ui_label_countdown.text = _retyTxt
        
        ui_bt_modify.setTitle( "onboard_sms_modify".localized, for: .normal)
        ui_bt_modify.isHidden = true
        
        ui_label_description.text =  "onboard_sms_sub".localized
        ui_label_phoneNb.text = tempPhone
        
        ui_label_help.attributedText = Utils.formatStringUnderline(textString: "onboarding_help_label".localized, textColor: .appOrange, font: ApplicationTheme.getFontNunitoRegular(size: 14))
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
            pageDelegate?.requestNewcode()
        }
    }
    
    @IBAction func tap_background(_ sender: Any) {
        ui_tf_code.resignFirstResponder()
    }
    
    @IBAction func action_modify(_ sender: Any) {
        pageDelegate?.goMain()
    }
    
    @IBAction func action_help(_ sender: Any) {
        if MFMailComposeViewController.canSendMail()  {
            
            let controller = MFMailComposeViewController()
            controller.setMessageBody("", isHTML: true)
            controller.setToRecipients([emailContact])
            controller.mailComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }
        else {
            IHProgressHUD.showError(withStatus:  "about_email_notavailable".localized)
        }
    }

}


extension OnboardingPhase2ViewController: MFMailComposeViewControllerDelegate {
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        self.dismiss(animated: true, completion: nil)
    }
}

//MARK: - UITextfieldDelegate -
extension OnboardingPhase2ViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.tempCode = textField.text
        
        pageDelegate?.sendCode(code: self.tempCode ?? "")
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        pageDelegate?.sendCode(code: self.tempCode ?? "")
        textField.resignFirstResponder()
        return true
    }
}

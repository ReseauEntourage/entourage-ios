//
//  OTOnboardingAssoFillViewController.swift
//  entourage
//
//  Created by Jr on 25/05/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTOnboardingAssoFillViewController: UIViewController {

    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_label_description: UILabel!
    
    @IBOutlet weak var ui_label_asso_name: UILabel!
    @IBOutlet weak var ui_tf_asso_cp: OTCustomTextfield!
    @IBOutlet weak var ui_tf_function: OTCustomTextfield!
    
    var asso:Partner? = nil
    weak var delegate:OnboardV2Delegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()

       ui_label_title.text =  "onboard_asso_fill_title".localized
        ui_label_description.text =  "onboard_asso_fill_description".localized
        
        ui_tf_asso_cp.placeholder =  "onboard_asso_fill_cp_placeholder".localized
        ui_tf_function.placeholder =  "onboard_asso_fill_function_placeholder".localized
        
        updateDelegateButtonNext()
        
        updateAssoNameLabel()
        ui_tf_asso_cp.text = asso?.postalCode != nil ? asso!.postalCode! : ""
        ui_tf_function.text = asso?.userRoleTitle != nil ? asso!.userRoleTitle! : ""
        
//        OTLogger.logEvent(View_Onboarding_Pro_SignUp)//TODO:  Analytics
    }
    
    func updateDelegateButtonNext() {
        if let name = asso?.name, name.count > 0 {
            delegate?.updateButtonNext(isValid: true)
        }
        else {
            delegate?.updateButtonNext(isValid: false)
        }
    }
    
    func updateAssoInfo() {
        updateAssoNameLabel()
        ui_tf_asso_cp.text = asso?.postalCode != nil ? asso!.postalCode! : ""
        
        updateDelegateButtonNext()
        
        if let _asso = asso {
            delegate?.updateAssoInfos(asso: _asso)
        }
        else {
            delegate?.updateAssoInfos(asso: Partner())
        }
    }
    
    func updateAssoNameLabel() {
        if let name = asso?.name {
            ui_label_asso_name.text = name
            ui_label_asso_name.textColor = .appBlack30
        }
        else {
            ui_label_asso_name.text =  "onboard_asso_fill_name_placeholder".localized
            ui_label_asso_name.textColor = .lightGray
        }
    }
    
    @IBAction func action_choose_asso(_ sender: Any) {
        
        if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_asso_search") as? OTOnboardingSearchAssoViewController {
            vc.delegate = self
            self.present(vc, animated: true, completion: nil)
        }
    }
    
    @IBAction func action_tap_view(_ sender: Any) {
        ui_tf_function.resignFirstResponder()
        ui_tf_asso_cp.resignFirstResponder()
    }
}

//MARK: - UITextFieldDelegate -
extension OTOnboardingAssoFillViewController: UITextFieldDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
        
        if textField == ui_tf_asso_cp {
            if asso == nil {
                asso = Partner()
            }
             asso?.postalCode = textField.text!
        }
        
        if textField == ui_tf_function {
            if asso == nil {
                asso = Partner()
            }
            asso?.userRoleTitle = textField.text!
        }
        
        updateDelegateButtonNext()
        
        delegate?.updateAssoInfos(asso: asso!)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == ui_tf_asso_cp {
            ui_tf_function.becomeFirstResponder()
        }
        else {
            textField.resignFirstResponder()
        }
        return true
    }
}

//MARK: - ValidateAssoDelegate -
extension OTOnboardingAssoFillViewController:ValidateAssoDelegate {    
    func validate(asso:Partner) {
        if let _ = self.asso {
            self.asso?.name = asso.name
            self.asso?.postalCode = asso.postalCode
            self.asso?.aid = asso.aid
            self.asso?.isCreation = asso.isCreation
        }
        else {
            self.asso = asso
        }
        Logger.print("***** Asso select : \(asso)")
        if let _functionTxt = ui_tf_function.text, _functionTxt.count > 0 {
            self.asso?.userRoleTitle = _functionTxt
        }
        
        updateAssoInfo()
    }
}

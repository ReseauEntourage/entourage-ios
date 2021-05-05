//
//  OTHomeNeoTourSendViewController.swift
//  entourage
//
//  Created by Jr on 13/04/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTHomeNeoTourSendViewController: UIViewController {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    
    @IBOutlet weak var ui_view_button_next: UIView!
    @IBOutlet weak var ui_button_title: UILabel!
    
    @IBOutlet weak var ui_label_email: UILabel!
    @IBOutlet weak var ui_view_email: UIView!
    @IBOutlet weak var ui_tf_email: OTCustomTextfield!
    
    @IBOutlet weak var ui_view_ok: UIView!
    @IBOutlet weak var ui_tv_ok: UILabel!
    
    var area = OTHomeTourArea()
    var hasEmail = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_view_button_next.layer.cornerRadius = 4
        
        self.title = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_send_top_title")
        ui_title.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_send_title"), area.areaName)
        ui_description.text = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_send_description"), area.areaName)
        ui_button_title.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_send_button")?.uppercased()
        
        ui_tv_ok.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_send_ok")
        
        ui_view_ok.isHidden = true
        //email
        if let user = UserDefaults.standard.currentUser, user.email.count > 0 {
            ui_view_email.isHidden = true
            hasEmail = true
        }
        else {
            hasEmail = false
            ui_view_email.isHidden = false
            
            ui_label_email.text = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_send_email")
            ui_tf_email.placeholder = OTLocalisationService.getLocalizedValue(forKey: "home_neo_tour_send_email_placeholder")
        }
        
        ui_tf_email.delegate = self
    }
    
    func sendEmailUpdate(email:String) {
        if let user = UserDefaults.standard.currentUser {
            SVProgressHUD.show()
            user.email = email
            OTAuthService.init().updateUserInformation(with: user) { (newUser) in
                SVProgressHUD.dismiss()
                newUser?.phone = user.phone
                UserDefaults.standard.currentUser = newUser
                self.ui_view_email.isHidden = true
                
                self.sendTourAnswer()
            } failure: { (error) in
                SVProgressHUD.dismiss()
            }
        }
    }
    
    func sendTourAnswer() {
        SVProgressHUD.show()
        
        let _analytic = String.init(format: Action_NeoFeedFirst_Send_TourCity, area.postalCode)
        OTLogger.logEvent(_analytic)
        
        OTHomeNeoService.sendAnswer(withId: area.areaId) { (error) in
            SVProgressHUD.dismiss()
            if error == nil {
                self.ui_view_ok.isHidden = false
                self.ui_view_button_next.isHidden = true
            }
        }
    }
    
    @IBAction func action_send(_ sender: Any) {
        if hasEmail {
            sendTourAnswer()
        }
        else {
            if let _email = ui_tf_email.text, _email.isValidEmail {
                sendEmailUpdate(email: _email)
            }
            else {
                let alertVC = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "attention_pop_title"), message: OTLocalisationService.getLocalizedValue(forKey: "needValidEmail"), preferredStyle: .alert)
                let actionOk = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "ok"), style: .default) { (action) in
                    alertVC.dismiss(animated: true, completion: nil)
                }
                
                alertVC.addAction(actionOk)
                self.navigationController?.present(alertVC, animated: true, completion: nil)
            }
        }
    }
    
    @IBAction func action_tap_view(_ sender: Any) {
        ui_tf_email.resignFirstResponder()
    }
}

extension OTHomeNeoTourSendViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

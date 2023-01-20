//
//  OnboardingPhase1ViewController.swift
//  entourage
//
//  Created by You on 30/11/2022.
//

import UIKit
import IQKeyboardManagerSwift

class OnboardingPhase1ViewController: UIViewController {

    weak var pageDelegate:OnboardingDelegate? = nil
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    
    var userFirstname:String? = nil
    var userLastname:String? = nil
    
    var countryCode:CountryCode = defaultCountryCode
    var phone:String? = nil
    var email:String? = nil
    var hasConsent = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }
    
    deinit {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    func updateValidate() {
        pageDelegate?.addUserInfos(firstname: userFirstname, lastname: userLastname,countryCode:countryCode, phone: phone, email: email, consentEmail: hasConsent)
    }

}

extension OnboardingPhase1ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OnboardingStartCell
        
        cell.populateCell(username: userFirstname, lastname: userLastname, countryCode: countryCode , phone: phone, email:email, isCheck: hasConsent, delegate: self)
        
        return cell
        
    }
}


extension OnboardingPhase1ViewController: OnboardingStartDelegate {
    func validateFirstLastname(firstName: String?, lastname: String?) {
        self.userFirstname = firstName
        self.userLastname = lastname
        updateValidate()
    }
    
    func validatePhoneNumber(prefix: CountryCode, phoneNumber: String?) {
        self.phone = phoneNumber
        self.countryCode = prefix
        updateValidate()
    }
    
    func validateEmail(email:String?) {
        self.email = email
        updateValidate()
    }
    
    func validateConsent(isChecked:Bool) {
        self.hasConsent = isChecked
        updateValidate()
    }
}

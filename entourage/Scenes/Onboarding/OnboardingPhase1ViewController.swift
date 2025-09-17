//
//  OnboardingPhase1ViewController.swift
//  entourage
//
//  Created by You on 30/11/2022.
//

import UIKit
import IQKeyboardManagerSwift

class OnboardingPhase1ViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var ui_tableview: UITableView!

    // MARK: - Properties
    weak var pageDelegate: OnboardingDelegate? = nil

    var userFirstname: String? = nil
    var userLastname: String? = nil
    var countryCode: CountryCode = defaultCountryCode
    var phone: String? = nil
    var email: String? = nil
    var hasConsent: Bool = false

    // Nouveaux champs
    var gender: String?
    var howWeMet: String?
    var company: String?
    var event: String?

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupKeyboardManager()
        setupTableView()
    }

    deinit {
        IQKeyboardManager.shared.enable = false
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    // MARK: - Setup
    private func setupKeyboardManager() {
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.enableAutoToolbar = false
    }

    private func setupTableView() {
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        ui_tableview.rowHeight = UITableView.automaticDimension
        ui_tableview.estimatedRowHeight = 600
        ui_tableview.reloadData()
    }

    // MARK: - Validation
    func updateValidate() {
        pageDelegate?.addUserInfos(
            firstname: userFirstname,
            lastname: userLastname,
            countryCode: countryCode,
            phone: phone,
            email: email,
            consentEmail: hasConsent,
            gender: gender,
            howWeMet: howWeMet,
            company: company,
            event: event
        )
    }
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension OnboardingPhase1ViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! OnboardingStartCell
        cell.populateCell(
            username: userFirstname,
            lastname: userLastname,
            countryCode: countryCode,
            phone: phone,
            email: email,
            isCheck: hasConsent,
            delegate: self
        )
        return cell
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
}

// MARK: - OnboardingStartDelegate
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

    func validateEmail(email: String?) {
        self.email = email
        updateValidate()
    }

    func validateConsent(isChecked: Bool) {
        self.hasConsent = isChecked
        updateValidate()
    }

    func validateGender(gender: String?) {
        self.gender = gender
        updateValidate()
    }

    func validateHowWeMet(howWeMet: String?) {
        self.howWeMet = howWeMet
        updateValidate()
    }

    func validateCompany(company: String?) {
        self.company = company
        updateValidate()
    }

    func validateEvent(event: String?) {
        self.event = event
        updateValidate()
    }
}

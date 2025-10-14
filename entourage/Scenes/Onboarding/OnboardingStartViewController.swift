//
//  OnboardingStartViewController.swift
//  entourage
//

import UIKit
import IHProgressHUD
import CoreLocation
import GooglePlaces

final class OnboardingStartViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var ui_page_control: MJCustomPageControl!
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_main_container_view: UIView!
    @IBOutlet weak var ui_container_view: UIView!
    @IBOutlet weak var ui_bt_previous: UIButton!
    @IBOutlet weak var ui_bt_next: UIButton!
    @IBOutlet weak var ui_top_view: MJNavBackView!

    // MARK: - Properties
    weak var parentDelegate: OTPreOnboardingV2ChoiceViewController? = nil
    var pageViewController: OnboardingPageViewController? = nil
    var currentPhasePosition = 1
    var shouldLaunchThird = false

    let minimumCharacters = 2
    let minimumPhoneCharacters = 9

    var temporaryUser: User = User()
    var temporaryPasscode: String? = nil
    var countryCode: CountryCode = defaultCountryCode
    var phone: String? = nil
    var email: String? = nil
    var hasConsent = false

    // New fields
    var gender: String?
    var howWeMet: String?
    var company: String?
    var event: String?

    var userTypeSelected = UserType.none
    var temporaryGooglePlace: GMSPlace? = nil
    var temporaryLocation: CLLocationCoordinate2D? = nil
    var temporaryAddressName: String? = nil
    var isLocOk = false
    var isTypeOk = false

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()

        ui_bt_previous.isHidden = true
        ui_page_control.numberOfPages = 3
        ui_page_control.currentPage = 0

        ui_bt_previous.layer.cornerRadius = ui_bt_previous.frame.height / 2
        ui_bt_previous.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_previous.layer.borderWidth = 1
        ui_bt_previous.backgroundColor = .clear
        ui_bt_previous.setTitleColor(.appOrange, for: .normal)
        ui_bt_previous.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 18)
        ui_bt_previous.setTitle("onboard_bt_back".localized, for: .normal)
        configureWhiteButton(ui_bt_previous, withTitle: "onboard_bt_back".localized)

        ui_bt_next.layer.cornerRadius = ui_bt_next.frame.height / 2
        ui_bt_next.backgroundColor = .appOrangeLight
        ui_bt_next.setTitleColor(.white, for: .normal)
        ui_bt_next.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_bt_next.setTitle("onboard_bt_next".localized, for: .normal)
        configureOrangeButton(ui_bt_next, withTitle: "onboard_bt_next".localized)
        enableDisableNextButton(isEnable: false)

        ui_main_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        self.modalPresentationStyle = .fullScreen

        ui_top_view.populateCustom(
            title: "onboard_welcome_title".localized,
            titleFont: ApplicationTheme.getFontQuickSandBold(size: 24),
            titleColor: .white,
            imageName: "back_button_white",
            backgroundColor: .clear,
            delegate: self,
            showSeparator: false
        )

        // Pilotage du bouton par la VM de la phase 1 uniquement
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handlePhase1CanProceed(_:)),
            name: .onboardingPhase1CanProceedChanged,
            object: nil
        )

        if shouldLaunchThird {
            updateViewsForPosition()
            ui_page_control.isHidden = true
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .onboardingPhase1CanProceedChanged, object: nil)
    }

    override func viewWillLayoutSubviews() {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OnboardingPageViewController {
            self.pageViewController = vc
            self.pageViewController?.parentDelegate = self
        }
    }

    // MARK: - Observer
    @objc private func handlePhase1CanProceed(_ notif: Notification) {
        guard currentPhasePosition == 1 else { return }
        let enabled = (notif.userInfo?["enabled"] as? Bool) ?? false
        enableDisableNextButton(isEnable: enabled)
    }

    // MARK: - UI Configuration
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    func configureWhiteButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = .white
        button.setTitleColor(.black, for: .normal)
        button.layer.borderColor = UIColor.appOrange.cgColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 21
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }

    func countValidate() {
        enableDisableNextButton(isEnable: isLocOk && isTypeOk)
    }

    func showError(message: String) {
        ui_error_view.changeTitleAndImage(title: message)
        ui_error_view.show()
    }

    func showPopAlreadySigned() {
        let alertVC = UIAlertController(title: nil, message: "alreadyRegistereMessageGoBack".localized, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK".localized, style: .default) { [weak self] _ in
            self?.parentDelegate?.isFromOnboarding = true
            self?.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(action)
        self.navigationController?.present(alertVC, animated: true, completion: nil)
    }

    // MARK: - Navigation
    @IBAction func action_next(_ sender: Any) {
        // Étape 2 : forcer la présence du code avant de lancer la requête
        if currentPhasePosition == 2 {
            guard let code = temporaryPasscode, !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                let alertVC = UIAlertController(title: nil, message: "Merci de renseigner le code reçu par SMS.", preferredStyle: .alert)
                alertVC.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(alertVC, animated: true, completion: nil)
                return
            }
            createUser()      // l’étape suivante est déclenchée au succès réseau
            return            // ne pas rafraîchir l’UI ici
        }

        // Étapes 1 et 3 : logique existante
        let isValid = checkValidation()
        if isValid.isValid {
            goPageNext()
        } else {
            showError(message: isValid.message)
        }
    }

    @IBAction func action_back(_ sender: Any) {
        goPageBack()
    }

    func goPageNext() {
        if currentPhasePosition == 1 {
            sendPhone()
        } else if currentPhasePosition == 2 {
            // géré dans action_next (pour l’alerte code manquant)
            return
        } else if currentPhasePosition == 3 {
            updateUser()
            return
        }
        updateViewsForPosition()
    }

    func goNextStep() {
        currentPhasePosition += 1
        updateViewsForPosition()
    }

    func goPageBack() {
        currentPhasePosition = max(1, currentPhasePosition - 1)
        updateViewsForPosition()
    }

    private func updateViewsForPosition() {
        pageViewController?.goPagePosition(position: currentPhasePosition)
        ui_page_control.currentPage = currentPhasePosition - 1
        ui_top_view.hideButtonBackForUnboarding(hide: false)
        ui_bt_next.setTitle("onboard_bt_next".localized, for: .normal)

        switch currentPhasePosition {
        case 1:
            ui_top_view.updateTitle(title: "onboard_welcome_title".localized)
            ui_bt_previous.isHidden = true
            ui_bt_next.isHidden = false
            // Le bouton sera piloté live par la notif de la phase 1

        case 2:
            ui_top_view.updateTitle(title: "onboard_sms_title".localized)
            ui_bt_previous.isHidden = false
            ui_bt_next.isHidden = false
            pageViewController?.createPhase2VC?.tempPhone = phone ?? "-"
            // À l’étape 2, on laisse le bouton actif (le serveur valide le code)
            enableDisableNextButton(isEnable: true)

        case 3:
            let _title = String(format: "onboard_phone_title".localized, temporaryUser.firstname)
            ui_top_view.updateTitle(title: _title)
            ui_top_view.hideButtonBackForUnboarding(hide: true)
            ui_bt_previous.isHidden = true
            ui_bt_next.isHidden = false
            ui_bt_next.setTitle("onboard_bt_create".localized, for: .normal)
            if shouldLaunchThird { ui_bt_next.setTitle("onboard_bt_next".localized, for: .normal) }
            _ = checkValidation()

        default:
            break
        }
    }

    func enableDisableNextButton(isEnable: Bool) {
        ui_bt_next.isEnabled = isEnable
        ui_bt_next.backgroundColor = isEnable ? .appOrange : .appOrangeLight
    }

    func checkValidation() -> (isValid: Bool, message: String) {
        var isValid = true
        var message = ""

        if currentPhasePosition == 1 {
            if temporaryUser.firstname.count < minimumCharacters {
                isValid = false; message = "onboard_error_general".localized
            } else if temporaryUser.lastname.count < minimumCharacters {
                isValid = false; message = "onboard_error_general".localized
            } else if (phone?.count ?? 0) < minimumPhoneCharacters {
                isValid = false; message = "onboard_error_general".localized
            } else if let mail = email, !mail.isEmpty, !mail.isValidEmail {
                isValid = false; message = "onboard_error_general".localized
            }
            enableDisableNextButton(isEnable: isValid)
            return (isValid, message)
        }

        if currentPhasePosition == 3 {
            if userTypeSelected == .none {
                isValid = false; message = "onboard_error_general".localized
            } else if temporaryLocation == nil && temporaryGooglePlace == nil {
                isValid = false; message = "onboard_error_general".localized
            }
        }

        enableDisableNextButton(isEnable: isValid)
        return (isValid, message)
    }

    // MARK: - Network
    func sendPhone() {
        IHProgressHUD.show()
        AuthService.createAccountWith(user: self.temporaryUser) { [weak self] phone, error in
            IHProgressHUD.dismiss()
            if let error = error {
                var showErrorHud = true
                if error.code == "INVALID_PHONE_FORMAT" {
                    let alertVC = UIAlertController(title: nil, message: "invalidPhoneNumberFormat".localized, preferredStyle: .alert)
                    alertVC.addAction(UIAlertAction(title: "close".localized, style: .default, handler: nil))
                    self?.navigationController?.present(alertVC, animated: true, completion: nil)
                    showErrorHud = false
                } else if error.code == "PHONE_ALREADY_EXIST" {
                    self?.showPopAlreadySigned()
                    return
                }
                if error.message.count > 0 {
                    if showErrorHud { IHProgressHUD.showError(withStatus: error.message) }
                } else {
                    IHProgressHUD.showError(withStatus: "alreadyRegisteredMessage".localized)
                }
            } else {
                var newUser = User()
                newUser.phone = phone
                UserDefaults.temporaryUser = newUser
                self?.goNextStep()
            }
        }
    }

    func createUser() {
        guard let tempPwd = temporaryPasscode, !tempPwd.isEmpty else { return }
        IHProgressHUD.show()
        AuthService.postLogin(phone: self.temporaryUser.phone!, password: tempPwd) { [weak self] user, error, isFirstLogin in
            IHProgressHUD.dismiss()
            if error != nil {
                let alertvc = UIAlertController(title: "tryAgain".localized, message: "invalidPhoneNumberOrCode".localized, preferredStyle: .alert)
                alertvc.addAction(UIAlertAction(title: "tryAgain_short".localized, style: .default, handler: nil))
                self?.navigationController?.present(alertvc, animated: true, completion: nil)
            } else if let user = user {
                var newUser = user
                newUser.phone = self?.temporaryUser.phone
                self?.temporaryUser.firstname = user.firstname
                self?.temporaryUser.lastname = user.lastname
                UserDefaults.currentUser = newUser
                UserDefaults.temporaryUser = nil
                self?.goNextStep()
            }
        }
    }

    func resendCode() {
        IHProgressHUD.show()
        AuthService.regenerateSecretCode(phone: self.temporaryUser.phone!) { [weak self] error in
            IHProgressHUD.dismiss()
            if error != nil {
                let alertvc = UIAlertController(title: "error".localized, message: "requestNotSent".localized, preferredStyle: .alert)
                alertvc.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: nil))
                self?.navigationController?.present(alertvc, animated: true, completion: nil)
            }
        }
    }

    func updateUser() {
        IHProgressHUD.show()
        var _currentUser = UserDefaults.currentUser
        _currentUser?.goal = userTypeSelected.getGoalString()
        if let email = email { _currentUser?.email = email }
        _currentUser?.hasConsent = hasConsent
        _currentUser?.gender = gender
        _currentUser?.discoverySource = howWeMet
        if howWeMet == "Sensibilisation entreprise" {
            _currentUser?.company = company
            _currentUser?.event = self.event
        }

        UserService.updateUser(user: _currentUser) { [weak self] user, _ in
            IHProgressHUD.dismiss()
            if let user = user {
                var newUser = user
                newUser.phone = _currentUser?.phone
                UserDefaults.currentUser = newUser
            }
            self?.updateAddress()
        }
    }

    func updateAddress() {
        if let _place = temporaryGooglePlace, let placeId = _place.placeID {
            IHProgressHUD.show()
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { [weak self] _ in
                IHProgressHUD.dismiss()
                self?.goEnd()
            }
        } else if let _lat = self.temporaryLocation?.latitude, let _long = self.temporaryLocation?.longitude {
            IHProgressHUD.show()
            let addressName = temporaryAddressName == nil ? "default" : temporaryAddressName!
            UserService.updateUserAddressWith(name: addressName, latitude: _lat, longitude: _long, isSecondaryAddress: false) { [weak self] _ in
                IHProgressHUD.dismiss()
                self?.goEnd()
            }
        }
    }

    func goEnd() {
        UserDefaults.standard.set(userTypeSelected.rawValue, forKey: "userType")
        UserDefaults.standard.set(true, forKey: "isFromOnboarding")
        UserDefaults.standard.set(false, forKey: "checkAfterLogin")

        let sb = UIStoryboard(name: StoryboardName.onboarding, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OnboardingEndViewController") as! OnboardingEndViewController
        if shouldLaunchThird {
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = vc
                window.makeKeyAndVisible()
            }
        } else {
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - OnboardingDelegate
extension OnboardingStartViewController: OnboardingDelegate {
    func addUserInfos(firstname: String?, lastname: String?, countryCode: CountryCode, phone: String?, email: String?, consentEmail: Bool, gender: String?, howWeMet: String?, company: String?, event: String?) {
        temporaryUser.firstname = firstname ?? ""
        temporaryUser.lastname = lastname ?? ""
        temporaryUser.phone = Utils.validatePhoneFormat(countryCode: countryCode.code, phone: phone ?? "")
        self.phone = phone
        self.countryCode = countryCode
        self.email = email
        self.hasConsent = consentEmail
        self.gender = gender
        self.howWeMet = howWeMet
        self.company = company
        self.event = event

        // Phases 2/3: on conserve la logique locale
        let validate = checkValidation()
        enableDisableNextButton(isEnable: validate.isValid)
    }

    func sendCode(code: String) {
        self.temporaryPasscode = code
        // À l’étape 2 le bouton reste actif, pas d’update ici
    }

    func addInfos(userType: UserType) {
        self.userTypeSelected = userType
        let result = checkValidation()
        enableDisableNextButton(isEnable: result.isValid)
    }

    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        self.temporaryGooglePlace = googlePlace
        self.temporaryLocation = currentlocation
        self.temporaryAddressName = currentLocationName
        let result = checkValidation()
        enableDisableNextButton(isEnable: result.isValid)
    }

    func goMain() { self.goPageBack() }
    func requestNewcode() { self.resendCode() }
}

// MARK: - MJNavBackViewDelegate
extension OnboardingStartViewController: MJNavBackViewDelegate {
    func goBack() { self.navigationController?.popViewController(animated: true) }
    func didTapEvent() { }
}

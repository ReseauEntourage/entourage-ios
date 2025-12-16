//
//  OnboardingStartViewController.swift
//  entourage
//

import UIKit
import SVProgressHUD
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

        // Suite aux retours utilisateurs, on masque définitivement l’indicateur de pages
        // (les « trois points » au bas de l’écran). Cela permet aussi de réduire
        // visuellement la hauteur du footer.
        ui_page_control.isHidden = true

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

        // Phase 1 pilotée par la VM
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
        NotificationCenter.default.removeObserver(
            self,
            name: .onboardingPhase1CanProceedChanged,
            object: nil
        )
    }

    override func viewWillLayoutSubviews() {
        self.navigationController?.isNavigationBarHidden = true
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? OnboardingPageViewController {
            self.pageViewController = vc
            self.pageViewController?.parentDelegate = self
        }
        DispatchQueue.main.async { [weak self] in
            self?.updateViewsForPosition()
        }
    }

    // MARK: - Observer

    @objc private func handlePhase1CanProceed(_ notif: Notification) {
        guard currentPhasePosition == 1 else { return }
        let enabled = (notif.userInfo?["enabled"] as? Bool) ?? false
        // Phase 1 : bouton uniquement piloté par la VM
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
        // Pilotage interne (hors phase 1)
        if currentPhasePosition != 1 {
            enableDisableNextButton(isEnable: isLocOk && isTypeOk)
        }
    }

    func showError(message: String) {
        ui_error_view.changeTitleAndImage(title: message)
        ui_error_view.show()
    }

    func showPopAlreadySigned() {
        let alertVC = UIAlertController(
            title: nil,
            message: "alreadyRegistereMessageGoBack".localized,
            preferredStyle: .alert
        )
        let action = UIAlertAction(title: "OK".localized, style: .default) { [weak self] _ in
            self?.parentDelegate?.isFromOnboarding = true
            self?.navigationController?.popViewController(animated: true)
        }
        alertVC.addAction(action)
        self.navigationController?.present(alertVC, animated: true, completion: nil)
    }

    // MARK: - Navigation actions

    @IBAction func action_next(_ sender: Any) {
        // Étape 2 : forcer la présence du code avant de lancer la requête
        if currentPhasePosition == 2 {
            // Étape 2 : on exige la saisie d'un code avant de procéder
            guard let code = temporaryPasscode,
                  !code.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                // On affiche une alerte localisable lorsque le code est manquant
                let alertVC = UIAlertController(
                    title: nil,
                    message: "onboard_sms_missing_code_message".localized,
                    preferredStyle: .alert
                )
                alertVC.addAction(
                    UIAlertAction(
                        title: "OK".localized,
                        style: .default,
                        handler: nil
                    )
                )
                self.present(alertVC, animated: true, completion: nil)
                return
            }
            // On envoie la requête de création de compte ; la suite est gérée en callback réseau
            createUser()
            return
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

    // MARK: - Navigation interne (phases)

    func goPageNext() {
        if currentPhasePosition == 1 {
            sendPhone()
        } else if currentPhasePosition == 2 {
            // géré dans action_next (pour l’alerte code manquant)
            return
        } else if currentPhasePosition == 3 {
            // ⬇️ Nouveau : d’abord maj user, puis on ouvre la vue ZoneChoice
            updateUser { [weak self] in
                self?.presentZoneChoice()
            }
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
            // ⚠️ Le bouton est piloté UNIQUEMENT par la notif de la VM en phase 1

        case 2:
            ui_top_view.updateTitle(title: "onboard_sms_title".localized)
            // À l’étape 2 (validation du code SMS), le bouton « Précédent »
            // est masqué conformément aux retours PO. L’utilisateur n’a pas
            // besoin de revenir sur l’écran précédent depuis cette étape.
            ui_bt_previous.isHidden = true
            ui_bt_next.isHidden = false
            pageViewController?.createPhase2VC?.tempPhone = phone ?? "-"
            // À l’étape 2, on laisse le bouton actif (le serveur valide le code)
            enableDisableNextButton(isEnable: true)

        case 3:
            let _title = String(
                format: "onboard_phone_title".localized,
                temporaryUser.firstname
            )
            ui_top_view.updateTitle(title: _title)
            ui_top_view.hideButtonBackForUnboarding(hide: true)
            ui_bt_previous.isHidden = true
            ui_bt_next.isHidden = false
            ui_bt_next.setTitle("onboard_bt_next".localized, for: .normal)

            // localisation retirée de la validation : seul le type est requis
            let v = checkValidation()
            enableDisableNextButton(isEnable: v.isValid)

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

            // ⚠️ Ne PAS piloter le bouton ici : la VM gère via NotificationCenter en phase 1.
            return (isValid, message)
        }

        if currentPhasePosition == 3 {
            // localisation SUPPRIMÉE de la validation
            // → désactiver le CTA si aucun type n’est sélectionné
            if userTypeSelected == .none {
                isValid = false
                message = "onboard_error_general".localized
            }
        }

        // Phases ≠ 1 : on peut piloter localement le CTA
        if currentPhasePosition != 1 {
            enableDisableNextButton(isEnable: isValid)
        }

        return (isValid, message)
    }

    // MARK: - Network

    func sendPhone() {
        SVProgressHUD.show()
        AuthService.createAccountWith(user: self.temporaryUser) { [weak self] phone, error in
            SVProgressHUD.dismiss()
            if let error = error {
                var showErrorHud = true
                if error.code == "INVALID_PHONE_FORMAT" {
                    let alertVC = UIAlertController(
                        title: nil,
                        message: "invalidPhoneNumberFormat".localized,
                        preferredStyle: .alert
                    )
                    alertVC.addAction(
                        UIAlertAction(
                            title: "close".localized,
                            style: .default,
                            handler: nil
                        )
                    )
                    self?.navigationController?.present(alertVC, animated: true, completion: nil)
                    showErrorHud = false
                } else if error.code == "PHONE_ALREADY_EXIST" {
                    self?.showPopAlreadySigned()
                    return
                }
                if error.message.count > 0 {
                    if showErrorHud {SVProgressHUD.show(withStatus: error.message) }
                } else {
                   SVProgressHUD.show(withStatus: "alreadyRegisteredMessage".localized)
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
        SVProgressHUD.show()
        AuthService.postLogin(
            phone: self.temporaryUser.phone!,
            password: tempPwd
        ) { [weak self] user, error, isFirstLogin in
            SVProgressHUD.dismiss()
            if error != nil {
                let alertvc = UIAlertController(
                    title: "tryAgain".localized,
                    message: "invalidPhoneNumberOrCode".localized,
                    preferredStyle: .alert
                )
                alertvc.addAction(
                    UIAlertAction(
                        title: "tryAgain_short".localized,
                        style: .default,
                        handler: nil
                    )
                )
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
        SVProgressHUD.show()
        AuthService.regenerateSecretCode(phone: self.temporaryUser.phone!) { [weak self] error in
            SVProgressHUD.dismiss()
            if error != nil {
                let alertvc = UIAlertController(
                    title: "error".localized,
                    message: "requestNotSent".localized,
                    preferredStyle: .alert
                )
                alertvc.addAction(
                    UIAlertAction(
                        title: "OK".localized,
                        style: .default,
                        handler: nil
                    )
                )
                self?.navigationController?.present(alertvc, animated: true, completion: nil)
            }
        }
    }

    /// Met à jour l'utilisateur côté API, puis exécute la completion (ZoneChoice).
    func updateUser(completion: (() -> Void)? = nil) {
        SVProgressHUD.show()
        var _currentUser = UserDefaults.currentUser
        _currentUser?.goal = userTypeSelected.getGoalString()
        if let email = email { _currentUser?.email = email }
        _currentUser?.hasConsent = hasConsent
        _currentUser?.gender = gender
        _currentUser?.discoverySource = howWeMet

        // Renseigne entreprise/évènement si fournis
        if let company = company, !company.isEmpty { _currentUser?.company = company }
        if let event = self.event, !event.isEmpty { _currentUser?.event = event }

        UserService.updateUser(user: _currentUser) { [weak self] user, _ in
            SVProgressHUD.dismiss()
            if let user = user {
                var newUser = user
                newUser.phone = _currentUser?.phone
                UserDefaults.currentUser = newUser
            }
            if let completion = completion {
                completion()
            } else {
                // Compat ancien flux
                self?.updateAddress()
            }
        }
    }

    func updateAddress() {
        if let _place = temporaryGooglePlace, let placeId = _place.placeID {
            SVProgressHUD.show()
            UserService.updateUserAddressWith(
                placeId: placeId,
                isSecondaryAddress: false
            ) { [weak self] _ in
                SVProgressHUD.dismiss()
                self?.goEnd()
            }
        } else if let _lat = self.temporaryLocation?.latitude,
                  let _long = self.temporaryLocation?.longitude {
            SVProgressHUD.show()
            let addressName = temporaryAddressName == nil
                ? "default"
                : temporaryAddressName!
            UserService.updateUserAddressWith(
                name: addressName,
                latitude: _lat,
                longitude: _long,
                isSecondaryAddress: false
            ) { [weak self] _ in
                SVProgressHUD.dismiss()
                self?.goEnd()
            }
        } else {
            // Pas d’adresse choisie → on termine quand même
            self.goEnd()
        }
    }
    // MARK: - ZoneChoice flow
    private func presentZoneChoice() {
        // Si l'utilisateur a choisi "asso" à la phase 3,
        // le nextStep doit être associationOnboarding.
        let nextStep: ZoneChoiceNextStep = (userTypeSelected == .assos)
            ? .associationOnboarding
            : .onboardingEnd

        presentZoneChoiceSwiftUI(
            initialCoordinate: temporaryLocation,
            initialLabel: temporaryAddressName,
            initialRadiusKm: 20,
            nextStep: nextStep,
            onConfirm: { [weak self] result in
                // On garde les infos localement si nécessaire,
                // mais la navigation est gérée par ZoneChoice lui-même.
                self?.temporaryGooglePlace = result.place
                self?.temporaryLocation = result.coordinate
                self?.temporaryAddressName = result.label
            },
            onCancel: { [weak self] in
                // Annulation = simple retour à l’écran précédent.
                // On ne termine plus l’onboarding ici.
                // L’animation de retour est gérée par ZoneChoice (pop/dismiss).
                // Si tu veux en plus forcer un retour à la phase 3 :
                // self?.currentPhasePosition = 3
                // self?.updateViewsForPosition()
                _ = self // juste pour garder [weak self] utile si tu veux ajouter qqch
            }
        )
    }


    func goEnd() {
        UserDefaults.standard.set(userTypeSelected.rawValue, forKey: "userType")
        UserDefaults.standard.set(true, forKey: "isFromOnboarding")
        UserDefaults.standard.set(false, forKey: "checkAfterLogin")

        let sb = UIStoryboard(name: StoryboardName.onboarding, bundle: nil)
        let vc = sb.instantiateViewController(
            withIdentifier: "OnboardingEndViewController"
        ) as! OnboardingEndViewController
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
    func addUserInfos(
        firstname: String?,
        lastname: String?,
        countryCode: CountryCode,
        phone: String?,
        email: String?,
        consentEmail: Bool,
        gender: String?,
        howWeMet howWeMet: String?,
        birthdate birthdate: String?,
        company: String?,
        event: String?
    ) {
        // UI storage
        self.phone = phone
        self.countryCode = countryCode
        self.email = email
        self.hasConsent = consentEmail
        self.gender = gender
        self.howWeMet = howWeMet
        self.company = company
        self.event = event

        // Build the user object used for the create call
        temporaryUser.firstname = firstname ?? ""
        temporaryUser.lastname  = lastname  ?? ""
        temporaryUser.phone     = Utils.validatePhoneFormat(
            countryCode: countryCode.code,
            phone: phone ?? ""
        )

        // Champs optionnels
        temporaryUser.email           = email
        temporaryUser.hasConsent      = consentEmail
        temporaryUser.gender          = gender
        temporaryUser.birthday        = birthdate           // "yyyy-MM-dd"
        temporaryUser.discoverySource = howWeMet
        temporaryUser.company         = company
        temporaryUser.event           = event

        // Phase button state : ne JAMAIS piloter le bouton en phase 1
        let v = checkValidation()
        if currentPhasePosition != 1 {
            enableDisableNextButton(isEnable: v.isValid)
        }
    }

    func sendCode(code: String) { self.temporaryPasscode = code }

    func addInfos(userType: UserType) {
        self.userTypeSelected = userType
        if currentPhasePosition != 1 {
            enableDisableNextButton(isEnable: checkValidation().isValid)
        }
    }

    func addPlace(
        currentlocation: CLLocationCoordinate2D?,
        currentLocationName: String?,
        googlePlace: GMSPlace?
    ) {
        self.temporaryGooglePlace = googlePlace
        self.temporaryLocation = currentlocation
        self.temporaryAddressName = currentLocationName
        if currentPhasePosition != 1 {
            enableDisableNextButton(isEnable: checkValidation().isValid)
        }
    }

    func goMain() { self.goPageBack() }
    func requestNewcode() { self.resendCode() }
}

// MARK: - MJNavBackViewDelegate

extension OnboardingStartViewController: MJNavBackViewDelegate {
    func goBack() { self.navigationController?.popViewController(animated: true) }
    func didTapEvent() { }
}

// MARK: - Phase helper

extension OnboardingStartViewController {
    /// Permet de forcer le démarrage à une phase donnée (1, 2 ou 3)
    func startAtPhase(_ phase: Int) {
        currentPhasePosition = phase
        if isViewLoaded {
            updateViewsForPosition()
        }
    }
}

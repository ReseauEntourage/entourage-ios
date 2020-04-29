//
//  OTOnboardingV2StartViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit
import SVProgressHUD

class OTOnboardingV2StartViewController: UIViewController {
    
    @IBOutlet weak var ui_label_position: UILabel!
    @IBOutlet weak var ui_container: UIView!
    @IBOutlet weak var ui_progress: OTProgressBarView!
    
    @IBOutlet weak var ui_bt_next: UIButton!
    @IBOutlet weak var ui_bt_previous: UIButton!
    @IBOutlet weak var ui_bt_pass: UIButton!
    var currentPosition:ControllerType = .firstLastName
    
    let nbOfSteps = 7
    
    var temporaryUser:OTUser = OTUser()
    var temporaryCountryCode = "+33"
    var temporaryPhone = ""
    var temporaryPasscode:String? = nil
    var userTypeSelected = UserType.none
    var temporaryGooglePlace:GMSPlace? = nil
    var temporaryLocation:CLLocation? = nil
    var temporaryEmail = ""
    var temporaryPassword = ""
    var temporaryPasswordConfirm = ""
    var temporaryUserPicture:UIImage? = nil
    
    //MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_bt_pass.setTitle(OTLocalisationService.getLocalizedValue(forKey: "onboard_button_pass")?.uppercased(), for: .normal)
        ui_bt_pass.isHidden = true
        changeController()
    }
    
    override func viewWillLayoutSubviews() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - Network -
    func callSignup() {
        
        SVProgressHUD.show()
        
        OTOnboardingService.init().setupNewUser(with: self.temporaryUser, success: { (onboardUser) in
            SVProgressHUD.dismiss()
            onboardUser?.phone =  self.temporaryUser.phone
            UserDefaults.standard.temporaryUser = onboardUser
            self.goNextStep()
        }) { (error) in
            SVProgressHUD.dismiss()
            if let _error = error as NSError? {
                var errorMessage = _error.localizedDescription
                let errorCode = _error.readCode()
                
                var showErrorHud = true
                if errorCode == INVALID_PHONE_FORMAT {
                    let alertVC = UIAlertController.init(title: nil, message: OTLocalisationService.getLocalizedValue(forKey: "invalidPhoneNumberFormat"), preferredStyle: .alert)
                    let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "close"), style: .default, handler: nil)
                    
                    alertVC.addAction(action)
                    self.navigationController?.present(alertVC, animated: true, completion: nil)
                    showErrorHud = false
                }
                else if errorCode == PHONE_ALREADY_EXIST {
                    errorMessage = OTLocalisationService.getLocalizedValue(forKey:"alreadyRegisteredShortMessage")
                    self.goNextStep()
                }
                
                if (errorMessage.count > 0) {
                    if(showErrorHud) {
                        SVProgressHUD.showError(withStatus: errorMessage)
                    }
                }
                else {
                    SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "alreadyRegisteredMessage"))
                }
            }
        }
    }
    
    func sendPasscode() {
        guard let tempPwd = temporaryPasscode else {
            return
        }
        
        SVProgressHUD.show()
        
        OTAuthService.init().auth(withPhone: self.temporaryUser.phone, password: tempPwd, success: { (user, isFirstlogin) in
            user?.phone =  self.temporaryUser.phone
            SVProgressHUD.dismiss()
            self.temporaryUser.firstName = user?.firstName
            self.temporaryUser.lastName = user?.lastName
            UserDefaults.standard.currentUser = user
            UserDefaults.standard.temporaryUser = nil
            UserDefaults.standard.setFirstLoginState(!isFirstlogin)
            
            self.goNextStep()
            
        }) { (error) in
            SVProgressHUD.dismiss()
            
            let alertvc = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "tryAgain"), message: OTLocalisationService.getLocalizedValue(forKey: "invalidPhoneNumberOrCode"), preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey:"tryAgain_short"), style: .default, handler: nil)
            alertvc.addAction(action)
            DispatchQueue.main.async {
                self.navigationController?.present(alertvc, animated: true, completion: nil)
            }
        }
    }
    
    func resendCode() {
        SVProgressHUD.show()
        OTAuthService.init().regenerateSecretCode(self.temporaryUser.phone, success: { (user) in
            SVProgressHUD.dismiss()
            SVProgressHUD.showSuccess(withStatus: OTLocalisationService.getLocalizedValue(forKey: "requestSent"))
        }) { (error) in
            SVProgressHUD.dismiss()
            let alertvc = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "error"), message: OTLocalisationService.getLocalizedValue(forKey: "requestNotSent"), preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey:"OK"), style: .default, handler: nil)
            alertvc.addAction(action)
            DispatchQueue.main.async {
                self.navigationController?.present(alertvc, animated: true, completion: nil)
            }
        }
    }
    
    func sendAddAddress() {
        if let _place = temporaryGooglePlace {
            SVProgressHUD.show()
            OTAuthService.updateUserAddress(withPlaceId: _place.placeID) { (error) in
                SVProgressHUD.dismiss()
                self.goNextStep()
            }
        }
        else if let _lat = self.temporaryLocation?.coordinate.latitude, let _long = self.temporaryLocation?.coordinate.longitude {
            SVProgressHUD.show()
            OTAuthService.updateUserAddress(withName: "Default", andLatitude: NSNumber.init(value: _lat), andLongitude: NSNumber.init(value: _long)) { (error) in
                SVProgressHUD.dismiss()
                self.goNextStep()
            }
        }
    }
    
    func updateUserEmailPwd() {
        var isValid = false
        var message = OTLocalisationService.getLocalizedValue(forKey: "onboard_email_pwd_error_email")
        if temporaryEmail.isValidEmail {
            if  temporaryPassword == temporaryPasswordConfirm {
                isValid = true
            }
            else {
                message = OTLocalisationService.getLocalizedValue(forKey: "onboard_email_pwd_error_pwd_match")
            }
        }
        
        if !isValid {
            let alertvc = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "error"), message: message, preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey:"OK"), style: .default, handler: nil)
            alertvc.addAction(action)
            
            self.navigationController?.present(alertvc, animated: true, completion: nil)
            return
        }
        
        SVProgressHUD.show()
        let _currentUser = UserDefaults.standard.currentUser
        _currentUser?.email = temporaryEmail
        OTAuthService().updateUserInformation(with: _currentUser, success: { (newUser) in
            newUser?.phone = _currentUser?.phone
            UserDefaults.standard.currentUser = newUser
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.goNextStep()
            }
        }) { (error) in
            DispatchQueue.main.async {
                SVProgressHUD.dismiss()
                self.goNextStep()
            }
        }
    }
    
    func updateUserPhoto() {
        let _currentUser = UserDefaults.standard.currentUser
        SVProgressHUD.show()
        OTPictureUploadService().uploadPicture(temporaryUserPicture, withSuccess: { (pictureName) in
            _currentUser?.avatarKey = pictureName
            OTAuthService().updateUserInformation(with: _currentUser, success: { (newUser) in
                newUser?.phone = _currentUser?.phone
                UserDefaults.standard.currentUser = newUser
                SVProgressHUD.dismiss()
                self.showPopNotification()
            }) { (error) in
                SVProgressHUD.dismiss()
                SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "user_photo_change_error"))
                self.showPopNotification()
            }
        }) { (error) in
            SVProgressHUD.dismiss()
            SVProgressHUD.showError(withStatus: OTLocalisationService.getLocalizedValue(forKey: "user_photo_change_error"))
            self.showPopNotification()
        }
    }
    
    //MARK: - Methods -
    func showPopNotification() {
        if let _currentUser = UserDefaults.standard.currentUser {
            print("Should show : currentUser : \(_currentUser)")
            if OTAppConfiguration.shouldShowIntroTutorial(_currentUser) {
                UserDefaults.standard.setTutorialCompleted()
            }
        }
        
        let alertVC = UIAlertController.init(title: OTLocalisationService.getLocalizedValue(forKey: "pop_notification_title"), message: OTLocalisationService.getLocalizedValue(forKey: "pop_notification_description"), preferredStyle: .alert)
        
        let actionValidate = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "pop_notification_bt_activate"), style: .default) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
            self.showPopupNotificationAuth()
        }
        
        let actionCancel = UIAlertAction.init(title: OTLocalisationService.getLocalizedValue(forKey: "pop_notification_bt_cancel"), style: .cancel) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
            self.goMain()
        }
        alertVC.addAction(actionCancel)
        alertVC.addAction(actionValidate)
        
        self.navigationController?.present(alertVC, animated: true, completion: nil)
    }
    
    func showPopupNotificationAuth() {
        OTPushNotificationsService.promptUserForAuthorizations {
            DispatchQueue.main.async {
                self.goMain()
            }
        }
    }
    
    func goMain() {
        OTAppState.navigateToAuthenticatedLandingScreen()
    }
    
    //MARK: - IBActions -
    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func action_next(_ sender: Any) {
        if currentPosition.rawValue <= nbOfSteps {
            if currentPosition == .phone {
                self.callSignup()
                return
            }
            
            if currentPosition == .passCode {
                if let pwd = temporaryPasscode, pwd.count == 6 {
                    self.sendPasscode()
                }
                else {
                    SVProgressHUD.showInfo(withStatus: "Veuillez remplir le password")
                }
                return
            }
            
            if currentPosition == .place {
                self.sendAddAddress()
                return
            }
            
            if currentPosition == .emailPwd {
                self.updateUserEmailPwd()
                return
            }
            
            if currentPosition == .photo {
                updateUserPhoto()
                return
            }
            
            currentPosition = ControllerType(rawValue: currentPosition.rawValue + 1)!
            changeController()
        }
    }
    
    @IBAction func action_previous(_ sender: Any) {
        if currentPosition.rawValue > 0 {
            currentPosition = ControllerType(rawValue: currentPosition.rawValue - 1)!
            changeController()
        }
    }
    
    @IBAction func action_pass(_ sender: Any) {
        if currentPosition == .type {
            userTypeSelected = .none
        }
        if currentPosition == .photo {
            showPopNotification()
            return
        }
        
        action_next(sender)
    }
}

//MARK: - Navigation -
extension OTOnboardingV2StartViewController {
    
    func changeController() {
        ui_bt_next.isEnabled = false
        
        switch currentPosition {
        case .firstLastName:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_names") as? OTOnboardingNamesViewController {
                vc.delegate = self
                vc.userFirstname = self.temporaryUser.firstName
                vc.userLastname = self.temporaryUser.lastName
                add(asChildViewController: vc)
            }
        case .phone:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_phone") as? OTOnboardingPhoneViewController {
                vc.delegate = self
                vc.countryCode = temporaryCountryCode
                vc.tempPhone = self.temporaryPhone
                vc.firstname = temporaryUser.firstName
                add(asChildViewController: vc)
            }
        case .passCode:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_code") as? OTOnboardingPassCodeViewController {
                vc.delegate = self
                vc.tempPhone = self.temporaryUser.phone
                add(asChildViewController: vc)
            }
        case .type:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_type") as? OTOnboardingTypeViewController {
                vc.delegate = self
                vc.userTypeSelected = self.userTypeSelected
                vc.firstname = self.temporaryUser.firstName
                add(asChildViewController: vc)
            }
            
        case .place:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_place") as? OTOnboardingPlaceViewController {
                vc.delegate = self
                vc.currentLocation = self.temporaryLocation
                vc.selectedPlace = self.temporaryGooglePlace
                add(asChildViewController: vc)
            }
        case .emailPwd:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_mail_pwd") as? OTOnboardingEmailPwdViewController {
                vc.delegate = self
                vc.tempEmail = self.temporaryEmail
                add(asChildViewController: vc)
            }
        case .photo:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_photo") as? OTOnboardingPhotoViewController {
                vc.delegate = self
                vc.currentUserFirstname = self.temporaryUser.firstName
                vc.selectedImage = self.temporaryUserPicture
                add(asChildViewController: vc)
            }
        }
        
        let percent = (ui_progress.bounds.size.width / CGFloat(nbOfSteps)) * CGFloat(currentPosition.rawValue)
        ui_progress.progressPercent = percent
        ui_progress.setNeedsDisplay()
        ui_label_position.attributedText = Utilitaires.formatString(stringMessage: "0\(currentPosition.rawValue) / 0\(nbOfSteps)", coloredTxt: "0\(nbOfSteps)", color: UIColor.appOrange(), colorHighlight: UIColor.appGrey165, fontSize: 24, fontWeight: .bold, fontColoredWeight: .bold)
        
        updatebuttons()
    }
    
    func updatebuttons() {
        ui_bt_pass.isHidden = true
        switch currentPosition {
        case .firstLastName,.type:
            ui_bt_previous.isHidden = true
        case .phone,.passCode,.place,.emailPwd,.photo:
            ui_bt_previous.isHidden = false
        }
        
        if currentPosition == .type  || currentPosition == .photo {
            ui_bt_pass.isHidden = false
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        if childViewControllers.count > 0 {
            let oldChild = childViewControllers[0]
            swapViewControllers(oldViewController: oldChild, toViewController: viewController)
            return;
        }
        
        if self.childViewControllers.count > 0 {
            while childViewControllers.count > 0 {
                remove(asChildViewController: childViewControllers[0])
            }
        }
        
        addChildViewController(viewController)
        
        ui_container.addSubview(viewController.view)
        
        viewController.view.frame = ui_container.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParentViewController: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        
        viewController.willMove(toParentViewController: nil)
        
        viewController.view.removeFromSuperview()
        
        viewController.removeFromParentViewController()
    }
    
    func swapViewControllers(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParentViewController: nil)
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChildViewController(newViewController)
        self.addSubViewController(subView: newViewController.view, toView:self.ui_container)
        
        newViewController.view.alpha = 0
        newViewController.view.layoutIfNeeded()
        
        UIView.animate(withDuration: 0.3, delay: 0.1, options: .showHideTransitionViews, animations: {
            newViewController.view.alpha = 1
            oldViewController.view.alpha = 0
        }) { (finished) in
            self.remove(asChildViewController: oldViewController)
        }
    }
    
    private func addSubViewController(subView:UIView, toView parentView:UIView) {
        self.view.layoutIfNeeded()
        parentView.addSubview(subView)
        
        subView.leadingAnchor.constraint(equalTo: parentView.leadingAnchor).isActive = true
        subView.topAnchor.constraint(equalTo: parentView.topAnchor).isActive = true
        subView.bottomAnchor.constraint(equalTo: parentView.bottomAnchor).isActive = true
        subView.trailingAnchor.constraint(equalTo: parentView.trailingAnchor).isActive  = true
    }
    
    func goNextStep() {
        self.currentPosition = ControllerType(rawValue: self.currentPosition.rawValue + 1)!
        self.changeController()
    }
}

//MARK: - Delegate -
extension OTOnboardingV2StartViewController: OnboardV2Delegate {
    
    func goNextManually() {
        self.action_next(self)
    }
    
    func updateButtonNext(isValid:Bool) {
        ui_bt_next.isEnabled = isValid ? true : false
    }
    
    func validateFirstLastname(firstName: String?, lastname: String?) {
        self.temporaryUser.firstName = firstName == nil ? "" : firstName!
        self.temporaryUser.lastName = lastname == nil ? "" : lastname!
    }
    
    func validatePhoneNumber(prefix: String, phoneNumber: String?) {
        if let _phone = phoneNumber {
            var phoneNb = _phone.trimmingCharacters(in: .whitespaces)
            if !phoneNb.hasPrefix("+") && phoneNb.hasPrefix("0") {
                phoneNb.remove(at: .init(encodedOffset: 0))
            }
            phoneNb = "\(prefix)\(phoneNb)"
            self.temporaryUser.phone = phoneNb
            self.temporaryPhone = _phone
            self.temporaryCountryCode = prefix
        }
        else {
            self.temporaryPhone = ""
            self.temporaryCountryCode = "+33"
        }
    }
    
    func validatePasscode(password:String) {
        self.temporaryPasscode = password
    }
    
    func requestNewcode() {
        self.resendCode()
    }
    
    func updateNewAddress(googlePlace:GMSPlace?,gpsLocation:CLLocation?) {
        self.temporaryGooglePlace = googlePlace
        self.temporaryLocation = gpsLocation
        
        if googlePlace != nil || gpsLocation != nil {
            updateButtonNext(isValid: true)
        }
        else {
            updateButtonNext(isValid: false)
        }
    }
    
    func updateUserType(userType: UserType) {
        self.userTypeSelected = userType
    }
    
    func updateEmailPwd(email:String,pwd:String,pwdConfirm:String) {
        self.temporaryEmail = email
        self.temporaryPassword = pwd
        self.temporaryPasswordConfirm = pwdConfirm
    }
    
    func updateUserPhoto(image: UIImage) {
        self.temporaryUserPicture = image
    }
}

//MARK: - Protocol -
protocol OnboardV2Delegate:class {
    func goNextManually()
    func validateFirstLastname(firstName:String?,lastname:String?)
    func validatePhoneNumber(prefix:String,phoneNumber:String?)
    func updateButtonNext(isValid:Bool)
    func validatePasscode(password:String)
    func requestNewcode()
    func updateNewAddress(googlePlace:GMSPlace?,gpsLocation:CLLocation?)
    func updateUserType(userType:UserType)
    func updateEmailPwd(email:String,pwd:String,pwdConfirm:String)
    func updateUserPhoto(image:UIImage)
}

//MARK: - Enums -
enum ControllerType:Int {
    case firstLastName = 1
    case phone = 2
    case passCode = 3
    case type = 4
    case place = 5
    case emailPwd = 6
    case photo = 7
}

enum UserType:Int {
    case neighbour = 1
    case alone = 2
    case assos = 3
    case none = -1
}

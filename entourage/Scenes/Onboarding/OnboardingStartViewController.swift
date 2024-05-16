//
//  OnboardingStartViewController.swift
//  entourage
//
//  Created by You on 30/11/2022.
//

import UIKit
import IHProgressHUD
import CoreLocation
import GooglePlaces

class OnboardingStartViewController: UIViewController {
    @IBOutlet weak var ui_page_control: MJCustomPageControl!
    
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_main_container_view: UIView!
    @IBOutlet weak var ui_container_view: UIView!
    @IBOutlet weak var ui_bt_previous: UIButton!
    @IBOutlet weak var ui_bt_next: UIButton!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    weak var parentDelegate:OTPreOnboardingV2ChoiceViewController? = nil
    
    var pageViewController:OnboardingPageViewController? = nil
    
    var currentPhasePosition = 1
    var shouldLaunchThird = false
    
    let minimumCharacters = 2
    let minimumPhoneCharacters = 9
    
    var temporaryUser:User = User()
    var temporaryPasscode:String? = nil
    var countryCode:CountryCode = defaultCountryCode
    var phone:String? = nil
    var email:String? = nil
    var hasConsent = false
    
    var userTypeSelected = UserType.none
    var temporaryGooglePlace:GMSPlace? = nil
    var temporaryLocation:CLLocationCoordinate2D? = nil
    var temporaryAddressName:String? = nil
    var isLocOk = false
    var isTypeOk = false
    
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
        
        ui_bt_next.layer.cornerRadius = ui_bt_next.frame.height / 2
        ui_bt_next.backgroundColor = .appOrangeLight
        ui_bt_next.setTitleColor(.white, for: .normal)
        ui_bt_next.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_bt_next.setTitle("onboard_bt_next".localized, for: .normal)
        
        enableDisableNextButton(isEnable: false)
        
        ui_main_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        self.modalPresentationStyle = .fullScreen
        
        ui_top_view.populateCustom(title: "onboard_welcome_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 24), titleColor: .white, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
        if shouldLaunchThird {
            self.updateViewsForPosition()
            self.ui_page_control.isHidden = true
        }
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
    
    func countValidate(){
        if isLocOk && isTypeOk {
            enableDisableNextButton(isEnable: true)
        }else{
            enableDisableNextButton(isEnable: false)
        }
    }
    
    func showError(message:String) {
        ui_error_view.changeTitleAndImage(title: message)
        ui_error_view.show()
    }
    
    func showPopAlreadySigned() {
        let alertVC = UIAlertController.init(title: nil, message:  "alreadyRegistereMessageGoBack".localized, preferredStyle: .alert)
        let action = UIAlertAction.init(title:  "OK".localized, style: .default, handler: { (action) in
            self.parentDelegate?.isFromOnboarding = true
            self.navigationController?.popViewController(animated: true)
        })
        
        alertVC.addAction(action)
        self.navigationController?.present(alertVC, animated: true, completion: nil)
    }
    
    //MARK: - Navigation -
    
    @IBAction func action_next(_ sender: Any) {
        let isValid = checkValidation()
        
        if isValid.isValid {
            goPageNext()
        }
        else {
            showError(message: isValid.message)
        }
    }
    
    @IBAction func action_back(_ sender: Any) {
        goPageBack()
    }
    
    func goPageNext() {
        if currentPhasePosition == 1 {
            self.sendPhone()
        }
        else if currentPhasePosition == 2 {
            self.createUser()
        }
        else if currentPhasePosition == 3 {
            self.updateUser()
            return
        }
        updateViewsForPosition()
    }
    
    func goNextStep() {
        currentPhasePosition = currentPhasePosition + 1

        updateViewsForPosition()
    }
    
    func goPageBack() {
        currentPhasePosition = currentPhasePosition - 1
        if currentPhasePosition < 1 {
            currentPhasePosition = 1
        }
        
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
        case 2:
            ui_top_view.updateTitle(title: "onboard_sms_title".localized)
            ui_bt_previous.isHidden = false
            ui_bt_next.isHidden = false
            pageViewController?.createPhase2VC?.tempPhone = phone ?? "-"
        case 3:
            let _title = String.init(format: "onboard_phone_title".localized, temporaryUser.firstname)
            ui_top_view.updateTitle(title: _title)
            ui_top_view.hideButtonBackForUnboarding(hide: true)
            ui_bt_previous.isHidden = true
            ui_bt_next.isHidden = false
            ui_bt_next.setTitle("onboard_bt_create".localized, for: .normal)
            if shouldLaunchThird{
                ui_bt_next.setTitle("onboard_bt_next".localized, for: .normal)
            }
        default:
            break
        }
        _ = checkValidation()
    }
    
    func enableDisableNextButton(isEnable:Bool) {
        if isEnable {
            ui_bt_next.alpha = 1.0
        }
        else {
            ui_bt_next.alpha = 0.4
        }
    }
    
    func checkValidation() -> (isValid:Bool,message:String) {
        var isValid = true
        var message = ""
        if currentPhasePosition == 1 {
            if temporaryUser.firstname.count < minimumCharacters {
                isValid = false
                message = "onboard_error_firstname".localized
            }
            else if temporaryUser.lastname.count < minimumCharacters {
                isValid = false
                message = "onboard_error_lastname".localized
            }
            else if phone?.count ?? 0 < minimumPhoneCharacters {
                isValid = false
                message = "onboard_error_phone".localized
            }

            else if email?.count ?? 0 > 0 && (email?.isValidEmail ?? false) == false {
                isValid = false
                message = "oonboard_error_email".localized
            }
        }
        if currentPhasePosition == 3 {
            if userTypeSelected == .none {
                isValid = false
                message = "onboard_error_Usertype".localized
            }
            else if temporaryLocation == nil && temporaryGooglePlace == nil {
                isValid = false
                message = "onboard_error_place".localized
            }
            
        }
        if isValid {
            enableDisableNextButton(isEnable: true)
        }
        return (isValid,message)
    }
    
    //MARK: - Network -
    func sendPhone() {
        IHProgressHUD.show()
        
        AuthService.createAccountWith(user: self.temporaryUser) { [weak self] phone, error in
            IHProgressHUD.dismiss()
            if let error = error {
                var showErrorHud = true
                if error.code == "INVALID_PHONE_FORMAT" {
                    let alertVC = UIAlertController.init(title: nil, message:  "invalidPhoneNumberFormat".localized, preferredStyle: .alert)
                    let action = UIAlertAction.init(title:  "close".localized, style: .default, handler: nil)
                    
                    alertVC.addAction(action)
                    
                    self?.navigationController?.present(alertVC, animated: true, completion: nil)
                    showErrorHud = false
                }
                else if error.code == "PHONE_ALREADY_EXIST" {
                    self?.showPopAlreadySigned()
                    return
                }
                if (error.message.count > 0) {
                    if(showErrorHud) {
                        IHProgressHUD.showError(withStatus: error.message)
                    }
                }
                else {
                    IHProgressHUD.showError(withStatus:  "alreadyRegisteredMessage".localized)
                }
            }
            else {
                var newUser = User()
                newUser.phone = phone
                UserDefaults.temporaryUser = newUser
                self?.goNextStep()
            }
        }
    }
    
    func createUser() {
       
        guard let tempPwd = temporaryPasscode else {
            return
        }
        
        IHProgressHUD.show()
        AuthService.postLogin(phone: self.temporaryUser.phone!, password: tempPwd) { [weak self] user, error, isFirstLogin in
            IHProgressHUD.dismiss()
            
            if let _ = error {
                let alertvc = UIAlertController.init(title:  "tryAgain".localized, message:  "invalidPhoneNumberOrCode".localized, preferredStyle: .alert)
                
                let action = UIAlertAction.init(title: "tryAgain_short".localized, style: .default, handler: nil)
                alertvc.addAction(action)
                
                self?.navigationController?.present(alertvc, animated: true, completion: nil)
            }
            else if let user = user {
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
            if let _ = error {
                let alertvc = UIAlertController.init(title:  "error".localized, message:  "requestNotSent".localized, preferredStyle: .alert)
                let action = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
                alertvc.addAction(action)
                
                self?.navigationController?.present(alertvc, animated: true, completion: nil)
            }
            else {
                IHProgressHUD.showSuccesswithStatus(  "requestSent".localized)
            }
        }
    }
    
    func updateUser() {
        IHProgressHUD.show()
        var _currentUser = UserDefaults.currentUser
        _currentUser?.goal = userTypeSelected.getGoalString()
        if let email = email {
            _currentUser?.email = email
        }
        
        _currentUser?.hasConsent = hasConsent
        
        UserService.updateUser(user: _currentUser) { [weak self] user, error in
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
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { [weak self] error in
                IHProgressHUD.dismiss()
                self?.goEnd()
            }
        }
        else if let _lat = self.temporaryLocation?.latitude, let _long = self.temporaryLocation?.longitude {
            IHProgressHUD.show()
            let addressName = temporaryAddressName == nil ? "default" : temporaryAddressName!
            
            UserService.updateUserAddressWith(name: addressName, latitude: _lat, longitude: _long, isSecondaryAddress: false) { [weak self] error in
                IHProgressHUD.dismiss()
                self?.goEnd()
            }
        }
    }
    
    func goEnd() {
        UserDefaults.standard.set(userTypeSelected.rawValue, forKey: "userType")
        UserDefaults.standard.set(true, forKey: "isFromOnboarding")
        UserDefaults.standard.set(false, forKey: "checkAfterLogin")
        
        let sb = UIStoryboard.init(name: StoryboardName.onboarding, bundle: nil)
        let vc = sb.instantiateViewController(withIdentifier: "OnboardingEndViewController") as! OnboardingEndViewController
        if shouldLaunchThird{
            if let window = UIApplication.shared.windows.first {
                window.rootViewController = vc
                window.makeKeyAndVisible()
            }
        }else{
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MARK: - Onboarding Delegate -
extension OnboardingStartViewController: OnboardingDelegate {
    func addUserInfos(firstname: String?, lastname: String?, countryCode: CountryCode, phone: String?, email: String?, consentEmail: Bool) {
        temporaryUser.firstname = firstname ?? ""
        temporaryUser.lastname = lastname ?? ""
        temporaryUser.phone = Utils.validatePhoneFormat(countryCode: countryCode.code, phone: phone ?? "")
        
        self.phone = phone
        self.countryCode = countryCode
        self.email = email
        self.hasConsent = consentEmail
        
       let validate = checkValidation()
        enableDisableNextButton(isEnable: validate.isValid)
    }
    
    func sendCode(code: String) {
        self.temporaryPasscode = code
    }
    
    func addInfos(userType:UserType) {
        self.userTypeSelected = userType
        if shouldLaunchThird && userType != .none{
            self.isTypeOk = true
            self.countValidate()
        }else{
            self.isTypeOk = false
            self.countValidate()
        }

    }
    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        self.temporaryGooglePlace = googlePlace
        self.temporaryLocation = currentlocation
        self.temporaryAddressName = currentLocationName
        if shouldLaunchThird && googlePlace != nil {
            self.isLocOk = true
            self.countValidate()
        }else{
            self.isLocOk = false
            self.countValidate()
        }
    }
    
    func goMain() {
        self.goPageBack()
    }
    
    func requestNewcode() {
        self.resendCode()
    }
}


//MARK: - MJNavBackViewDelegate -
extension OnboardingStartViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.popViewController(animated: true)
    }
}

//
//  OTOnboardingV2StartViewController.swift
//  entourage
//
//  Created by Jr on 21/04/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import GooglePlaces
import IHProgressHUD

class OTOnboardingV2StartViewController: UIViewController {
    
    @IBOutlet weak var ui_button_back: UIButton!
    @IBOutlet weak var ui_image_back: UIImageView!
    @IBOutlet weak var ui_label_position: UILabel!
    @IBOutlet weak var ui_container: UIView!
    @IBOutlet weak var ui_progress: OTProgressBarView!
    
    @IBOutlet weak var ui_bt_next: UIButton!
    @IBOutlet weak var ui_bt_previous: UIButton!
    @IBOutlet weak var ui_bt_pass: UIButton!
    var currentPosition:ControllerType = .firstLastName
    var currentPositionAsso:ControllerAssoType = .none
    var currentPositionAlone:ControllerAloneType = .none
    var currentPositionNeighbour:ControllerNeighbourType = .none
    
    let nbOfSteps = 6
    
    var temporaryUser:User = User()
    var temporaryCountryCode = "+33"
    var temporaryPhone = ""
    var temporaryPasscode:String? = nil
    var userTypeSelected = UserType.none
    var temporaryGooglePlace:GMSPlace? = nil
    var temporaryLocation:CLLocation? = nil
    var temporaryAddressName:String? = nil
    var temporaryEmail = ""
    var temporaryPassword = ""
    var temporaryPasswordConfirm = ""
    var temporaryAssoInfo:Partner? = nil
    var temporaryAssoActivities:AssoActivities? = nil
    var temporarySdfActivities:SdfNeighbourActivities? = nil
    var temporaryNeighbourActivities:SdfNeighbourActivities? = nil
    
    weak var parentDelegate:OTPreOnboardingV2ChoiceViewController? = nil
    
    //MARK: - Lifecycle -
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_bt_pass.setTitle( "onboard_button_pass".localized.uppercased(), for: .normal)
        ui_bt_pass.isHidden = true
        changeController()
    }
    
    override func viewWillLayoutSubviews() {
        self.navigationController?.isNavigationBarHidden = true
    }
    
    //MARK: - Network -
    func callSignup() {
        IHProgressHUD.show()
        //        OTLogger.logEvent(Action_Onboarding_Phone_Submit)//TODO: a faire Analytics
        
        AuthService.createAccountWith(user: self.temporaryUser) { [weak self] user, error in
            IHProgressHUD.dismiss()
            if let error = error {
                Logger.print("***** Error \(error)")
                var showErrorHud = true
                if error.code == "INVALID_PHONE_FORMAT" {
                    let alertVC = UIAlertController.init(title: nil, message:  "invalidPhoneNumberFormat".localized, preferredStyle: .alert)
                    let action = UIAlertAction.init(title:  "close".localized, style: .default, handler: nil)
                    
                    alertVC.addAction(action)
                    
                    self?.navigationController?.present(alertVC, animated: true, completion: nil)
                    showErrorHud = false
                    //OTLogger.logEvent(Error_Onboarding_Phone_Submit_Error)//TODO: a faire Analytics
                }
                else if error.code == "PHONE_ALREADY_EXIST" {
                    //  OTLogger.logEvent(Error_Onboarding_Phone_Submit_Exist)//TODO: a faire Analytics
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
                var newUser = user
                newUser?.phone = self?.temporaryUser.phone
                UserDefaults.temporaryUser = newUser
                // OTLogger.logEvent(Action_Onboarding_Phone_Submit_Success)//TODO: a faire Analytics
                self?.goNextStep()
            }
        }
    }
    
    func sendPasscode() {
        guard let tempPwd = temporaryPasscode else {
            return
        }
        
        IHProgressHUD.show()
//        OTLogger.logEvent(Action_Onboarding_SignUp_Submit)//TODO: a faire Analytics
        AuthService.postLogin(phone: self.temporaryUser.phone!, password: tempPwd) { [weak self] user, error, isFirstLogin in
            IHProgressHUD.dismiss()
            
            if let _ = error {
//                OTLogger.logEvent(Error_Onboarding_SignUp_Fail)//TODO: a faire Analytics
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
//                OTLogger.logEvent(Action_Onboarding_SignUp_Success)//TODO: a faire Analytics
                self?.goNextStep()
            }
        }
    }
    
    func updateGoalType(isAsso:Bool) {
        IHProgressHUD.show()
        var _currentUser = UserDefaults.currentUser
        _currentUser?.goal = userTypeSelected.getGoalString()
        
        if userTypeSelected != .none {
//            OTLogger.logEvent(Action_Onboarding_Choose_Profile_Signup)//TODO: a faire Analytics
        }
        
        UserService.updateUser(user: _currentUser) { [weak self] user, error in
            IHProgressHUD.dismiss()
            
            if let user = user {
                var newUser = user
                newUser.phone = _currentUser?.phone
                UserDefaults.currentUser = newUser
            }
            
            if isAsso {
                if let self = self {
                    self.currentPositionAsso = ControllerAssoType(rawValue: self.currentPositionAsso.rawValue + 1)!
                    self.moveToTunnelAsso()
                }
            }
            else {
                self?.goNextStep()
            }
        }
    }
    
    func resendCode() {
        IHProgressHUD.show()
//        OTLogger.logEvent(Action_Onboarding_SMS)//TODO: a faire Analytics
        
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
    
    func sendAddAddress() {
//        OTLogger.logEvent(Action_Onboarding_Action_Zone_Submit) //TODO: a faire Analytics
        
        if let _place = temporaryGooglePlace, let placeId = _place.placeID {
            IHProgressHUD.show()
            UserService.updateUserAddressWith(placeId: placeId, isSecondaryAddress: false) { [weak self] error in
                IHProgressHUD.dismiss()
                self?.goNextStep()
            }
        }
        else if let _lat = self.temporaryLocation?.coordinate.latitude, let _long = self.temporaryLocation?.coordinate.longitude {
            IHProgressHUD.show()
            let addressName = temporaryAddressName == nil ? "default" : temporaryAddressName!
            
            UserService.updateUserAddressWith(name: addressName, latitude: _lat, longitude: _long, isSecondaryAddress: false) { [weak self] error in
                IHProgressHUD.dismiss()
                self?.goNextStep()
            }
        }
    }
    
    func updateUserEmailPwd() {
        var isValid = false
        var message =  "onboard_email_pwd_error_email".localized
        if temporaryEmail.isValidEmail {
            if  temporaryPassword == temporaryPasswordConfirm {
                isValid = true
            }
            else {
                message =  "onboard_email_pwd_error_pwd_match".localized
            }
        }
        
        if !isValid {
            let alertvc = UIAlertController.init(title:  "error".localized, message: message, preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
            alertvc.addAction(action)
            
            self.navigationController?.present(alertvc, animated: true, completion: nil)
            return
        }
        
        IHProgressHUD.show()
        var _currentUser = UserDefaults.currentUser
        _currentUser?.email = temporaryEmail
//        OTLogger.logEvent(Action_Onboarding_Email_Submit)//TODO: a faire Analytics
        
        UserService.updateUser(user: _currentUser) { [weak self] user, error in
            IHProgressHUD.dismiss()
            
            if let user = user {
                var newUser = user
                newUser.phone = _currentUser?.phone
                UserDefaults.currentUser = newUser
                self?.updateInfosAndShowPop()
            }
            else {
//                OTLogger.logEvent(Error_Onboarding_Email_Submit_Error)//TODO: a faire Analytics
                self?.showPopNotification()
            }
        }
    }
    
    func updateInfosAndShowPop() {
        if self.userTypeSelected == .alone {
            self.updateAlone()
        }
        else if self.userTypeSelected == .neighbour {
            self.updateNeighbour()
        }
        
        DispatchQueue.main.async {
            IHProgressHUD.dismiss()
            self.showPopNotification()
        }
    }
    
    
    //MARK: - Network Asso -
    
    func updateAssoInfos() {
        if let _asso = temporaryAssoInfo,_asso.name.count > 0, _asso.postalCode?.count ?? 0 > 0, _asso.userRoleTitle?.count ?? 0 > 0 {
            
            IHProgressHUD.show()
//            OTLogger.logEvent(Action_Onboarding_Pro_SignUp_Submit)//TODO: a faire Analytics
            
            UserService.updateUserAssociationInfo(association: temporaryAssoInfo!) { [weak self] error in
                IHProgressHUD.dismiss()
                if error == nil {
//                OTLogger.logEvent(Action_Onboarding_Pro_SignUp_Success)//TODO: a faire Analytics
                }
                else {
//                    OTLogger.logEvent(Error_Onboarding_Pro_SignUp_Error)//TODO: a faire Analytics
                }
                if let self = self {
                    self.currentPositionAsso = ControllerAssoType(rawValue: self.currentPositionAsso.rawValue + 1)!
                    self.moveToTunnelAsso()
                }
            }
        }
        else {
            let alertvc = UIAlertController.init(title:  "attention_pop_title".localized, message:  "onboard_asso_fill_error".localized, preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
            alertvc.addAction(action)
            
            self.navigationController?.present(alertvc, animated: true, completion: nil)
        }
    }
    
    func updateAssoActivity() {
        if let _activities = temporaryAssoActivities, _activities.hasOneSelectionMin() {
            IHProgressHUD.show()
//            OTLogger.logEvent(Action_Onboarding_Pro_Mosaic)//TODO: a faire Analytics
            
            UserService.updateUserInterests(interests: _activities.getArrayForWS()) { [weak self] user, error in
                IHProgressHUD.dismiss()
                guard let self = self else { return }
                self.currentPosition = ControllerType(rawValue: self.currentPosition.rawValue + 2)!
                self.changeController()
            }
        }
        else {
            let alertvc = UIAlertController.init(title:  "attention_pop_title".localized, message:  "onboard_asso_activity_error".localized, preferredStyle: .alert)
            
            let action = UIAlertAction.init(title: "OK".localized, style: .default, handler: nil)
            alertvc.addAction(action)
            
            self.navigationController?.present(alertvc, animated: true, completion: nil)
        }
    }
    
    
    func updateAlone() {
        temporarySdfActivities = SdfNeighbourActivities(isSdf: true)
        updateActivities(activities: temporarySdfActivities, isSdf: true)
    }
    
    func updateNeighbour() {
        temporaryNeighbourActivities = SdfNeighbourActivities(isSdf: false)
        updateActivities(activities: temporaryNeighbourActivities, isSdf: false)
    }
    
    func updateActivities(activities:SdfNeighbourActivities?,isSdf:Bool) {
        if let _activities = activities, _activities.hasOneSelectionMin() {
            UserService.updateUserInterests(interests: _activities.getArrayForWS()) { user, error in
                if let user = user {
                    let _currentUser = UserDefaults.currentUser
                    var newUser = user
                    newUser.phone = _currentUser?.phone
                    UserDefaults.currentUser = newUser
                }
            }
        }
    }
    
    //MARK: - Methods -
    func showPopAlreadySigned() {
        let alertVC = UIAlertController.init(title: nil, message:  "alreadyRegistereMessageGoBack".localized, preferredStyle: .alert)
        let action = UIAlertAction.init(title:  "OK".localized, style: .default, handler: { (action) in
            self.parentDelegate?.isFromOnboarding = true
            self.navigationController?.popViewController(animated: true)
            
        })
        
        alertVC.addAction(action)
        self.navigationController?.present(alertVC, animated: true, completion: nil)
    }
    
    func showPopNotification() {
        AppState.showPopNotification { [weak self] isAccept in
            DispatchQueue.main.async {
                self?.goMain()
            }
        }
    }
    
    func goMain() {
        
        UserDefaults.standard.set(userTypeSelected.rawValue, forKey: "userType")
        UserDefaults.standard.set(true, forKey: "isFromOnboarding")
        UserDefaults.standard.set(false, forKey: "checkAfterLogin")
        
        let user = UserDefaults.currentUser
        
        UserService.getDetailsForUser(userId: user?.uuid ?? "") { returnUser, error in
            if let returnUser = returnUser {
                var newUser = returnUser
                newUser.phone = user?.phone
                UserDefaults.currentUser = newUser
            }
            AppState.navigateToMainApp()
        }
    }
    
    //MARK: - IBActions -
    @IBAction func action_back(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func action_next(_ sender: Any) {
        if currentPosition.rawValue <= nbOfSteps {
            if currentPosition == .firstLastName {
//                OTLogger.logEvent(Action_Onboarding_Names)
            }
            
            if currentPosition == .phone {
                self.callSignup()
                return
            }
            
            if currentPosition == .passCode {
                if let pwd = temporaryPasscode, pwd.count == 6 {
                    self.sendPasscode()
                }
                else {
                    IHProgressHUD.showSuccesswithStatus(  "onboard_sms_no_pwd".localized)
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
            
            if currentPosition == .type {
                if self.userTypeSelected == .assos {
                    if currentPositionAsso == .none {
                        updateGoalType(isAsso: true)
                        return
                    }
                    if currentPositionAsso == .activity {
                        updateAssoActivity()
                        return
                    }
                    if currentPositionAsso == .fill {
                        updateAssoInfos()
                        return
                    }
                    
                    currentPositionAsso = ControllerAssoType(rawValue: currentPositionAsso.rawValue + 1)!
                    moveToTunnelAsso()
                    return
                }
                else {
                    updateGoalType(isAsso: false)
                    return
                }
            }
            
            currentPosition = ControllerType(rawValue: currentPosition.rawValue + 1)!
            changeController()
        }
    }
    
    @IBAction func action_previous(_ sender: Any) {
        if currentPosition.rawValue > 0 {
            if currentPosition == .type {
                if self.userTypeSelected == .assos {
                    if self.currentPositionAsso != .none {
                        currentPositionAsso = ControllerAssoType(rawValue: currentPositionAsso.rawValue - 1)!
                    }
                    moveToTunnelAsso()
                    return
                }
            }
            
            if currentPosition == .emailPwd {
                if self.userTypeSelected == .assos {
                    if self.currentPositionAsso != .none {
                        currentPosition = ControllerType(rawValue: currentPosition.rawValue - 2)!
                    }
                    moveToTunnelAsso()
                    return
                }
            }
            
            currentPosition = ControllerType(rawValue: currentPosition.rawValue - 1)!
            changeController()
        }
    }
    
    @IBAction func action_pass(_ sender: Any) {
        
        if currentPosition == .type {
            userTypeSelected = .none
//            OTLogger.logEvent(Action_Onboarding_Choose_Profile_Skip)
        }
        
        if currentPosition == .emailPwd {
            self.updateInfosAndShowPop()
            return
        }
        
        action_next(sender)
    }
}

//MARK: - Navigation -
extension OTOnboardingV2StartViewController {
    
    func changeController() {
        ui_bt_next.isEnabled = false
        
        self.hideBackButton(isHidden: true)
        
        switch currentPosition {
        case .firstLastName:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_names") as? OTOnboardingNamesViewController {
                vc.delegate = self
                vc.userFirstname = self.temporaryUser.firstname
                vc.userLastname = self.temporaryUser.lastname
                add(asChildViewController: vc)
            }
            self.hideBackButton(isHidden: false)
        case .phone:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_phone") as? OTOnboardingPhoneViewController {
                vc.delegate = self
                vc.countryCode = temporaryCountryCode
                vc.tempPhone = self.temporaryPhone
                vc.firstname = temporaryUser.firstname
                add(asChildViewController: vc)
            }
            self.hideBackButton(isHidden: false)
        case .passCode:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_code") as? OTOnboardingPassCodeViewController {
                vc.delegate = self
                vc.tempPhone = self.temporaryUser.phone!
                add(asChildViewController: vc)
            }
            self.hideBackButton(isHidden: true)
        case .type:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_type") as? OTOnboardingTypeViewController {
                vc.delegate = self
                vc.userTypeSelected = self.userTypeSelected
                vc.firstname = self.temporaryUser.firstname
                add(asChildViewController: vc)
                
                currentPositionAsso = .none
            }
            
        case .place:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_place") as? OTOnboardingPlaceViewController {
                vc.delegate = self
                vc.currentLocation = self.temporaryLocation
                vc.selectedPlace = self.temporaryGooglePlace
                vc.isSdf = userTypeSelected == .alone ? true : false
                vc.isSecondaryAddress = false
                add(asChildViewController: vc)
                
                currentPositionAlone = .none
                currentPositionNeighbour = .none
            }
        case .emailPwd:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_mail_pwd") as? OTOnboardingEmailPwdViewController {
                vc.delegate = self
                vc.tempEmail = self.temporaryEmail
                add(asChildViewController: vc)
            }
        }
        
        let percent = (ui_progress.bounds.size.width / CGFloat(nbOfSteps)) * CGFloat(currentPosition.rawValue)
        ui_progress.progressPercent = percent
        ui_progress.setNeedsDisplay()
        ui_label_position.attributedText = Utils.formatString(stringMessage: "0\(currentPosition.rawValue) / 0\(nbOfSteps)", coloredTxt: "0\(nbOfSteps)", color: UIColor.appOrange, colorHighlight: UIColor.appGrey165, fontSize: 24, fontWeight: .bold, fontColoredWeight: .bold)
        
        updatebuttons()
    }
    
    func hideBackButton(isHidden:Bool) {
        ui_button_back.isHidden = isHidden
        ui_image_back.isHidden = isHidden
    }
    
    func moveToTunnelAlone() {
        ui_bt_next.isEnabled = false
        switch currentPositionAlone {
        case .none:
            changeController()
        }
        
        let percent = (ui_progress.bounds.size.width / CGFloat(nbOfSteps + 1)) * CGFloat(Double(currentPositionAlone.rawValue) + Double(currentPosition.rawValue) * 0.95)
        ui_progress.progressPercent = percent
        ui_progress.setNeedsDisplay()
        
        updatebuttons()
    }
    
    func moveToTunnelNeighbour() {
        ui_bt_next.isEnabled = false
        
        switch currentPositionNeighbour {
        case .none:
            changeController()
        }
        
        let percent = (ui_progress.bounds.size.width / CGFloat(nbOfSteps + 1)) * CGFloat(Double(currentPositionNeighbour.rawValue) + Double(currentPosition.rawValue) * 0.95)
        ui_progress.progressPercent = percent
        ui_progress.setNeedsDisplay()
        
        updatebuttons()
    }
    
    func moveToTunnelAsso() {
        ui_bt_next.isEnabled = false
        
        switch currentPositionAsso {
        case .start:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_asso_start") as? OTOnboardingAssoStartViewController {
                add(asChildViewController: vc)
                ui_bt_next.isEnabled = true
            }
        case .info:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_asso_info") as? OTOnboardingAssoInfoViewController {
                add(asChildViewController: vc)
                ui_bt_next.isEnabled = true
            }
        case .fill:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_asso_fill") as? OTOnboardingAssoFillViewController {
                vc.delegate = self
                vc.asso = temporaryAssoInfo
                add(asChildViewController: vc)
            }
        case .activity:
            if let vc = storyboard?.instantiateViewController(withIdentifier: "Onboarding_asso_activity") as? OTOnboardingAssoActivityViewController {
                vc.delegate = self
                vc.activitiesSelections = temporaryAssoActivities
                vc.username = temporaryUser.firstname
                add(asChildViewController: vc)
            }
        case .none:
            changeController()
            return
        }
        
        let middleSize = ui_progress.bounds.size.width / 2
        let percent = middleSize + (middleSize / CGFloat(nbOfSteps)) * CGFloat(currentPositionAsso.rawValue)
        ui_progress.progressPercent = percent
        ui_progress.setNeedsDisplay()
        
        updatebuttons()
    }
    
    func updatebuttons() {
        ui_bt_pass.isHidden = true
        switch currentPosition {
        case .firstLastName:
            ui_bt_previous.isHidden = true
        case .type:
            if currentPositionAsso == .none && currentPositionAlone == .none && currentPositionNeighbour == .none {
                ui_bt_previous.isHidden = true
            }
            else {
                ui_bt_previous.isHidden = false
            }
        case .place:
            ui_bt_previous.isHidden = false
        case .emailPwd:
            ui_bt_previous.isHidden = false
            ui_bt_pass.isHidden = false
        case .phone,.passCode:
            ui_bt_previous.isHidden = false
        }
    }
    
    private func add(asChildViewController viewController: UIViewController) {
        if children.count > 0 {
            let oldChild = children[0]
            swapViewControllers(oldViewController: oldChild, toViewController: viewController)
            return;
        }
        
        if self.children.count > 0 {
            while children.count > 0 {
                remove(asChildViewController: children[0])
            }
        }
        
        addChild(viewController)
        
        ui_container.addSubview(viewController.view)
        
        viewController.view.frame = ui_container.bounds
        viewController.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        viewController.didMove(toParent: self)
    }
    
    private func remove(asChildViewController viewController: UIViewController) {
        
        viewController.willMove(toParent: nil)
        
        viewController.view.removeFromSuperview()
        
        viewController.removeFromParent()
    }
    
    func swapViewControllers(oldViewController: UIViewController, toViewController newViewController: UIViewController) {
        oldViewController.willMove(toParent: nil)
        newViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        self.addChild(newViewController)
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
    
    func goNextStepSdfNeighbour() {
        if self.userTypeSelected == .alone {
            self.currentPositionAlone = ControllerAloneType(rawValue: self.currentPositionAlone.rawValue + 1)!
            self.moveToTunnelAlone()
        }
        else {
            self.currentPositionNeighbour = ControllerNeighbourType(rawValue: self.currentPositionNeighbour.rawValue + 1)!
            self.moveToTunnelNeighbour()
        }
    }
}

//MARK: - Delegate -
extension OTOnboardingV2StartViewController: OnboardV2Delegate {
    
    func goNextManually() {
        self.action_next(self)
    }
    
    func goPreviousManually() {
        self.temporaryPhone = ""
        self.action_previous(self)
    }
    
    func updateButtonNext(isValid:Bool) {
        ui_bt_next.isEnabled = isValid ? true : false
    }
    
    func validateFirstLastname(firstName: String?, lastname: String?) {
        self.temporaryUser.firstname = firstName == nil ? "" : firstName!
        self.temporaryUser.lastname = lastname == nil ? "" : lastname!
    }
    
    func validatePhoneNumber(prefix: String, phoneNumber: String?) {
        if let _phone = phoneNumber {
            self.temporaryUser.phone = Utils.validatePhoneFormat(countryCode: prefix, phone: _phone)
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
    
    func updateNewAddress(googlePlace:GMSPlace?,gpsLocation:CLLocation?,addressName:String?) {
        
        self.temporaryGooglePlace = googlePlace
        self.temporaryLocation = gpsLocation
        self.temporaryAddressName = addressName
        
        
        if googlePlace != nil || gpsLocation != nil {
            updateButtonNext(isValid: true)
        }
        else {
            updateButtonNext(isValid: false)
        }
    }
    
    func updateUserType(userType: UserType) {
        self.userTypeSelected = userType
        //Reset infos Tunnel asso + place / email
        temporaryAssoInfo = nil
        temporaryAssoActivities?.reset()
        temporarySdfActivities?.reset()
        temporaryNeighbourActivities?.reset()
        temporaryEmail = ""
        temporaryLocation = nil
        temporaryAddressName = nil
        temporaryGooglePlace = nil
    }
    
    func updateEmailPwd(email:String,pwd:String,pwdConfirm:String) {
        self.temporaryEmail = email
        self.temporaryPassword = pwd
        self.temporaryPasswordConfirm = pwdConfirm
    }
    
    
    func updateAssoInfos(asso:Partner) {
        self.temporaryAssoInfo = asso
    }
    
    func updateAssoActivities(assoActivities: AssoActivities) {
        self.temporaryAssoActivities = assoActivities
    }
    
    func updateSdfActivities(sdfActivities: SdfNeighbourActivities) {
        self.temporarySdfActivities = sdfActivities
    }
    
    func updateNeighbourActivities(neighbourActivities: SdfNeighbourActivities) {
        self.temporaryNeighbourActivities = neighbourActivities
    }
}

//MARK: - Protocol -
protocol OnboardV2Delegate:AnyObject {
    func goNextManually()
    func goPreviousManually()
    func validateFirstLastname(firstName:String?,lastname:String?)
    func validatePhoneNumber(prefix:String,phoneNumber:String?)
    func updateButtonNext(isValid:Bool)
    func validatePasscode(password:String)
    func requestNewcode()
    func updateNewAddress(googlePlace:GMSPlace?,gpsLocation:CLLocation?,addressName:String?)
    func updateUserType(userType:UserType)
    func updateEmailPwd(email:String,pwd:String,pwdConfirm:String)
    
    func updateAssoInfos(asso:Partner)
    func updateAssoActivities(assoActivities:AssoActivities)
    func updateSdfActivities(sdfActivities:SdfNeighbourActivities)
    func updateNeighbourActivities(neighbourActivities:SdfNeighbourActivities)
}

//MARK: - Enums -
enum ControllerType:Int {
    case firstLastName = 1
    case phone = 2
    case passCode = 3
    case type = 4
    case place = 5
    case emailPwd = 6
}

enum ControllerAssoType:Int {
    case start = 1
    case info = 2
    case fill = 3
    case activity = 4
    case none = 0
}

enum ControllerNeighbourType:Int {
    case none = 0
}

enum ControllerAloneType:Int {
    case none = 0
}

enum UserType:Int {
    case neighbour = 1
    case alone = 2
    case assos = 3
    case none = 0
    
    func getGoalString() -> String {
        switch self {
        case .alone:
            return "ask_for_help"
        case .neighbour:
            return "offer_help"
        case .assos:
            return "organization"
        case .none:
            return ""
        }
    }
}

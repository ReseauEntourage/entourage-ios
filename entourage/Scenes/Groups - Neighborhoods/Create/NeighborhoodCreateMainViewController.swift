//
//  NeighborhoodMainViewController.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import UIKit
import CoreLocation
import GooglePlaces
import IHProgressHUD

class NeighborhoodCreateMainViewController: UIViewController {
    @IBOutlet weak var ui_page_control: MJCustomPageControl!
    
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_title_phase_nb: UILabel!
    @IBOutlet weak var ui_title_phase: UILabel!
    @IBOutlet weak var ui_main_container_view: UIView!
    @IBOutlet weak var ui_container_view: UIView!
    @IBOutlet weak var ui_bt_previous: UIButton!
    @IBOutlet weak var ui_bt_next: UIButton!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    weak var parentDelegate:UserProfileDetailDelegate? = nil
    
    var pageViewController:NeighborhoodCreatePageViewController? = nil
    
    var newNeighborhood = Neighborhood()
    var newInterestTagOtherMessage:String? = nil
    var newTags:Tags? = nil
    
    var currentPhasePosition = 1
    
    weak var parentController:UIViewController? = nil // Use to open the ending screen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        ui_title_phase.font = ApplicationTheme.getFontNunitoBold(size: 24)
        ui_title_phase.textColor = .black
        ui_title_phase_nb.font = ApplicationTheme.getFontNunitoBold(size: 24)
        ui_title_phase_nb.textColor = .appOrangeLight
        
        ui_title_phase.text = "neighborhood_create_title_phase".localized
        ui_bt_previous.isHidden = true
        ui_page_control.numberOfPages = 3
        ui_page_control.currentPage = 0
        
        ui_bt_previous.layer.cornerRadius = ui_bt_previous.frame.height / 2
        ui_bt_previous.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_previous.layer.borderWidth = 1
        ui_bt_previous.backgroundColor = .clear
        ui_bt_previous.setTitleColor(.appOrange, for: .normal)
        ui_bt_previous.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 18)
        ui_bt_previous.setTitle("neighborhood_create_group_bt_back".localized, for: .normal)
        
        ui_bt_next.layer.cornerRadius = ui_bt_next.frame.height / 2
        ui_bt_next.backgroundColor = .appOrangeLight
        ui_bt_next.setTitleColor(.white, for: .normal)
        ui_bt_next.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 18)
        ui_bt_next.setTitle("neighborhood_create_group_bt_next".localized, for: .normal)
        
        enableDisableNextButton(isEnable: false) //TODO: remettre false
        
        ui_main_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        self.modalPresentationStyle = .fullScreen
        
        ui_top_view.populateCustom(title: "neighborhood_create_group_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 24), titleColor: .white, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? NeighborhoodCreatePageViewController {
            self.pageViewController = vc
            self.pageViewController?.parentDelegate = self
        }
    }
    
    func showError(message:String) {
        ui_error_view.changeTitleAndImage(title: message)
        ui_error_view.show()
    }
    
    //MARK: - Navigation -
    
    @IBAction func action_next(_ sender: Any) {
        let isValid = checkValidation()
        if isValid.isValid {
            goPageNext()
        }
        else {
            if currentPhasePosition == 2 {
                NotificationCenter.default.post(Notification(name: NSNotification.Name(kNotificationNeighborhoodCreatePhase2Error), object: nil, userInfo: ["error_message":isValid.message]))
            }
            else {
                showError(message: isValid.message)
            }
        }
    }
    
    @IBAction func action_back(_ sender: Any) {
        goPageBack()
    }
    
    func goPageNext() {
        currentPhasePosition = currentPhasePosition + 1
        if currentPhasePosition > ui_page_control.numberOfPages {
            currentPhasePosition = ui_page_control.numberOfPages
            self.createGroup()
        }
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
        ui_title_phase_nb.text = String.init(format: "neighborhood_create_title_phase_nb".localized,currentPhasePosition)
        
        ui_bt_next.setTitle("neighborhood_create_group_bt_next".localized, for: .normal)
        switch currentPhasePosition {
        case 1:
            ui_bt_previous.isHidden = true
            ui_bt_next.isHidden = false
        case 2:
            ui_bt_previous.isHidden = false
            ui_bt_next.isHidden = false
        case 3:
            ui_bt_previous.isHidden = false
            ui_bt_next.isHidden = false
            ui_bt_next.setTitle("neighborhood_create_group_bt_create".localized, for: .normal)
        default:
            break
        }
        _ = checkValidation()
    }
    
    func enableDisableNextButton(isEnable:Bool) {
        if isEnable {
            // ui_bt_next.isEnabled = true
            ui_bt_next.alpha = 1.0
        }
        else {
            // ui_bt_next.isEnabled = false
            ui_bt_next.alpha = 0.4
        }
    }
    
    //MARK: - Network -
    func createGroup() {
        IHProgressHUD.show()
        NeighborhoodService.createNeighborhood(group: newNeighborhood) { group, error in
            Logger.print("***** groupe crée ? \(group) error: ? \(error)")
            IHProgressHUD.dismiss()
            if group != nil {
                self.goEnd()
            }
            else {
                IHProgressHUD.showError(withStatus: "Erreur lors de la création du groupe. PLACEHOLDER")
            }
        }
    }
    
    private func goEnd() {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "neighb_validateVC") {
            vc.modalPresentationStyle = .fullScreen
            self.dismiss(animated: false) {
                self.parentController?.present(vc, animated: true)
            }
        }
    }
}

//MARK: - NeighborhoodCreateMainDelegate -
extension NeighborhoodCreateMainViewController: NeighborhoodCreateMainDelegate {
    func addGroupName(_ title: String) {
        newNeighborhood.name = title
        _ = checkValidation()
    }
    
    func addGroupDescription(_ about: String?) {
        newNeighborhood.aboutGroup = about
    }
    
    func addGroupPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        if let currentlocation = currentlocation {
//            newNeighborhood.latitude = currentlocation.latitude
//            newNeighborhood.longitude = currentlocation.longitude
            let location = CLLocation(latitude: currentlocation.latitude, longitude: currentlocation.longitude)
            newNeighborhood.address = Address(displayAddress: currentLocationName, location: location)
        }
        else if let googlePlace = googlePlace {
            let location = CLLocation(latitude: googlePlace.coordinate.latitude, longitude: googlePlace.coordinate.longitude)
            newNeighborhood.address = Address(displayAddress: googlePlace.name, location: location)
        }
        _ = checkValidation()
    }
    
    func addGroupInterests(tags:Tags?, messageOther:String?) {
        newInterestTagOtherMessage = messageOther
        guard let tags = tags else {
            _ = checkValidation()
            return
        }
        newTags = tags
        newNeighborhood.interests = [String]()
        newNeighborhood.tagOtherMessage = newInterestTagOtherMessage
        for tag in tags.getTags() {
            if tag.isSelected {
                newNeighborhood.interests?.append(tag.key)
            }
        }
        let validation = checkValidation()
        
        if validation.isValid {
            NotificationCenter.default.post(Notification(name: NSNotification.Name(kNotificationNeighborhoodCreatePhase2Error), object: nil, userInfo:nil))
        }
    }
    
    func checkValidation() -> (isValid:Bool, message:String) {
        var isValid = false
        var message = ""
        
        switch currentPhasePosition {
        case 1:
            if newNeighborhood.name.count >= 2 && (newNeighborhood.address?.location?.coordinate.latitude ?? 0 != 0)  {
                isValid = true
            }
            message = "neighborhoodCreatePhase1_error".localized
        case 2:
            message = "neighborhoodCreatePhase2_error".localized
            if newNeighborhood.interests?.count ?? 0 > 0 {
                isValid = true
                if let _others = newTags?.getTags() {
                    for tag in _others {
                        if tag.key == Tag.tagOther && tag.isSelected {
                            if self.newInterestTagOtherMessage?.count ?? 0 >= ApplicationTheme.minOthersCatChars {
                                isValid = true
                            }
                            else {
                                message = "neighborhoodCreatePhase2_others_error".localized
                                isValid = false
                            }
                            break
                        }
                    }
                }
            }
        case 3:
            if newNeighborhood.neighborhood_image_id != nil {
                isValid = true
            }
            message = "neighborhoodCreatePhase3_error".localized
        default:
            break
        }
        enableDisableNextButton(isEnable: isValid)
        
        return (isValid,message)
    }
    
    func showChoosePhotos(delegate:ChoosePictureNeighborhoodDelegate) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "neighborhoodChoosePhotoVC") as? NeighborhoodChoosePictureViewController {
            
            vc.delegate = delegate
            self.present(vc, animated: true)
        }
    }
    
    func addGroupPhoto(image: NeighborhoodImage) {
        newNeighborhood.neighborhood_image_id = image.uid
        _ = checkValidation()
    }
    
    func addGroupWelcome(message: String?) {
        newNeighborhood.welcomeMessage = message
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodCreateMainViewController: MJNavBackViewDelegate {
    func goBack() {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "neighborhoodCreatePopCloseBackCancel".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "neighborhoodCreatePopCloseBackQuit".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrangeLight_50, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: "neighborhoodCreatePopCloseBackTitle".localized, message: "neighborhoodCreatePopCloseBackMessage".localized, buttonrightType: buttonCancel, buttonLeftType: buttonValidate, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true, parentVC: self)
        
        alertVC.delegate = self
        alertVC.show()
    }
}

//MARK: - MJAlertControllerDelegate -
extension NeighborhoodCreateMainViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
        self.dismiss(animated: true)
    }
    func validateRightButton(alertTag: MJAlertTAG) {}
}

//MARK: - Protocol NeighborhoodCreateMainDelegate -
protocol NeighborhoodCreateMainDelegate: AnyObject {
    //Phase 1
    func addGroupName(_ title:String)
    func addGroupDescription(_ about:String?)
    func addGroupPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?)
    //Phase 2
    func addGroupInterests(tags:Tags?, messageOther:String?)
    //Phase 3
    func showChoosePhotos(delegate:ChoosePictureNeighborhoodDelegate)
    func addGroupPhoto(image:NeighborhoodImage)
    func addGroupWelcome(message:String?)
}

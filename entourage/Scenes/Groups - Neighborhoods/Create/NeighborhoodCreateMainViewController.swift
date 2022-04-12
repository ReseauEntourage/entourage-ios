//
//  NeighborhoodMainViewController.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import UIKit
import CoreLocation
import GooglePlaces

class NeighborhoodCreateMainViewController: UIViewController {
    @IBOutlet weak var ui_page_control: MJCustomPageControl!
    
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
    
    var currentPhasePosition = 1
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
    
    @IBAction func action_next(_ sender: Any) {
        goPageNext()
    }
    
    @IBAction func action_back(_ sender: Any) {
        goPageBack()
    }
    
    func goPageNext() {
        currentPhasePosition = currentPhasePosition + 1
        if currentPhasePosition > ui_page_control.numberOfPages {
            currentPhasePosition = ui_page_control.numberOfPages
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
        checkValidation()
    }
    
    func enableDisableNextButton(isEnable:Bool) {
        if isEnable {
            ui_bt_next.isEnabled = true
            ui_bt_next.alpha = 1.0
        }
        else {
            ui_bt_next.isEnabled = false
            ui_bt_next.alpha = 0.4
        }
    }
}

//MARK: - NeighborhoodCreateMainDelegate -
extension NeighborhoodCreateMainViewController: NeighborhoodCreateMainDelegate {
    func addGroupName(_ title: String) {
        Logger.print("***** add Name : \(title)")
        newNeighborhood.name = title
       checkValidation()
    }
    
    func addGroupDescription(_ about: String?) {
        Logger.print("***** add description : \(about)")
        newNeighborhood.aboutGroup = about
    }
    
    func addGroupPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        //TODO: Recup datas
        if let currentlocation = currentlocation {
            newNeighborhood.latitude = currentlocation.latitude
            newNeighborhood.longitude = currentlocation.longitude
            let location = CLLocation(latitude: currentlocation.latitude, longitude: currentlocation.longitude)
            newNeighborhood.address = Address(displayAddress: currentLocationName, location: location)
        }
        else if let googlePlace = googlePlace {
            let location = CLLocation(latitude: googlePlace.coordinate.latitude, longitude: googlePlace.coordinate.longitude)
            newNeighborhood.address = Address(displayAddress: googlePlace.name, location: location)
        }
        
        Logger.print("***** add place : \(currentLocationName) - \(googlePlace)")
        checkValidation()

    }
    
    func addGroupInterests(tags:Tags?, messageOther:String?) {
        newInterestTagOtherMessage = messageOther
        Logger.print("***** add group interest : \(tags) - Message ? \(messageOther)")
        guard let tags = tags else {
            checkValidation()
            return
        }
        newNeighborhood.interests = [String]()
        for tag in tags.getTags() {
            if tag.isSelected {
                newNeighborhood.interests?.append(tag.key)
            }
        }
        checkValidation()
    }
    
    
    func checkValidation() {
        //TODO: Check + update bouton suivant avec pos + titre mandatory
        var isValid = false
        
        switch currentPhasePosition {
        case 1:
            
            isValid = false
            
            if newNeighborhood.name.count >= 2 && (newNeighborhood.address?.location?.coordinate.latitude ?? 0 != 0)  {
                isValid = true
            }
        case 2:
            if newNeighborhood.interests?.count ?? 0 > 0 {
                isValid = true
            }
        case 3:
            if newNeighborhood.neighborhood_image_id != nil {
                isValid = true
            }
        default:
            break
        }
        enableDisableNextButton(isEnable: isValid)
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodCreateMainViewController: MJNavBackViewDelegate {
    func goBack() {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "neighborhoodCreatePopCloseBackCancel".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "neighborhoodCreatePopCloseBackQuit".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrangeLight, cornerRadius: -1)
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
    func addGroupPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?)//TODO: passer gplace + geoloc + name ?
    
    func addGroupInterests(tags:Tags?, messageOther:String?)
}

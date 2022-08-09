//
//  ActionCreateMainViewController.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import UIKit
import CoreLocation
import GooglePlaces
import IHProgressHUD

class ActionCreateMainViewController: UIViewController {
    
    @IBOutlet weak var ui_page_control: MJCustomPageControl!
    
    @IBOutlet weak var ui_error_view: MJErrorInputView!
    @IBOutlet weak var ui_title_phase_nb: UILabel!
    @IBOutlet weak var ui_title_phase: UILabel!
    @IBOutlet weak var ui_main_container_view: UIView!
    @IBOutlet weak var ui_container_view: UIView!
    @IBOutlet weak var ui_bt_previous: UIButton!
    @IBOutlet weak var ui_bt_next: UIButton!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    @IBOutlet weak var ui_view_charte: UIView!
    @IBOutlet weak var ui_tableview_charte: UITableView!
    @IBOutlet weak var ui_button_validate_charte: UIButton!
    
    var arrayDesc = [String]()
    var arrayTitle = [String]()
    
    var currentPhasePosition = 1
    
    var pageViewController:ActionCreatePageViewController? = nil
    weak var parentController:UIViewController? = nil // Use to open the ending screen
    
    var isContrib:Bool = false
    
    var newAction = Action()
    var newImage:UIImage? = nil
    var newSection:Section? = nil
    
    var actionTitle = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        actionTitle = isContrib ? "action_create_title_contrib".localized : "action_create_title_solicitation".localized
        
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        ui_title_phase.font = ApplicationTheme.getFontNunitoBold(size: 24)
        ui_title_phase.textColor = .black
        ui_title_phase_nb.font = ApplicationTheme.getFontNunitoBold(size: 24)
        ui_title_phase_nb.textColor = .appOrangeLight
        
        ui_title_phase.text = "action_create_title_phase".localized
        ui_bt_previous.isHidden = true
        
        ui_page_control.numberOfPages = 3
        ui_page_control.currentPage = 0
        
        ui_bt_previous.layer.cornerRadius = ui_bt_previous.frame.height / 2
        ui_bt_previous.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_previous.layer.borderWidth = 1
        ui_bt_previous.backgroundColor = .clear
        ui_bt_previous.setTitleColor(.appOrange, for: .normal)
        ui_bt_previous.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_bt_previous.setTitle("action_create_group_bt_back".localized, for: .normal)
        
        ui_bt_next.layer.cornerRadius = ui_bt_next.frame.height / 2
        ui_bt_next.backgroundColor = .appOrangeLight
        ui_bt_next.setTitleColor(.appOrange, for: .normal)
        ui_bt_next.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_bt_next.setTitle("action_create_group_bt_next".localized, for: .normal)
        
        enableDisableNextButton(isEnable: false)
        
        ui_main_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        self.modalPresentationStyle = .fullScreen
        
        ui_top_view.populateCustom(title: "action_charte_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 24), titleColor: .white, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
        
        //Charte
        ui_view_charte.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_button_validate_charte.layer.cornerRadius = ui_bt_previous.frame.height / 2
        ui_button_validate_charte.layer.borderColor = UIColor.appOrange.cgColor
        ui_button_validate_charte.layer.borderWidth = 1
        ui_button_validate_charte.backgroundColor = .appOrange
        ui_button_validate_charte.setTitleColor(.white, for: .normal)
        ui_button_validate_charte.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_button_validate_charte.setTitle("accept_charte".localized, for: .normal)
        
        arrayDesc = ["action_charte_1".localized,"action_charte_2".localized,
                     "action_charte_3".localized,"action_charte_4".localized,"action_charte_5".localized]
        
        arrayTitle = ["action_charte_1_title".localized,"action_charte_2_title".localized,
                      "action_charte_3_title".localized,"action_charte_4_title".localized,"action_charte_5_title".localized]
        ui_tableview_charte.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_tableview_charte.delegate = self
        ui_tableview_charte.dataSource = self
    }
    
    //MARK: - Network -
    func createAction() {
        newAction.sectionName = newSection?.key
        IHProgressHUD.show()
        
        if isContrib {
            if let newImage = newImage {
                ContribUploadPictureService.prepareUploadWith(image: newImage, action: newAction, isUpdate: false) { action, isOk in
                    IHProgressHUD.dismiss()
                    if let action = action {
                        self.goEnd(action: action)
                    }
                    else {
                        self.showError()
                    }
                }
            }
            else {
                ActionsService.createAction(isContrib: true, action: newAction) { action, error in
                    IHProgressHUD.dismiss()
                    if let action = action {
                        self.goEnd(action: action)
                    }
                    else {
                        self.showError()
                    }
                }
            }
        }
        else {
            ActionsService.createAction(isContrib: false, action: newAction) { action, error in
                IHProgressHUD.dismiss()
                if let action = action {
                    self.goEnd(action: action)
                }
                else {
                    self.showError()
                }
            }
        }
    }
    
    private func showError() {
        let _type:String = self.isContrib ? "action_contrib".localized : "action_solicitation".localized
        let error = String.init(format: "action_create_contrib_nok".localized, _type)
        IHProgressHUD.showError(withStatus: error)
    }
    
    //MARK: - IBActions -
    @IBAction func action_next(_ sender: Any) {
        let isValid = checkValidation()
        if isValid.isValid {
            goPageNext()
        }
        else {
            if currentPhasePosition == 4 {
                NotificationCenter.default.post(Notification(name: NSNotification.Name(kNotificationEventCreatePhase4Error), object: nil, userInfo: ["error_message":isValid.message]))
            }
            else if currentPhasePosition == 5 {
                NotificationCenter.default.post(Notification(name: NSNotification.Name(kNotificationEventCreatePhase5Error), object: nil, userInfo: ["error_message":isValid.message]))
            }
            else {
                showError(message: isValid.message)
            }
        }
    }
    
    @IBAction func action_back(_ sender: Any) {
        goPageBack()
    }
    
    @IBAction func action_validate_charte(_ sender: Any) {
        ui_view_charte.isHidden = true
        ui_top_view.updateTitle(title: actionTitle)
    }
    
    //MARK: - NAv -
    private func goPageNext() {
        currentPhasePosition = currentPhasePosition + 1
        if currentPhasePosition > ui_page_control.numberOfPages {
            currentPhasePosition = ui_page_control.numberOfPages
            self.createAction()
        }
        updateViewsForPosition()
    }
    
    private func goPageBack() {
        currentPhasePosition = currentPhasePosition - 1
        if currentPhasePosition < 1 {
            currentPhasePosition = 1
        }
        
        updateViewsForPosition()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? ActionCreatePageViewController {
            self.pageViewController = vc
            self.pageViewController?.parentDelegate = self
        }
    }
    
    private func showError(message:String) {
        ui_error_view.changeTitleAndImage(title: message)
        ui_error_view.show()
    }
    
    private func goEnd(action:Action) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationActionCreateEnd), object: nil)
        if let vc = storyboard?.instantiateViewController(withIdentifier: "action_validateVC") as? ActionCreateValidateViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.actionId = action.id
            vc.isContrib = isContrib
            self.dismiss(animated: false) {
                self.parentController?.present(vc, animated: true)
            }
        }
    }
    
    //MARK: - Checks -
    func checkValidation() -> (isValid:Bool, message:String) {
        var isValid = false
        var message = ""
        
        switch currentPhasePosition {
        case 1:
            //Check name / desc
            if newAction.title?.count ?? 0 >= 2 && newAction.description?.count ?? 0 > 2 {
                isValid = true
            }
            
            message = "actionCreatePhase1_error".localized
        case 2: //Check interests
            if let _ = newSection {
                isValid = true
            }
            message = "actionCreatePhase2_error".localized
        case 3: //address
            
            if newAction.location?.latitude ?? 0 != 0 {
                isValid = true
            }
            message = "actionCreatePhase3_error".localized
            
        default:
            break
        }
        enableDisableNextButton(isEnable: isValid)
        
        return (isValid,message)
    }
    
    private func updateViewsForPosition() {
        pageViewController?.goPagePosition(position: currentPhasePosition)
        ui_page_control.currentPage = currentPhasePosition - 1
        ui_title_phase_nb.text = String.init(format: "action_create_title_phase_nb".localized,currentPhasePosition)
        
        ui_bt_next.setTitle("action_create_group_bt_next".localized, for: .normal)
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
            ui_bt_next.setTitle("action_create_group_bt_create".localized, for: .normal)
        default:
            break
        }
        _ = checkValidation()
    }
    
    private func enableDisableNextButton(isEnable:Bool) {
        if isEnable {
            ui_bt_next.backgroundColor = .appOrangeLight.withAlphaComponent(0.5)
            ui_bt_next.alpha = 1.0
        }
        else {
            ui_bt_next.backgroundColor = .appOrangeLight
            ui_bt_next.alpha = 0.4
        }
    }
    
    func hasNoInput() -> Bool {
        return newAction.title?.count ?? 0 == 0 && newAction.description?.count ?? 0 == 0 //&& newImage == nil
    }
}

//MARK: - ActionCreateMainDelegate -
extension ActionCreateMainViewController: ActionCreateMainDelegate {
    //Phase 1
    func addTitle(_ title:String) {
        newAction.title = title
        _ = checkValidation()
    }
    func addDescription(_ about:String?) {
        newAction.description = about
        _ = checkValidation()
    }
    func addPhoto(image:UIImage?) {
        newImage = image
        _ = checkValidation()
    }
    
    //Phase 2
    func addInterest(section:Section) {
        newSection = section
        _ = checkValidation()
    }
    
    //Phase 3
    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        if let currentlocation = currentlocation {
            newAction.location = EventLocation(latitude: currentlocation.latitude, longitude: currentlocation.longitude)
        }
        else if let googlePlace = googlePlace {
            newAction.location = EventLocation(latitude: googlePlace.coordinate.latitude, longitude: googlePlace.coordinate.longitude)
        }
        _ = checkValidation()
    }
    
    func isContribution() -> Bool {
        return isContrib
    }
    
    func isEdit() -> Bool { return false }
    func getCurrentAction() -> Action? { return nil }
}

//MARK: - MJNavBackViewDelegate -
extension ActionCreateMainViewController: MJNavBackViewDelegate {
    func goBack() {
        
        if hasNoInput() {
            self.dismiss(animated: true)
            return
        }
        
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "actionCreatePopCloseBackCancel".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "actionCreatePopCloseBackQuit".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrangeLight_50, cornerRadius: -1)
        let message = String.init(format: "actionCreatePopCloseBackMessage".localized, isContrib ? "action_contrib".localized : "action_solicitation".localized)
        alertVC.configureAlert(alertTitle: "actionCreatePopCloseBackTitle".localized, message: message, buttonrightType: buttonCancel, buttonLeftType: buttonValidate, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true, parentVC: self)
        alertVC.delegate = self
        alertVC.show()
    }
}

//MARK: - MJAlertControllerDelegate -
extension ActionCreateMainViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
        self.dismiss(animated: true)
    }
    func validateRightButton(alertTag: MJAlertTAG) {}
}

//MARK: - Protocol TableView DataSource/delegate -
extension ActionCreateMainViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrayDesc.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodCguCell
        
        cell.populateCell(title: arrayTitle[indexPath.row], description: arrayDesc[indexPath.row], position: indexPath.row + 1)
        
        return cell
    }
}

//MARK: - Protocol EventCreateMainDelegate -
protocol ActionCreateMainDelegate: AnyObject {
    
    func addTitle(_ title:String)
    func addDescription(_ about:String?)
    func addPhoto(image:UIImage?)
    
    func addInterest(section:Section)
    
    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?)
    
    func isContribution() -> Bool
    
    func isEdit() -> Bool
    func getCurrentAction() -> Action?
}

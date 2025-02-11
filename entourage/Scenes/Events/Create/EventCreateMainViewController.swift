//
//  EventCreateMainViewController.swift
//  entourage
//
//  Created by Jerome on 21/06/2022.
//

import UIKit
import CoreLocation
import GooglePlaces
import IHProgressHUD

class EventCreateMainViewController: UIViewController {
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
    
    var pageViewController:EventCreatePageViewController? = nil
    
    var newEvent = Event()
    var newInterestTagOtherMessage:String? = nil
    var newTags:Tags? = nil
    var isGroupSharing = false
    var hasPlaceLimit = false
    
    var currentPhasePosition = 1
    
    var currentNeighborhoodId:Int? = nil
    
    weak var parentController:UIViewController? = nil // Use to open the ending screen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        newEvent.metadata = EventMetadata()
        
        ui_error_view.populateView(backgroundColor: .white.withAlphaComponent(0.6))
        ui_error_view.hide()
        
        ui_title_phase.font = ApplicationTheme.getFontNunitoBold(size: 24)
        ui_title_phase.textColor = .black
        ui_title_phase_nb.font = ApplicationTheme.getFontNunitoBold(size: 24)
        ui_title_phase_nb.textColor = .appOrangeLight
        
        ui_title_phase.text = "event_create_title_phase".localized
        ui_bt_previous.isHidden = true
        ui_page_control.numberOfPages = 5
        ui_page_control.currentPage = 0
        
        ui_bt_previous.layer.cornerRadius = ui_bt_previous.frame.height / 2
        ui_bt_previous.layer.borderColor = UIColor.appOrange.cgColor
        ui_bt_previous.layer.borderWidth = 1
        ui_bt_previous.backgroundColor = .clear
        ui_bt_previous.setTitleColor(.appOrange, for: .normal)
        ui_bt_previous.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_bt_previous.setTitle("event_create_group_bt_back".localized, for: .normal)
        configureWhiteButton(ui_bt_previous, withTitle: "event_create_group_bt_back".localized)
        
        ui_bt_next.layer.cornerRadius = ui_bt_next.frame.height / 2
        ui_bt_next.backgroundColor = .appOrangeLight
        ui_bt_next.setTitleColor(.appOrange, for: .normal)
        ui_bt_next.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_bt_next.setTitle("event_create_group_bt_next".localized, for: .normal)
        configureOrangeButton(ui_bt_next, withTitle: "event_create_group_bt_next".localized)
        
        enableDisableNextButton(isEnable: false) //TODO: remettre false
        
        ui_main_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        self.modalPresentationStyle = .fullScreen
        
        ui_top_view.populateCustom(title: "event_create_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 24), titleColor: .white, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
    }
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
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EventCreatePageViewController {
            self.pageViewController = vc
            self.pageViewController?.parentDelegate = self
            self.pageViewController?.isCreating = true
        }
    }
    
    private func showError(message:String) {
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
    
    private func goPageNext() {
        currentPhasePosition = currentPhasePosition + 1
        if currentPhasePosition > ui_page_control.numberOfPages {
            currentPhasePosition = ui_page_control.numberOfPages
            self.createEvent()
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
    
    private func updateViewsForPosition() {
        pageViewController?.goPagePosition(position: currentPhasePosition)
        ui_page_control.currentPage = currentPhasePosition - 1
        ui_title_phase_nb.text = String.init(format: "event_create_title_phase_nb".localized,currentPhasePosition)
        
        ui_bt_next.setTitle("event_create_group_bt_next".localized, for: .normal)
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
        case 4:
            ui_bt_previous.isHidden = false
            ui_bt_next.isHidden = false
        case 5:
            ui_bt_previous.isHidden = false
            ui_bt_next.isHidden = false
            ui_bt_next.setTitle("event_create_group_bt_create".localized, for: .normal)
        default:
            break
        }
        _ = checkValidation()
    }
    
    private func enableDisableNextButton(isEnable:Bool) {
        if isEnable {
            ui_bt_next.backgroundColor = .appOrange
            ui_bt_next.alpha = 1.0
        }
        else {
            ui_bt_next.backgroundColor = .appOrange
            ui_bt_next.alpha = 0.4
        }
    }
    
    //MARK: - Network -
    private func createEvent() {
        IHProgressHUD.show()
        Logger.print("***** createEvent \(newEvent.dictionaryForWS())")
        EventService.createEvent(event: newEvent) { event, error in
            IHProgressHUD.dismiss()
            if event != nil {
                self.goEnd(event: event!)
            }else {
                IHProgressHUD.showError(withStatus: "event_create_ok".localized)
            }
        }
    }
    
    private func goEnd(event:Event) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventCreateEnd), object: nil)
        if let vc = storyboard?.instantiateViewController(withIdentifier: "event_validateVC") as? EventCreateValidateViewController {
            AnalyticsLoggerManager.logEvent(name: Event_create_end)
            vc.modalPresentationStyle = .fullScreen
            vc.eventId = event.uid
            self.dismiss(animated: false) {
                self.parentController?.present(vc, animated: true)
            }
        }
    }
}

//MARK: - EventCreateMainDelegate -
extension EventCreateMainViewController: EventCreateMainDelegate {
    //Phase 1
    func addTitle(_ title: String) {
        newEvent.title = title
        _ = checkValidation()
    }
    
    func addDescription(_ about: String?) {
        newEvent.descriptionEvent = about
        _ = checkValidation()
    }
    
    func addPhoto(image: EventImage) {
        newEvent.imageId = image.id
        _ = checkValidation()
    }
    
    func showChooseImage(delegate:ChoosePictureEventDelegate) {
        if let vc = storyboard?.instantiateViewController(withIdentifier: "eventChoosePhotoVC") as? EventChoosePictureViewController {
            
            vc.delegate = delegate
            self.present(vc, animated: true)
        }
    }
    
    //Phase 2
    func addDateStart(dateStart:Date?) {
        newEvent.startDate = dateStart
        _ = checkValidation()
    }
    func addDateEnd(dateEnd:Date?) {
        newEvent.endDate = dateEnd
        _ = checkValidation()
    }
    func addRecurrence(recurrence:EventRecurrence) {
        newEvent.recurrence = recurrence
        _ = checkValidation()
    }
    
    //Phase 3
    func addPlaceType(isOnline:Bool) {
        newEvent.isOnline = isOnline
        _ = checkValidation()
    }
    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        newEvent.onlineEventUrl = nil
        if let currentlocation = currentlocation {
            newEvent.location = EventLocation(latitude: currentlocation.latitude, longitude: currentlocation.longitude)
            newEvent.addressName = currentLocationName
        }
        else if let googlePlace = googlePlace {
            newEvent.location = EventLocation(latitude: googlePlace.coordinate.latitude, longitude:  googlePlace.coordinate.longitude)
            newEvent.addressName = googlePlace.name
            newEvent.metadata?.google_place_id = googlePlace.placeID
        }
        _ = checkValidation()
    }
    
    func addOnline(url:String?) {
        newEvent.onlineEventUrl = url
        _ = checkValidation()
    }
    func addPlaceLimit(hasLimit:Bool, nbPlaces:Int) {
        if newEvent.metadata == nil {
            newEvent.metadata = EventMetadata()
        }
        hasPlaceLimit = hasLimit
        newEvent.metadata?.place_limit = nbPlaces
        _ = checkValidation()
    }
    
    //Phase 4
    func addInterests(tags:Tags?, messageOther:String?) {
        newInterestTagOtherMessage = messageOther
        guard let tags = tags else {
            _ = checkValidation()
            return
        }
        newTags = tags
        newEvent.interests = [String]()
        newEvent.tagOtherMessage = newInterestTagOtherMessage
        for tag in tags.getTags() {
            if tag.isSelected {
                newEvent.interests?.append(tag.key)
            }
        }
        let validation = checkValidation()
        
        if validation.isValid {
            NotificationCenter.default.post(Notification(name: NSNotification.Name(kNotificationEventCreatePhase4Error), object: nil, userInfo:nil))
        }
    }
    
    //Phase 5
    func addShare(_ isSharing:Bool) {
        self.isGroupSharing = isSharing
        _ = checkValidation()
    }
    func addShareGroups(groups:[EventNeighborhood]?) {
        if let groups = groups {
            newEvent.neighborhoods = [EventNeighborhood]()
            newEvent.neighborhoods?.append(contentsOf: groups)
        }
        else {
            newEvent.neighborhoods = [EventNeighborhood]()
        }
        _ = checkValidation()
    }

    func getNeighborhoodId() -> Int? {
        return currentNeighborhoodId
    }
    
    //Non used here
    func isEdit() -> Bool { return false }
    func getCurrentEvent() -> Event? { return nil }
    func setDateChanged() { }
    func hasCurrentRecurrency() -> Bool {return false}
    
    //MARK: - Checks -
    func checkValidation() -> (isValid:Bool, message:String) {
        var isValid = false
        var message = ""
        
        switch currentPhasePosition {
        case 1:
            //Check name / desc + img
            if newEvent.title.count >= 2 && newEvent.descriptionEvent?.count ?? 0 > 2 && newEvent.imageId != nil {
                isValid = true
            }
            message = "eventCreatePhase1_error".localized
        case 2: //check date start/end
            message = "eventCreatePhase2_error".localized
            
            if newEvent.startDate != nil && newEvent.endDate != nil {
                isValid = true
            }
        case 3: //Check online + url || !online + address + limit place + nb
            if newEvent.isOnline ?? false {
                if newEvent.onlineEventUrl != nil {
                    isValid = true
                }
            }
            else {
                Logger.print("***** Event create not online \(newEvent.metadata)")
                if let meta = newEvent.metadata {
                    var isValidFromLimit = false
                    if hasPlaceLimit ?? false {
                        if meta.place_limit ?? 0 > 0 {
                            isValidFromLimit = true
                        }
                    }
                    else {
                        isValidFromLimit = true
                    }
                    
                    if ((newEvent.location?.latitude ?? 0 != 0) || meta.google_place_id != nil) && isValidFromLimit {
                        isValid = true
                    }
                }
            }
            message = "eventCreatePhase3_error".localized
        case 4: //Check interests
            if newEvent.interests?.count ?? 0 > 0 {
                isValid = true
                if let _others = newTags?.getTags() {
                    for tag in _others {
                        if tag.key == Tag.tagOther && tag.isSelected {
                            if self.newInterestTagOtherMessage?.count ?? 0 >= ApplicationTheme.minOthersCatChars {
                                isValid = true
                            }
                            else {
                                isValid = false
                            }
                            break
                        }
                    }
                }
            }
            message = "eventCreatePhase4_error".localized
        case 5:
            if isGroupSharing {
                
                if newEvent.neighborhoods?.count ?? 0 > 0 {
                    isValid = true
                }
            }
            else {
                isValid = true
            }
            
            message = "eventCreatePhase5_error".localized
        default:
            break
        }
        enableDisableNextButton(isEnable: isValid)
        
        return (isValid,message)
    }
    
    func hasNoInput() -> Bool {
        return newEvent.title.count == 0 && newEvent.descriptionEvent?.count ?? 0 == 0 && newEvent.imageId == nil
    }
}

//MARK: - MJNavBackViewDelegate -
extension EventCreateMainViewController: MJNavBackViewDelegate {
    func goBack() {
        
        if hasNoInput() {
            self.dismiss(animated: true)
            return
        }
        
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "eventCreatePopCloseBackCancel".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "eventCreatePopCloseBackQuit".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: "eventCreatePopCloseBackTitle".localized, message: "eventCreatePopCloseBackMessage".localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        alertVC.delegate = self
        alertVC.show()
    }
}

//MARK: - MJAlertControllerDelegate -
extension EventCreateMainViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
    }
    func validateRightButton(alertTag: MJAlertTAG) {
        self.dismiss(animated: true)

    }
}

//MARK: - Protocol EventCreateMainDelegate -
protocol EventCreateMainDelegate: AnyObject {
    //Phase 1
    func addTitle(_ title:String)
    func addDescription(_ about:String?)
    func addPhoto(image:EventImage)
    
    func showChooseImage(delegate:ChoosePictureEventDelegate)
    //Phase 2
    func addDateStart(dateStart:Date?)
    func addDateEnd(dateEnd:Date?)
    func addRecurrence(recurrence:EventRecurrence)
    func setDateChanged()
    
    //Phase 3
    func addPlaceType(isOnline:Bool)
    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?)
    func addOnline(url:String?)
    func addPlaceLimit(hasLimit:Bool, nbPlaces:Int)
    
    //Phase 4
    func addInterests(tags:Tags?, messageOther:String?)
    
    //Phase 5
    func addShare(_ isSharing:Bool)
    func addShareGroups(groups:[EventNeighborhood]?)
    
    func getNeighborhoodId() -> Int?
    //Use for edition
    func isEdit() -> Bool
    func getCurrentEvent() -> Event?
    func hasCurrentRecurrency() -> Bool
}




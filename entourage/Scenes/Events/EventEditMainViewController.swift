//
//  EventEditViewController.swift
//  entourage
//
//  Created by Jerome on 30/06/2022.
//

import UIKit
import CoreLocation
import GooglePlaces
import IHProgressHUD

class EventEditMainViewController: UIViewController {
    
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
    
    var eventId:Int = 0
    
    var newTitle:String? = nil
    var newDescription:String? = nil
    var newImageId:Int? = nil
    
    var newDateChanged:Bool? = nil
    var newStartDate:Date? = nil
    var newEndDate:Date? = nil
    var newRecurrence:EventRecurrence? = nil
    
    var newIsOnline:Bool? = nil
    var newOnlineEventUrl:String? = nil
    var newLocation:EventLocation? = nil
    var newAddressName:String? = nil
    var newGoogle_place_id:String? = nil
    var newHasPlaceLimit:Bool? = nil
    var newPlace_limit:Int? = nil
    
    var newInterests:[String]? = nil
    var newNeiborhoodIds:[Int]? = nil
    
    var newInterestTagOtherMessage:String? = nil
    var newTags:Tags? = nil
    var isGroupSharing:Bool? = nil
    
    var currentPhasePosition = 1
    
    var currentEvent:Event? = nil
    
    weak var parentController:UIViewController? = nil // Use to open the ending screen
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
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
        
        ui_bt_next.layer.cornerRadius = ui_bt_next.frame.height / 2
        ui_bt_next.backgroundColor = .appOrangeLight
        ui_bt_next.setTitleColor(.white, for: .normal)
        ui_bt_next.titleLabel?.font = ApplicationTheme.getFontNunitoBold(size: 15)
        ui_bt_next.setTitle("event_create_group_bt_next".localized, for: .normal)
        
        enableDisableNextButton(isEnable: false) //TODO: remettre false
        
        ui_main_container_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        self.modalPresentationStyle = .fullScreen
        
        ui_top_view.populateCustom(title: "event_mod_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 24), titleColor: .white, imageName: "back_button_white", backgroundColor: .clear, delegate: self, showSeparator: false)
        
        getEvent()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let vc = segue.destination as? EventCreatePageViewController {
            self.pageViewController = vc
            self.pageViewController?.parentDelegate = self
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
            ui_bt_next.setTitle("event_mod_group_bt_mod".localized, for: .normal)
        default:
            break
        }
        _ = checkValidation()
    }
    
    private func enableDisableNextButton(isEnable:Bool) {
        if isEnable {
            ui_bt_next.alpha = 1.0
        }
        else {
            ui_bt_next.alpha = 0.4
        }
    }
    
    //MARK: - Network -
    private func getEvent() {
        EventService.getEventWithId(eventId) { event, error in
            self.currentEvent = event
            Logger.print("***** return new Event ;) \(event)")
            NotificationCenter.default.post(name: NSNotification.Name(kNotificationEventEditLoadedEvent), object: nil)
            _ = self.checkValidation()
        }
    }
    
    private func createEvent() {
        if hasNoInput() {
            IHProgressHUD.showSuccesswithStatus("Événement modifié PLACEHOLDER")
            self.goEnd(event: nil)
            return
        }
        
        let newEvent = populateNewEvent()
        IHProgressHUD.show()
        Logger.print("***** createEvent \(newEvent.dictionaryForWS())")
        EventService.updateEvent(event: newEvent) { event, error in
            IHProgressHUD.dismiss()
            if event != nil {
                self.goEnd(event: event!)
            }else {
                IHProgressHUD.showError(withStatus: "Erreur lors de la création de l'event. PLACEHOLDER")
            }
        }
    }
    
    private func goEnd(event:Event?) {
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventCreateEnd), object: nil)
        
        DispatchQueue.main.async {
            self.dismiss(animated: true)
        }
    }
    
    func populateNewEvent() -> EventEditing {
        
        var newEvent = EventEditing()
        newEvent.metadata = EventMetadataEditing()
        newEvent.uid = eventId
        
        newEvent.title = newTitle
        newEvent.descriptionEvent = newDescription
        newEvent.imageId = newImageId
        
        newEvent.recurrence = newRecurrence
        newEvent.isOnline = newIsOnline
        newEvent.onlineEventUrl = newOnlineEventUrl
        newEvent.location = newLocation
        
        newEvent.metadata?.place_name = newAddressName
        newEvent.metadata?.google_place_id = newGoogle_place_id
        newEvent.metadata?.place_limit = newPlace_limit
        newEvent.startDate = newStartDate
        newEvent.endDate = newEndDate
        
        newEvent.interests = newInterests
        newEvent.neiborhoodIds = newNeiborhoodIds
        newEvent.tagOtherMessage = newInterestTagOtherMessage
        
        return newEvent
    }
}

//MARK: - EventCreateMainDelegate -
extension EventEditMainViewController: EventCreateMainDelegate {
    //Phase 1
    func addTitle(_ title: String) {
        newTitle = title
        _ = checkValidation()
    }
    func addDescription(_ about: String?) {
        newDescription = about
        _ = checkValidation()
    }
    func addPhoto(image: EventImage) {
        newImageId = image.id
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
        newStartDate = dateStart
        _ = checkValidation()
    }
    func addDateEnd(dateEnd:Date?) {
        newEndDate = dateEnd
        _ = checkValidation()
    }
    func addRecurrence(recurrence:EventRecurrence) {
        newRecurrence = recurrence
        _ = checkValidation()
    }
    func setDateChanged() {
        newDateChanged = true
        _ = checkValidation()
    }
    
    //Phase 3
    func addPlaceType(isOnline:Bool) {
        newIsOnline = isOnline
        _ = checkValidation()
    }
    func addPlace(currentlocation: CLLocationCoordinate2D?, currentLocationName: String?, googlePlace: GMSPlace?) {
        newOnlineEventUrl = nil
        if let currentlocation = currentlocation {
            newLocation = EventLocation(latitude: currentlocation.latitude, longitude: currentlocation.longitude)
            newAddressName = currentLocationName
        }
        else if let googlePlace = googlePlace {
            newAddressName = googlePlace.name
            newGoogle_place_id = googlePlace.placeID
        }
        else {
            newLocation = nil
            newGoogle_place_id = nil
            newAddressName = nil
        }
        _ = checkValidation()
    }
    func addOnline(url:String?) {
        newOnlineEventUrl = url
        _ = checkValidation()
    }
    func addPlaceLimit(hasLimit:Bool, nbPlaces:Int) {
        newHasPlaceLimit = hasLimit
        newPlace_limit = nbPlaces
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
        newInterests = [String]()
        for tag in tags.getTags() {
            if tag.isSelected {
                newInterests?.append(tag.key)
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
    func addShareGroups(groupIds:[Int]?) {
        if let groupIds = groupIds {
            newNeiborhoodIds = [Int]()
            newNeiborhoodIds?.append(contentsOf: groupIds)
        }
        else {
            newNeiborhoodIds = nil
        }
        _ = checkValidation()
    }
    
    func isEdit() -> Bool {
        return true
    }
    func getCurrentEvent() -> Event? {
        return currentEvent
    }
    
    //MARK: - Checks -
    func checkValidation() -> (isValid:Bool, message:String) {
        var isValid = true
        var message = ""
        
        switch currentPhasePosition {
        case 1:
            //Check name / desc
            if newTitle?.count ?? 2 < 2 || newDescription?.count ?? 3 <= 2 {
                isValid = false
            }
            message = "eventCreatePhase1_error".localized
        case 2: //check date start/end
            message = "eventCreatePhase2_error".localized
            if newDateChanged ?? false {
                isValid = false
                if newStartDate != nil && newEndDate != nil {
                    isValid = true
                }
            }
        case 3: //Check online + url || !online + address + limit place + nb
            if newIsOnline != nil {
                isValid = false
                if newIsOnline ?? false {
                    if newOnlineEventUrl?.count ?? 0 > ApplicationTheme.minHttpChars {
                        isValid = true
                    }
                }
                else {
                    var isValidFromLimit = false
                    if newHasPlaceLimit ?? false {
                        if newPlace_limit ?? 0 > 0 {
                            isValidFromLimit = true
                        }
                    }
                    else {
                        isValidFromLimit = true
                    }
                    
                    if ((newLocation?.latitude ?? 0 != 0) || newGoogle_place_id?.count ?? 0 > 0) && isValidFromLimit {
                        isValid = true
                    }
                }
            }
            message = "eventCreatePhase3_error".localized
        case 4: //Check interests
            if newInterests != nil {
                isValid = false
                if newInterests?.count ?? 0 > 0 {
                    isValid = true
                }
            }
            message = "eventCreatePhase4_error".localized
        case 5:
            if isGroupSharing != nil {
                isValid = false
                if isGroupSharing ?? false {
                    if newNeiborhoodIds?.count ?? 0 > 0 {
                        isValid = true
                    }
                }
                else {
                    isValid = true
                }
            }
            message = "eventCreatePhase5_error".localized
        default:
            break
        }
        enableDisableNextButton(isEnable: isValid)
        
        return (isValid,message)
    }
    
    func hasNoInput() -> Bool {
        return populateNewEvent().dictionaryForWS().count == 0
    }
}

//MARK: - MJNavBackViewDelegate -
extension EventEditMainViewController: MJNavBackViewDelegate {
    func goBack() {
        
        if hasNoInput() {
            self.dismiss(animated: true)
            return
        }
        
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "eventModPopCloseBackCancel".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        let buttonValidate = MJAlertButtonType(title: "eventModPopCloseBackQuit".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrangeLight_50, cornerRadius: -1)
        alertVC.configureAlert(alertTitle: "eventModPopCloseBackTitle".localized, message: "eventModPopCloseBackMessage".localized, buttonrightType: buttonCancel, buttonLeftType: buttonValidate, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true, parentVC: self)
        alertVC.delegate = self
        alertVC.show()
    }
}

//MARK: - MJAlertControllerDelegate -
extension EventEditMainViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {
        self.dismiss(animated: true)
    }
    func validateRightButton(alertTag: MJAlertTAG) {
    }
}

//
//  EventDetailFullFeedViewController.swift
//  entourage
//
//  Created by Jerome on 12/07/2022.
//

import UIKit
import IHProgressHUD
import EventKit
import EventKitUI

class EventDetailFullFeedViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    var event:Event? = nil
    var eventId = 0
    var isEntourageEvent = false
    
    var hasGroup = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        ui_top_view.backgroundColor = .appBeigeClair
        ui_top_view.populateCustom(title: "event_detail_full_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: nil, imageName: nil, backgroundColor: .clear, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        
        registerCellsNib()
        
        if event?.neighborhoods?.count ?? 0 > 0 {
            hasGroup = true
        }
        
        AnalyticsLoggerManager.logEvent(name: Event_detail_full)
    }
    
    func registerCellsNib() {
        ui_tableview.register(UINib(nibName: EventDetailFullCell.identifier, bundle: nil), forCellReuseIdentifier: EventDetailFullCell.identifier)
        ui_tableview.register(UINib(nibName: EventDetailFullGroupCell.identifier, bundle: nil), forCellReuseIdentifier: EventDetailFullGroupCell.identifier)
        ui_tableview.register(UINib(nibName: EventDetailFullGroupTitleCell.identifier, bundle: nil), forCellReuseIdentifier: EventDetailFullGroupTitleCell.identifier)
        ui_tableview.register(UINib(nibName: EventDetailFullInterestCell.identifier, bundle: nil), forCellReuseIdentifier: EventDetailFullInterestCell.identifier)
    }
    
    func showPopLeave() {
        
        let currentUserId = UserDefaults.currentUser?.sid
        if event?.author?.uid == currentUserId { return }
        
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_leave_event_pop_bt_quit".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_leave_event_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_leave_event_pop_title".localized, message: "params_leave_event_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .None
        customAlert.delegate = self
        customAlert.show()
    }
    
    func sendLeaveGroup() {
        IHProgressHUD.show()
        EventService.leaveEvent(eventId: eventId, userId: UserDefaults.currentUser!.sid) { event, error in
            IHProgressHUD.dismiss()
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationEventUpdate), object: nil)
                self.goBack()
            }
        }
    }
}

//MARK: - Tableview Datasource/delegate -
extension EventDetailFullFeedViewController: UITableViewDataSource, UITableViewDelegate {
    func numberOfSections(in tableView: UITableView) -> Int {
        return hasGroup ? 3 : 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if hasGroup {
            switch section {
            case 0,2:
                return 1
            default:
                return event!.neighborhoods!.count + 1
            }
        }
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailFullCell.identifier, for: indexPath) as! EventDetailFullCell
            
            cell.populateCell(event: event!, delegate: self, isEntourageEvent: isEntourageEvent)
            
            return cell
        }
        if hasGroup && indexPath.section == 1 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailFullGroupTitleCell.identifier, for: indexPath) as! EventDetailFullGroupTitleCell
                
                cell.populate(nbOfGroups: event?.neighborhoods?.count ?? 1)
                
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailFullGroupCell.identifier, for: indexPath) as! EventDetailFullGroupCell
            
            cell.populateCell(title: event!.neighborhoods![indexPath.row - 1].name)
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailFullInterestCell.identifier, for: indexPath) as! EventDetailFullInterestCell
        cell.populateCell(interests: event?.interests)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if hasGroup && indexPath.section == 1 && indexPath.row > 0 {
            let neighId = event!.neighborhoods![indexPath.row - 1].id
            let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
            if let nav = sb.instantiateViewController(withIdentifier: "neighborhoodDetailNav") as? UINavigationController, let vc = nav.topViewController as? NeighborhoodDetailViewController {
                vc.isAfterCreation = false
                vc.neighborhoodId = neighId
                vc.isShowCreatePost = false
                vc.neighborhood = nil
                self.navigationController?.present(nav, animated: true)
            }
        }
    }
}

//MARK: - EventDetailFullDelegate -
extension EventDetailFullFeedViewController: EventDetailFullDelegate {
    func showWebviewUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
    
    func showMembers() {
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.isEvent = true
            self.navigationController?.present(navVC, animated: true)
        }
    }
    func showMemberReact(postId:Int){
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.postId = postId
            vc.eventId = eventId
            vc.isFromReact = true
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    func showLocation() {
        if event?.isCanceled() ?? false { return }
        
        if event?.isOnline ?? false, let urlStr = event?.onlineEventUrl {
            WebLinkManager.openUrl(url: URL(string: urlStr), openInApp: false, presenterViewController: self)
        }
        else {
            if let _address = event?.metadata?.display_address?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let mapString = String.init(format: "https://maps.apple.com/?address=%@", _address)
                WebLinkManager.openUrl(url: URL(string: mapString), openInApp: false, presenterViewController: self)
            }
        }
    }
    
    func leaveEvent() {
        showPopLeave()
    }
    
    //MARK: - Calendar -
    func addToCalendar() {
        let store = EKEventStore()
        store.requestAccess(to: .event, completion: {(granted,error) in
            if granted && error == nil {
                self.showPopCalendar()
            }
            else {
                DispatchQueue.main.async {
                    let alertVC = MJAlertController()
                    alertVC.alertTagName = .AcceptSettings
                    let buttonCancel = MJAlertButtonType(title: "event_add_contact_refuse".localized, titleStyle:ApplicationTheme.getFontCourantBoldOrange(), bgColor: .appOrangeLight, cornerRadius: -1)
                    let buttonValidate = MJAlertButtonType(title: "event_add_contact_activate".localized, titleStyle:ApplicationTheme.getFontCourantBoldOrange(), bgColor: .appOrange, cornerRadius: -1)
                    alertVC.configureAlert(alertTitle: "errorSettings".localized, message: "event_add_contact_error".localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
                    
                    alertVC.delegate = self
                    alertVC.show()
                }
            }
        })
    }
    
    func showPopCalendar() {
        DispatchQueue.main.async {
            let alertVC = MJAlertController()
            alertVC.alertTagName = .AcceptAdd
            let buttonCancel = MJAlertButtonType(title: "event_add_contact_cancel".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
            let buttonValidate = MJAlertButtonType(title: "event_add_contact_accept".localized, titleStyle:ApplicationTheme.getFontCourantBoldOrange(), bgColor: .appOrange, cornerRadius: -1)
            alertVC.configureAlert(alertTitle: "event_add_contact_title".localized, message: "event_add_contact_description".localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
            
            alertVC.delegate = self
            alertVC.show()
        }
    }
    
    func showAddCalendar() {
        let store = EKEventStore()
        store.requestAccess(to: .event, completion: {(granted,error) in
            if granted && error == nil {
                let ekEvent = EKEvent(eventStore: store)
                ekEvent.title = self.event?.title
                ekEvent.startDate = self.event?.getMetadateStartDate()
                ekEvent.endDate = self.event?.getMetadateEndDate()
                
                if let _url = self.event?.onlineEventUrl, let url = URL.init(string: _url) {
                    ekEvent.url = url
                }
                else if let _lat = self.event?.location?.latitude, let _long = self.event?.location?.longitude {
                    let _structLovation = EKStructuredLocation()
                    _structLovation.geoLocation = CLLocation(latitude: _lat, longitude: _long)
                    _structLovation.title = self.event?.addressName
                    ekEvent.structuredLocation = _structLovation
                    ekEvent.location = self.event?.addressName
                }
                
                DispatchQueue.main.async {
                    let vc = EKEventEditViewController()
                    vc.editViewDelegate = self
                    vc.event = ekEvent
                    vc.eventStore = store
                    self.present(vc, animated: true, completion: nil)
                }
            }
        })
    }
}

//MARK: - MJAlertControllerDelegate -
extension EventDetailFullFeedViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {}
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendLeaveGroup()
        }
        
        if alertTag == .AcceptSettings {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:],completionHandler:nil)
            }
        }
        if alertTag == .AcceptAdd {
            self.showAddCalendar()
        }
    }
    
    func closePressed(alertTag:MJAlertTAG) {}
}

//MARK: - MJNavBackViewDelegate -
extension EventDetailFullFeedViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
    func didTapEvent() {
        //Nothing yet
    }
}

//MARK: - EKEVENT Delegate -
extension EventDetailFullFeedViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}

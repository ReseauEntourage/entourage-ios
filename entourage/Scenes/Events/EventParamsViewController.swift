//
//  EventParamsViewController.swift
//  entourage
//
//  Created by Jerome on 25/07/2022.
//

import UIKit

class EventParamsViewController: BasePopViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var event:Event? = nil
    
    var eventUserType:EventUserType = .Viewer
    
    var hasRecurrency = false
    
    var isCanceled = false
    var isRealAuthor = false
    
    var selectedRecurrencyPosition = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hasRecurrency = event?.recurrence == .once ? false : true
        let currentUserId = UserDefaults.currentUser?.sid
        
        isCanceled = event?.isCanceled() ?? false
        isRealAuthor = event?.author?.uid == currentUserId
        
        if isRealAuthor && !isCanceled {
            eventUserType = .Creator
        }
        else {
            if let event = event, event.isMember ?? false {
                eventUserType = .Member
            }
            else {
                eventUserType = .Viewer
            }
        }
        
        ui_top_view.populateView(title: "event_params_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self,backgroundColor: .appBeigeClair, isClose: true)
        
        //Notif for updating event infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvent(_ :)), name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = event else {
            self.goBack()
            return
        }
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    @objc func updateEvent(_ notification:Notification) {
        if let _event = notification.userInfo?["event"] as? Event {
            self.event = _event
            self.ui_tableview.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func sendQuitEvent() {
        guard let event = event else {
            return
        }
        
        EventService.leaveEvent(eventId: event.uid, userId: UserDefaults.currentUser!.sid) { event, error in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
                self.goBack()
            }
        }
    }
    
    func sendCancelEvent() {
        guard let event = event else {
            return
        }

        EventService.cancelEvent(eventId: event.uid) { event, error in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
                //TODO: On ferme la page ?
                self.goBack()
            }
        }
    }
    
    func sendCancelEventRecurrency() {
        guard let event = event else {
            return
        }

        EventService.cancelEventWithRecurrency(eventId: event.uid) { event, error in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
                //TODO: On ferme la page ?
                self.goBack()
            }
        }
    }
    
    func showPopLeave() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_leave_event_pop_bt_quit".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_leave_event_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), bgColor: .appOrangeLight_50, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_leave_event_pop_title".localized, message: "params_leave_event_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .None
        customAlert.delegate = self
        customAlert.show()
    }
    
    func showPopCancel() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_cancel_event_pop_bt_delete".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_cancel_event_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), bgColor: .appOrangeLight_50, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_cancel_event_pop_title".localized, message: "params_cancel_event_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
    }
    
    func showPopCancelRecurrency() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_cancel_event_pop_bt_delete".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_cancel_event_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), bgColor: .appOrangeLight_50, cornerRadius: -1)
        
        customAlert.configurePopWithChoice(alertTitle: "params_cancel_event_recurrency_title".localized, choice1: "params_cancel_event_recurrency_choice1".localized, choice2: "params_cancel_event_recurrency_choice2".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), choiceStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
    }
}

//MARK: - MJAlertControllerDelegate -
extension EventParamsViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {}
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendQuitEvent()
        }
        
        if alertTag == .Suppress {
            if selectedRecurrencyPosition == 1 {
                self.sendCancelEventRecurrency()
            }
            else {
                self.sendCancelEvent()
            }
        }
    }
    func closePressed(alertTag:MJAlertTAG) {}
    
    func selectedChoice(position: Int) {
        selectedRecurrencyPosition = position
    }
}

//MARK: - Tableview Datasource/delegate -
extension EventParamsViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch eventUserType {
        case .Creator:
            return hasRecurrency ? 7 : 6 // minus 1 remove notifs for now
        case .Member:
            return isRealAuthor ? 4 : 5 // minus 1 remove notifs for now
        case .Viewer:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_info", for: indexPath) as! EventParamTopCell
            
            cell.populateCell(event: event)
            
            return cell
        }
        
        switch eventUserType {
        case .Creator:
            switch indexPath.row {
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! EventParamEditShow
                cell.populateCell(title: "event_params_edit".localized, imageName: "ic_edit_group", delegate: self, type: .EditEvent)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! EventParamEditShow
                cell.populateCell(title: "event_share_option".localized, imageName: "ic_share", delegate: self, type: .share)
                return cell
            case 3:
                if hasRecurrency {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! EventParamEditShow
                    cell.populateCell(title: "event_params_recurrency".localized, imageName: "ic_edit_group", delegate: self, type: .EditRecurrency)
                    return cell
                }
                else {
                    //CGU
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! EventParamEditShow
                    cell.populateCell(title: "event_params_cgu".localized, imageName: "ic_cgu_group", delegate: self, type: .CGU)
                    return cell
                }
            case 4:
                if hasRecurrency {
                    //CGU
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! EventParamEditShow
                    cell.populateCell(title: "event_params_cgu".localized, imageName: "ic_cgu_group", delegate: self, type: .CGU)
                    return cell
                }
                else {
                    //Signal
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! EventParamSignalCell
                    cell.populateCell(isQuit: false, hasCellBottom: true,delegate: self,isCancelEvent: false)
                    return cell
                }
            case 5:
                if hasRecurrency {
                    //Signal
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! EventParamSignalCell
                    cell.populateCell(isQuit: false, hasCellBottom: true,delegate: self,isCancelEvent: false)
                    return cell
                }
                else {
                    //Quit
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! EventParamSignalCell
                    cell.populateCell(isQuit: true, hasCellBottom: false,delegate: self,isCancelEvent: true)
                    return cell
                }
               
            default:
                //Cancel
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! EventParamSignalCell
                    cell.populateCell(isQuit: true, hasCellBottom: false,delegate: self,isCancelEvent: true)
                    return cell
            }
        case .Member:
            switch indexPath.row {
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! EventParamEditShow
                cell.populateCell(title: "event_params_cgu".localized, imageName: "ic_cgu_group", delegate: self, type: .CGU)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! EventParamEditShow
                cell.populateCell(title: "event_share_option".localized, imageName: "ic_share", delegate: self, type: .share)
                return cell
                
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! EventParamSignalCell
                cell.populateCell(isQuit: false, hasCellBottom: true,delegate: self,isCancelEvent: false)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! EventParamSignalCell
                cell.populateCell(isQuit: true, hasCellBottom: false,delegate: self,isCancelEvent: false)
                return cell
            }
        case .Viewer:
            switch indexPath.row {
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! EventParamEditShow
                cell.populateCell(title: "event_params_cgu".localized, imageName: "ic_cgu_group", delegate: self, type: .CGU)
                return cell
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! EventParamEditShow
                cell.populateCell(title: "event_share_option".localized, imageName: "ic_share", delegate: self, type: .share)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! EventParamSignalCell
                cell.populateCell(isQuit: false, hasCellBottom: false,delegate: self,isCancelEvent: false)
                return cell
            }
        }
    }
}

//MARK: - GroupDetailDelegate -
extension EventParamsViewController: GroupDetailDelegate {
    func publicationDeleted() {
        self.ui_tableview.reloadData()
    }
    
    func showMessage(signalType:GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle:ApplicationTheme.getFontCourantRegularNoir(size: 18, color: .white), bgColor: .appOrange, cornerRadius: -1)
        
        alertVC.configureAlert(alertTitle: "report_event_title".localized, message: "report_group_message_success".localized, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension EventParamsViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

//MARK: - NeighborhoodParamCellDelegate -
extension EventParamsViewController: EventParamCellDelegate {
    func share() {
        var stringUrl = "https://"
        var title = ""
        if NetworkManager.sharedInstance.getBaseUrl().contains("preprod"){
            stringUrl = stringUrl + "preprod.entourage.social/app/"
        }else{
            stringUrl = stringUrl + "www.entourage.social/app/"
        }
        if let _event = event {
            stringUrl = stringUrl + "outings/" + _event.uuid_v2
            title = "share_event".localized + "\n" + _event.title + ": "

        }
        let url = URL(string: stringUrl)!
        let shareText = "\(title)\n\n\(stringUrl)"
        
        let activityViewController = UIActivityViewController(activityItems: [title, url], applicationActivities: nil)
          // Présenter l’UIActivityViewController
        let viewController = self
          viewController.present(activityViewController, animated: true, completion: nil)
        AnalyticsLoggerManager.logEvent(name: event_option_share)
    }
    
    func quitEvent() {
        let currentUserId = UserDefaults.currentUser?.sid
        if event?.author?.uid == currentUserId {
            if hasRecurrency {
                showPopCancelRecurrency()
            }
            else {
                showPopCancel()
            }
        }
        else {
            showPopLeave()
        }
    }
    
    func signalEvent() {
        AnalyticsLoggerManager.logEvent(name: action_event_report)
        if let  vc = UIStoryboard.init(name: StoryboardName.neighborhoodReport, bundle: nil).instantiateViewController(withIdentifier: "reportGroupMainVC") as? ReportGroupMainViewController {
            vc.modalPresentationStyle = .currentContext
            vc.event = event
            vc.parentDelegate = self
            vc.signalType = .event
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showCGU() {
        if let  vc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "params_CGU_VC") as? EventParamsCGUViewController {
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func editEvent() {
        if let  vc = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventEditVCMain") as? EventEditMainViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.currentEvent = self.event
            vc.eventId = self.event?.uid ?? -1
            vc.hasRecurrency = hasRecurrency
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func editRecurrency() {
        if let  vc = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventEditRecurrencyVC") as? EventEditRecurrencyViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.event = self.event
            
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func editNotif(notifType:EventUserNotifType,isOn:Bool) {
        //TODO: à faire
        Logger.print("***** edit notif : \(notifType) - Is on \(isOn)")
    }
}


//MARK: - NeighborhoodParamCellDelegate Protocol -
protocol EventParamCellDelegate:AnyObject {
    func signalEvent()
    func quitEvent()
    func showCGU()
    func editEvent()
    func editRecurrency()
    func editNotif(notifType:EventUserNotifType,isOn:Bool)
    func share()
}

//MARK: - Enums -
enum EventUserNotifType {
    case All
    case Publications
    case Members
}

enum EventUserType {
    case Creator
    case Member
    case Viewer
}

enum EventCellEditType {
    case CGU
    case EditEvent
    case EditRecurrency
    case share
}

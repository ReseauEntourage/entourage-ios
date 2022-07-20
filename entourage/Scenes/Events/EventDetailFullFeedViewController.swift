//
//  EventDetailFullFeedViewController.swift
//  entourage
//
//  Created by Jerome on 12/07/2022.
//

import UIKit
import IHProgressHUD

class EventDetailFullFeedViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    var event:Event? = nil
    var eventId = 0
    
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
        let buttonCancel = MJAlertButtonType(title: "params_leave_event_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), bgColor: .appOrangeLight_50, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_leave_event_pop_title".localized, message: "params_leave_event_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35,parentVC:self)
        
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
            
            cell.populateCell(event: event!, delegate: self)
            
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
    func showMembers() {
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.isEvent = true
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    func showLocation() {
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
    
    func addToCalendar() {
        self.showWIP(parentVC: self.navigationController)
    }
}

//MARK: - MJAlertControllerDelegate -
extension EventDetailFullFeedViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {
        if alertTag == .AcceptSettings {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:],completionHandler:nil)
            }
        }
    }
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendLeaveGroup()
        }
    }
    
    func closePressed(alertTag:MJAlertTAG) {}
}


//MARK: - MJNavBackViewDelegate -
extension EventDetailFullFeedViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

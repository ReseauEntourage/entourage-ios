//
//  NeighborhoodParamsGroupViewController.swift
//  entourage
//
//  Created by Jerome on 02/05/2022.
//

import UIKit

protocol NeighborhoodParamDismissDelegate{
    func onDismiss()
}

class NeighborhoodParamsGroupViewController: BasePopViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var neighborhood:Neighborhood? = nil
    var groupUserType:GroupUserType = .Viewer
    var dismissDelegate:NeighborhoodParamDismissDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let currentUserId = UserDefaults.currentUser?.sid
        if neighborhood?.creator.uid == currentUserId {
            groupUserType = .Creator
        }
        else {
            if let neighborhood = neighborhood, neighborhood.isMember {
                groupUserType = .Member
            }
            else {
                groupUserType = .Viewer
            }
        }
        
        ui_top_view.populateView(title: "neighborhood_params_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self,backgroundColor: .appBeigeClair, isClose: true)
        
        //Notif for updating neighborhood infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateNeighborhood(_ :)), name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
        
        AnalyticsLoggerManager.logEvent(name: View_GroupOption_Show)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let _ = neighborhood else {
            self.goBack()
            return
        }
        self.navigationController?.hideTransparentNavigationBar()
    }
    
    @objc func updateNeighborhood(_ notification:Notification) {
        if let neighB = notification.userInfo?["neighborhood"] as? Neighborhood {
            self.neighborhood = neighB
            self.ui_tableview.reloadData()
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func sendQuitGroup() {
        guard let neighborhood = neighborhood else {
            return
        }
        
        NeighborhoodService.leaveNeighborhood(groupId: neighborhood.uid, userId: UserDefaults.currentUser!.sid) { group, error in
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
                self.goBack()
            }
        }
    }
    
    func showPopLeave() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_leave_group_pop_bt_quit".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_leave_group_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_leave_group_pop_title".localized, message: "params_leave_group_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
        customAlert.alertTagName = .None
        customAlert.delegate = self
        customAlert.show()
    }
}

//MARK: - MJAlertControllerDelegate -
extension NeighborhoodParamsGroupViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {
        
    }
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendQuitGroup()
        }
    }
    func closePressed(alertTag:MJAlertTAG) {}
}


//MARK: - Tableview Datasource/delegate -
extension NeighborhoodParamsGroupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch groupUserType {
        case .Creator:
            return 5 //TODO: on peut quitter le groupe ? //Return 4 hide notif now
        case .Member:
            return 5  //Return 4 hide notif now
        case .Viewer:
            return 4
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cell_info", for: indexPath) as! NeighborhoodParamTopCell
            
            cell.populateCell(neighborhood: neighborhood)
            
            return cell
        }
        
        switch groupUserType {
        case .Creator:
            switch indexPath.row {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_edit".localized,imageName: "ic_edit_group", delegate: self, isCGU: false, isShare: false)
                return cell
            case 2: /*here change for share*/
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_share".localized,imageName: "ic_share", delegate: self, isCGU: false, isShare: true)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_cgu".localized,imageName: "ic_cgu_group", delegate: self, isCGU: true, isShare: false)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! NeighborhoodParamSignalCell
                cell.populateCell(isQuit: false, hasQuit: false,delegate: self)
                return cell
            }
        case .Member:
            switch indexPath.row {
            case 1: /*here change for share**/
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_share".localized,imageName: "ic_share", delegate: self, isCGU: false, isShare: true)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_cgu".localized,imageName: "ic_cgu_group", delegate: self, isCGU: true, isShare: false)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! NeighborhoodParamSignalCell
                cell.populateCell(isQuit: false, hasQuit: true,delegate: self)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! NeighborhoodParamSignalCell
                cell.populateCell(isQuit: true, hasQuit: true,delegate: self)
                return cell
            }
        case .Viewer:
            switch indexPath.row {
            case 1: /*here change for share**/
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_share".localized,imageName: "ic_share", delegate: self, isCGU: false, isShare: true)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_cgu".localized,imageName: "ic_cgu_group", delegate: self, isCGU: true, isShare: false)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! NeighborhoodParamSignalCell
                cell.populateCell(isQuit: false, hasQuit: false,delegate: self)
                return cell
            }
        }
    }
}

//MARK: - GroupDetailDelegate -
extension NeighborhoodParamsGroupViewController: GroupDetailDelegate {
    func translateItem(id: Int) {
        //TODO Translate
    }
    
    func publicationDeleted() {
        self.ui_tableview.reloadData()
    }
    
    func showMessage(signalType:GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        
        alertVC.configureAlert(alertTitle: "report_group_title".localized, message: "report_group_message_success".localized, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodParamsGroupViewController: MJNavBackViewDelegate {
    func didTapEvent() {
        //Nothing yet 
    }
    
    func goBack() {
        self.dismissDelegate?.onDismiss()
        self.navigationController?.dismiss(animated: true)
    }
}

//MARK: - NeighborhoodParamCellDelegate -
extension NeighborhoodParamsGroupViewController: NeighborhoodParamCellDelegate {
    func shareGroup() {
        var stringUrl = "https://"
        var title = ""
        if NetworkManager.sharedInstance.getBaseUrl().contains("preprod"){
            stringUrl = stringUrl + "preprod.entourage.social/app/"
        }else{
            stringUrl = stringUrl + "www.entourage.social/app/"
        }
        if let _group = neighborhood {
            stringUrl = stringUrl + "neighborhoods/" + _group.uuid_v2
            title = "share_group".localized + "\n" + _group.name + ": "

        }
        let url = URL(string: stringUrl)!
        let shareText = "\(title)\n\n\(stringUrl)"
        
        let activityViewController = UIActivityViewController(activityItems: [title, url], applicationActivities: nil)
          // Présenter l’UIActivityViewController
        let viewController = self
          viewController.present(activityViewController, animated: true, completion: nil)
        AnalyticsLoggerManager.logEvent(name: group_option_share)
    }
    
    func quitGroup() {
        AnalyticsLoggerManager.logEvent(name: Action_GroupOption_Quit)
        showPopLeave()
    }
    
    func signalGroup() {
        AnalyticsLoggerManager.logEvent(name: Action_GroupOption_Report)
        if let  vc = UIStoryboard.init(name: StoryboardName.neighborhoodReport, bundle: nil).instantiateViewController(withIdentifier: "reportGroupMainVC") as? ReportGroupMainViewController {
            vc.modalPresentationStyle = .currentContext
            vc.group = neighborhood
            vc.parentDelegate = self
            vc.signalType = .group
            vc.textString = neighborhood?.aboutGroup
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showCGU() {
        AnalyticsLoggerManager.logEvent(name: Action_GroupOption_Rules)
        if let  vc = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "params_CGU_VC") as? NeighBorhoodParamsCGUViewController {
            vc.modalPresentationStyle = .fullScreen
            
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func editGroup() {
        AnalyticsLoggerManager.logEvent(name: Action_GroupOption_EditGroup)
        if let  vc = UIStoryboard.init(name: StoryboardName.neighborhoodCreate, bundle: nil).instantiateViewController(withIdentifier: "editGroupVC") as? NeighborhoodEditViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.currentNeighborhoodId = self.neighborhood!.uid
            
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func editNotif(notifType:GroupUserNotifType,isOn:Bool) {
        //TODO: à faire
        switch notifType {
        case .All:
            AnalyticsLoggerManager.logEvent(name: Action_GroupOption_Notif_All)
        case .Events:
            AnalyticsLoggerManager.logEvent(name: Action_GroupOption_Notif_Event)
        case .Messages:
            AnalyticsLoggerManager.logEvent(name: Action_GroupOption_Notif_Message)
        case .Members:
            AnalyticsLoggerManager.logEvent(name: Action_GroupOption_Notif_Member)
        }
        Logger.print("***** edit notif : \(notifType) - Is on \(isOn)")
    }
}


//MARK: - NeighborhoodParamCellDelegate Protocol -
protocol NeighborhoodParamCellDelegate:AnyObject {
    func signalGroup()
    func quitGroup()
    func showCGU()
    func editGroup()
    func editNotif(notifType:GroupUserNotifType,isOn:Bool)
    func shareGroup()
}

//MARK: - Enums -
enum GroupUserNotifType {
    case All
    case Events
    case Messages
    case Members
}

enum GroupUserType {
    case Creator
    case Member
    case Viewer
}

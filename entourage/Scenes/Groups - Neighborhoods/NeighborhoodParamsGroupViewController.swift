//
//  NeighborhoodParamsGroupViewController.swift
//  entourage
//
//  Created by Jerome on 02/05/2022.
//

import UIKit
import IHProgressHUD

class NeighborhoodParamsGroupViewController: BasePopViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    
    var neighborhood:Neighborhood? = nil
    
    var groupUserType:GroupUserType = .Viewer
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let currentUserId = UserDefaults.currentUser?.sid
        if neighborhood?.creator.uid == currentUserId {
            groupUserType = .Creator
        }
        else {
            if let neighborhood = neighborhood, neighborhood.isFollowingGroup(myId: currentUserId) {
                groupUserType = .Member
            }
            else {
                groupUserType = .Viewer
            }
        }
        
        ui_top_view.populateView(title: "neighborhood_params_title".localized, titleFont: ApplicationTheme.getFontQuickSandBold(size: 15), titleColor: .black, delegate: self,backgroundColor: .appBeigeClair, isClose: true)
        
        //Notif for updating neighborhood infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateNeighborhood(_ :)), name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
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
        
        NeighborhoodService.leaveGroup(groupId: neighborhood.uid, userId: UserDefaults.currentUser!.sid) { group, error in
            IHProgressHUD.dismiss()
            if error == nil {
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
                self.goBack()
            }
        }
    }
    
    func showPopLeave() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_leave_group_pop_bt_quit".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_leave_group_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_leave_group_pop_title".localized, message: "params_leave_group_pop_message".localized, buttonrightType: buttonCancel, buttonLeftType: buttonAccept, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35,parentVC:self)
        
        customAlert.alertTagName = .None
        customAlert.delegate = self
        customAlert.show()
    }
}

//MARK: - MJAlertControllerDelegate -
extension NeighborhoodParamsGroupViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendQuitGroup()
        }
    }
    
    func validateRightButton(alertTag:MJAlertTAG) {}
    func closePressed(alertTag:MJAlertTAG) {}
}


//MARK: - Tableview Datasource/delegate -
extension NeighborhoodParamsGroupViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch groupUserType {
        case .Creator:
            return 5 //TODO: on peut quitter le groupe ?
        case .Member:
            return 4
        case .Viewer:
            return 3
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
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_notifs", for: indexPath) as! NeighborhoodParamNotifsCell
                cell.populateCell(notif_all: true, notif_events: false, notif_messages: true, notif_members: true, delegate: self)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_edit".localized,imageName: "ic_edit_group", delegate: self, isCGU: false)
                return cell
            case 3:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_cgu".localized,imageName: "ic_cgu_group", delegate: self, isCGU: true)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! NeighborhoodParamSignalCell
                cell.populateCell(isQuit: false,delegate: self)
                return cell
            }
        case .Member:
            switch indexPath.row {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_cgu".localized,imageName: "ic_cgu_group", delegate: self, isCGU: true)
                return cell
            case 2:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! NeighborhoodParamSignalCell
                cell.populateCell(isQuit: false,delegate: self)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! NeighborhoodParamSignalCell
                cell.populateCell(isQuit: true,delegate: self)
                return cell
            }
        case .Viewer:
            switch indexPath.row {
            case 1:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_cgu", for: indexPath) as! NeighborhoodParamEditShowCell
                cell.populateCell(title: "neighborhood_params_edit".localized,imageName: "ic_edit_group", delegate: self, isCGU: true)
                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "cell_signal", for: indexPath) as! NeighborhoodParamSignalCell
                cell.populateCell(isQuit: false,delegate: self)
                return cell
            }
        }
    }
}

//MARK: - GroupDetailDelegate -
extension NeighborhoodParamsGroupViewController: GroupDetailDelegate {
    func showMessage(message: String, imageName: String?) {
        //TODO: on affiche cette info ou une pop custom ?
        IHProgressHUD.showSuccesswithStatus(message)
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodParamsGroupViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

//MARK: - NeighborhoodParamCellDelegate -
extension NeighborhoodParamsGroupViewController: NeighborhoodParamCellDelegate {
    func quitGroup() {
        showPopLeave()
    }
    
    func signalGroup() {
        if let  vc = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "reportGroupMainVC") as? ReportGroupMainViewController {
            vc.modalPresentationStyle = .currentContext
            vc.group = neighborhood
            vc.parentDelegate = self
            vc.signalType = .group
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showCGU() {
        if let  vc = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "params_CGU_VC") as? NeighBorhoodParamsCGUViewController {
            vc.modalPresentationStyle = .fullScreen
            
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func editGroup() {
        if let  vc = UIStoryboard.init(name: "Neighborhood_Create", bundle: nil).instantiateViewController(withIdentifier: "editGroupVC") as? NeighborhoodEditViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.currentNeighborhoodId = self.neighborhood!.uid
            
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func editNotif(notifType:GroupUserNotifType,isOn:Bool) {
        //TODO: à faire
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

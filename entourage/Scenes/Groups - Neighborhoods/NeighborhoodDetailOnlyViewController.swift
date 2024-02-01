//
//  NeighborhoodDetailOnlyViewController.swift
//  entourage
//
//  Created by Jerome on 11/05/2022.
//

import UIKit
import IHProgressHUD

class NeighborhoodDetailOnlyViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    var neighborhoodId:Int = 0
    var neighborhood:Neighborhood? = nil
    
    weak var delegate:NeighborhoodDetailViewControllerDelegate? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: "neighborhood_about_group_title".localized, titleFont: ApplicationTheme.getFontCourantBoldNoir().font, titleColor: ApplicationTheme.getFontCourantBoldNoir().color, imageName: nil, backgroundColor: .appBeigeClair, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        
        getNeighborhoodDetail()
        NotificationCenter.default.addObserver(self, selector: #selector(updateNeighborhood), name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
        AnalyticsLoggerManager.logEvent(name: View_GroupFeed_FullDescription)
    }
    
    @objc func updateNeighborhood() {
        getNeighborhoodDetail()

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getNeighborhoodDetail() {
        NeighborhoodService.getNeighborhoodDetail(id: String(neighborhoodId)) { group, error in
            if let _ = error {
                self.goBack()
            }
            self.neighborhood = group
            self.ui_tableview.reloadData()
        }
    }
    
    func addRemoveMember(isAdd:Bool) {
        guard let neighborhood = neighborhood else {
            return
        }
        if isAdd {
            IHProgressHUD.show()
            NeighborhoodService.joinNeighborhood(groupId: neighborhood.uid) { user, error in
                IHProgressHUD.dismiss()
                if let user = user {
                    let member = MemberLight.init(uid: user.uid, username: user.username, imageUrl: user.imageUrl)
                    self.neighborhood?.members.append(member)
                    let count:Int = self.neighborhood?.membersCount != nil ? self.neighborhood!.membersCount + 1 : 1
                    
                    self.neighborhood?.membersCount = count
                    self.delegate?.refreshNeighborhoodModified()
                }
            }
        }
        else {
            showPopLeave()
        }
        
    }
    
    func joinLeaveGroup() {
        let currentUserId = UserDefaults.currentUser?.sid
        if neighborhood?.creator.uid == currentUserId { return }
        
        if let _ = neighborhood?.members.first(where: {$0.uid == currentUserId}) {
            addRemoveMember(isAdd: false)
        }
        else {
            addRemoveMember(isAdd: true)
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
    
    func sendLeaveGroup() {
        guard let neighborhood = neighborhood else {
            return
        }
        IHProgressHUD.show()
        NeighborhoodService.leaveNeighborhood(groupId: neighborhood.uid, userId: UserDefaults.currentUser!.sid) { group, error in
            IHProgressHUD.dismiss()
            if error == nil {
                self.neighborhood?.members.removeAll(where: {$0.uid == UserDefaults.currentUser!.sid})
                let count:Int = self.neighborhood?.membersCount != nil ? self.neighborhood!.membersCount - 1 : 0
                
                self.neighborhood?.membersCount = count
                
                self.ui_tableview.reloadData()
                self.delegate?.refreshNeighborhoodModified()
            }
        }
    }
    
    @IBAction func action_show_params(_ sender: Any) {
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "params_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighborhoodParamsGroupViewController {
            vc.neighborhood = neighborhood
            self.navigationController?.present(navVC, animated: true)
        }
    }
}

//MARK: - MJAlertControllerDelegate -
extension NeighborhoodDetailOnlyViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {
        
    }
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendLeaveGroup()
        }
    }
    func closePressed(alertTag:MJAlertTAG) {}
}

//MARK: - UITableViewDataSource / Delegate -
extension NeighborhoodDetailOnlyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.neighborhood != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath) as! NeighborhoodDetailTopCell
        cell.populateCell(neighborhood: self.neighborhood, isFollowingGroup: self.neighborhood?.isMember ?? false, isFromOnlyDetail: true, delegate: self)
        return cell
    }
}

//MARK: - NeighborhoodDetailTopCellDelegate -
extension NeighborhoodDetailOnlyViewController: NeighborhoodDetailTopCellDelegate {
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
        AnalyticsLoggerManager.logEvent(name: group_share)
    }
    
    func showWebUrl(urlString: String) {
        if let url = urlString.extractUrlFromChain(){
            WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
        }
    }
    
    func showWebUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
    
    func showMembers() {
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.neighborhood = neighborhood
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    
    func joinLeave() {
        joinLeaveGroup()
    }
    func showDetailFull() {}
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodDetailOnlyViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

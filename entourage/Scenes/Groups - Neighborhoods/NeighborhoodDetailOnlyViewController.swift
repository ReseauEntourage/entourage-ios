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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: "neighborhood_about_group_title".localized, titleFont: ApplicationTheme.getFontCourantBoldNoir().font, titleColor: ApplicationTheme.getFontCourantBoldNoir().color, imageName: nil, backgroundColor: .appBeigeClair, delegate: self, showSeparator: true, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        
        getNeighborhoodDetail()
        NotificationCenter.default.addObserver(self, selector: #selector(updateNeighborhood), name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
    }
    
    @objc func updateNeighborhood() {
        getNeighborhoodDetail()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func getNeighborhoodDetail() {
        NeighborhoodService.getNeighborhoodDetail(id: neighborhoodId) { group, error in
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
        
        IHProgressHUD.show()
        
        if isAdd {
            NeighborhoodService.joinGroup(groupId: neighborhood.uid) { user, error in
                IHProgressHUD.dismiss()
                if let user = user {
                    let member = NeighborhoodUserLight.init(uid: user.uid, username: user.username, imageUrl: user.imageUrl)
                    self.neighborhood?.members.append(member)
                    let count:Int = self.neighborhood?.membersCount != nil ? self.neighborhood!.membersCount + 1 : 1
                    
                    self.neighborhood?.membersCount = count
                    self.ui_tableview.reloadData()
                }
            }
        }
        else {
            NeighborhoodService.leaveGroup(groupId: neighborhood.uid, userId: UserDefaults.currentUser!.sid) { group, error in
                IHProgressHUD.dismiss()
                if error == nil {
                    self.neighborhood?.members.removeAll(where: {$0.uid == UserDefaults.currentUser!.sid})
                    let count:Int = self.neighborhood?.membersCount != nil ? self.neighborhood!.membersCount - 1 : 0
                    
                    self.neighborhood?.membersCount = count
                    
                    self.ui_tableview.reloadData()
                }
            }
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
        self.ui_tableview.reloadData()
    }
    
    @IBAction func action_show_params(_ sender: Any) {
        if let navVC = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "params_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighborhoodParamsGroupViewController {
            vc.neighborhood = neighborhood
            self.navigationController?.present(navVC, animated: true)
        }
    }
}

//MARK: - UITableViewDataSource / Delegate -
extension NeighborhoodDetailOnlyViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.neighborhood != nil ? 1 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath) as! NeighborhoodDetailTopCell
        cell.populateCell(neighborhood: self.neighborhood, isFollowingGroup: false, delegate: self)
        return cell
    }
}

//MARK: - NeighborhoodDetailTopCellDelegate -
extension NeighborhoodDetailOnlyViewController: NeighborhoodDetailTopCellDelegate {
    func showMembers() {
        if let navVC = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodListUsersViewController {
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

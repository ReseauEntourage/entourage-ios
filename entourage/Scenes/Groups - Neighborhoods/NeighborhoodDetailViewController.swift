//
//  NeighborhoodDetailViewController.swift
//  entourage
//
//  Created by Jerome on 27/04/2022.
//

import UIKit
import IHProgressHUD

class NeighborhoodDetailViewController: UIViewController {
    
    @IBOutlet weak var ui_container_view: UIView!
    @IBOutlet weak var ui_viewtop_white_round: UIView!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_iv_neighborhood: UIImageView!
    
    var neighborhoodId:Int = 0
    var neighborhood:Neighborhood? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_container_view.addRadiusTopOnly(radius: ApplicationTheme.bigCornerRadius)
        
        ui_viewtop_white_round.addRadiusTopOnly(radius: ApplicationTheme.bigCornerRadius)
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: nil, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .clear, delegate: self, showSeparator: false, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        
        getNeighborhoodDetail()
        
        //Notif for updating neighborhood infos
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
            
            if let _url = self.neighborhood?.image_url, let url = URL(string: _url) {
                self.ui_iv_neighborhood.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_neighborhood"))
            }
            else {
                self.ui_iv_neighborhood.image = UIImage.init(named: "placeholder_neighborhood")
            }
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
        //neighborhood?.creator.uid = 2889 // TODO: a supp apres WS
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
extension NeighborhoodDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath) as! NeighborhoodDetailTopCell
            
            cell.populateCell(neighborhood: self.neighborhood, delegate: self)
            
            return cell
        }
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellEventEmpty", for: indexPath)
            
            return cell
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostEmpty", for: indexPath)
        
        return cell
    }
}

//MARK: - NeighborhoodDetailTopCellDelegate -
extension NeighborhoodDetailViewController: NeighborhoodDetailTopCellDelegate {
    func showMembers() {
        //TODO: a faire
        Logger.print("***** show membres")
        
        if let navVC = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodListUsersViewController {
            vc.neighborhood = neighborhood
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    func joinLeave() {
        joinLeaveGroup()
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

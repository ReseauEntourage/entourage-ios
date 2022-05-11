//
//  NeighborhoodDetailViewController.swift
//  entourage
//
//  Created by Jerome on 27/04/2022.
//

import UIKit
import IHProgressHUD

class NeighborhoodDetailViewController: UIViewController {
    
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_iv_neighborhood: UIImageView!
    @IBOutlet weak var ui_iv_neighborhood_mini: UIImageView!
    @IBOutlet weak var ui_label_title_neighb: UILabel!
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    
    var neighborhoodId:Int = 0
    var neighborhood:Neighborhood? = nil
    
    var maxViewHeight:CGFloat = 150
    var minViewHeight:CGFloat = 70 + 19
    
    var maxImageHeight:CGFloat = 73
    var minImageHeight:CGFloat = 0
    
    var viewNormalHeight:CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: nil, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .clear, delegate: self, showSeparator: false, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        ui_iv_neighborhood.image = nil
        getNeighborhoodDetail()
        
        //Notif for updating neighborhood infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateNeighborhood), name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
        
        setupViews()
    }
    
    func setupViews() {
        maxImageHeight = ui_iv_neighborhood.frame.height
        
        ui_view_height_constraint.constant = maxViewHeight
        viewNormalHeight = ui_view_height_constraint.constant
        
        let topPadding = ApplicationTheme.getTopIPhonePadding()
        let inset = UIEdgeInsets(top: viewNormalHeight - topPadding ,left: 0,bottom: 0,right: 0)
        minViewHeight = minViewHeight + topPadding - 20
        
        ui_tableview.contentInset = inset
        ui_tableview.scrollIndicatorInsets = inset
        
        ui_label_title_neighb.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_iv_neighborhood_mini.layer.cornerRadius = 8
        ui_iv_neighborhood_mini.layer.borderColor = UIColor.appOrangeLight.cgColor
        ui_iv_neighborhood_mini.layer.borderWidth = 1
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
                self.ui_iv_neighborhood_mini.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_neighborhood"))
            }
            else {
                self.ui_iv_neighborhood.image = UIImage.init(named: "placeholder_neighborhood")
                self.ui_iv_neighborhood_mini.image = UIImage.init(named: "placeholder_neighborhood")
            }
            
            self.ui_label_title_neighb.text = group?.name
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
    
    //MARK: - Method uiscrollview delegate -
    func scrollViewDidScroll( _ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0) {
            let yImage = self.maxImageHeight - (scrollView.contentOffset.y+self.maxImageHeight)
            let diffImage = (self.maxViewHeight - self.maxImageHeight)
            let heightImage = min(max (yImage -  diffImage,self.minImageHeight),self.maxImageHeight)
            
            self.ui_iv_neighborhood.alpha = heightImage / self.maxImageHeight
            
            self.ui_iv_neighborhood_mini.alpha = 1 - (heightImage / self.maxImageHeight)
            self.ui_label_title_neighb.alpha = 1 - (heightImage / self.maxImageHeight)
            
            let yView = self.viewNormalHeight - (scrollView.contentOffset.y + self.viewNormalHeight)
            let heightView = min(max (yView,self.minViewHeight),self.maxViewHeight)
            self.ui_view_height_constraint.constant = heightView
            
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - UITableViewDataSource / Delegate -
extension NeighborhoodDetailViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.neighborhood != nil ? 3 : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let userId = UserDefaults.currentUser?.sid
            if self.neighborhood!.isFollowingGroup(myId: userId) {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellTopMember", for: indexPath) as! NeighborhoodDetailTopCell
                
                cell.populateCell(neighborhood: self.neighborhood,isFollowingGroup: true, delegate: self)
                
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellTop", for: indexPath) as! NeighborhoodDetailTopCell
                
                cell.populateCell(neighborhood: self.neighborhood, isFollowingGroup: false, delegate: self)
                
                return cell
            }
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
        if let navVC = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodListUsersViewController {
            vc.neighborhood = neighborhood
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    func joinLeave() {
        joinLeaveGroup()
    }
    
    func showDetailFull() {
        let sb = UIStoryboard.init(name: "Neighborhood", bundle: nil)
        if let navvc = sb.instantiateViewController(withIdentifier: "neighborhoodDetailOnlyNav") as? UINavigationController, let vc = navvc.topViewController as? NeighborhoodDetailOnlyViewController {
            vc.neighborhoodId = self.neighborhoodId
            self.navigationController?.present(navvc, animated: true)
        }
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

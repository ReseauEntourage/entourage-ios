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
    
    var messagesNew = [PostMessage]()
    var messagesOld = [PostMessage]()
    
    var hasNewAndOldSections = false
    var currentPagingPage = 2 //Default 1 WS
    let itemsPerPage = 25 //Default WS
    
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
            self.splitMessages()
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
    
    func splitMessages() {
        //TODO: split messages depuis les infos du WS
        guard let messages = neighborhood?.messages else {
            return
        }

        messagesNew.removeAll()
        messagesOld.removeAll()
        var i = 0
        for post in messages {
            if i % 2 == 0 {
                messagesNew.append(post)
            }
            else {
                messagesOld.append(post)
            }
            i = i + 1
        }
        
        hasNewAndOldSections = messagesOld.count > 0 && messagesNew.count > 0
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
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let minimum = self.neighborhood != nil ? 2 : 0
        let added = hasNewAndOldSections ? 1 : 0
        return minimum + added
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 2 }
        
        if hasNewAndOldSections {
            var count = 0
            if section == 1 {
                count = messagesNew.count + 2
            }
            else {
                count = messagesOld.count + 1
            }
            return count
        }
        
        
        let messageCount:Int = (self.neighborhood?.messages?.count ?? 0) > 0 ? self.neighborhood!.messages!.count + 2 : 1
        return  messageCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if self.neighborhood!.isMember {
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
            else {
                if neighborhood?.futureEvents?.count ?? 0 > 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: "cellEvents", for: indexPath) as! NeighborhoodEventsTableviewCell
                    
                    cell.populateCell(events:neighborhood!.futureEvents!, delegate: self)
                    
                    
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellEventEmpty", for: indexPath)
                
                return cell
            }
        }
        
        
       
        if self.neighborhood?.messages?.count ?? 0 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostEmpty", for: indexPath)
            
            return cell
        }
        
        if hasNewAndOldSections && indexPath.section == 2 {
            if indexPath.row == 0 {
               //Todo: New / Old
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostTitleDate", for: indexPath) as! NeighborhoodPostHeadersCell
                
                cell.populateCell(title: "neighborhood_post_group_section_old_posts_title".localized, isTopHeader: false)
                return cell
            }
            
            let postmessage:PostMessage = messagesOld[indexPath.row - 1]
           
            //TODO: mettre le check de la cell avec l'image ou pas
            if indexPath.row % 2 == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostText", for: indexPath) as! NeighborhoodPostCell
                
                cell.populateCell(message: postmessage)
                return cell
            }
            
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostImage", for: indexPath) as! NeighborhoodPostCell
            cell.populateCell(message: postmessage)
            return cell
            
        }
        
        if indexPath.row == 0 {
           //TODO: Title
            
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostTitle", for: indexPath) as! NeighborhoodPostHeadersCell
            cell.populateCell(title: "neighborhood_post_group_section_title".localized, isTopHeader: true)
            return cell
        }
        
        if indexPath.row == 1 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostTitleDate", for: indexPath) as! NeighborhoodPostHeadersCell
            cell.populateCell(title: "neighborhood_post_group_section_new_posts_title".localized, isTopHeader: false)
            return cell
        }
        
        
        
        //TODO: voir si texte ou image
//        if self.neighborhood?.messages?[indexPath.row - 2].messageType == "text" {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostText", for: indexPath) as! NeighborhoodPostCell
//
//            return cell
//        }
//        else {
//            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostImage", for: indexPath) as! NeighborhoodPostCell
//
//            return cell
//        }
        let postmessage:PostMessage = hasNewAndOldSections ? self.messagesNew[indexPath.row - 2] : self.neighborhood!.messages![indexPath.row - 2]
       
        if indexPath.row % 2 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostText", for: indexPath) as! NeighborhoodPostCell
            
            cell.populateCell(message: postmessage)
            return cell
        }
        
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostImage", for: indexPath) as! NeighborhoodPostCell
        cell.populateCell(message: postmessage)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 214
        }
        return UITableView.automaticDimension
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

extension NeighborhoodDetailViewController:NeighborhoodEventsTableviewCellDelegate {
    func showAll() {
        //TODO: Show all events
        Logger.print("***** show all events ;)")
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

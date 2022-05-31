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
    
    @IBOutlet weak var ui_button_add: UIButton!
    //Use to strech header
    var maxViewHeight:CGFloat = 150
    var minViewHeight:CGFloat = 70 + 19
    var maxImageHeight:CGFloat = 73
    var minImageHeight:CGFloat = 0
    var viewNormalHeight:CGFloat = 0
    
    var messagesNew = [PostMessage]()
    var messagesOld = [PostMessage]()
    var neighborhoodId:Int = 0
    var neighborhood:Neighborhood? = nil
    
    var hasNewAndOldSections = false
    var currentPagingPage = 1 //Default WS
    let itemsPerPage = 25 //Default WS
    let nbOfItemsBeforePagingReload = 5
    var isLoading = false
    var isAfterCreation = true
    var isShowCreatePost = false
    
    var pullRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: nil, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .clear, delegate: self, showSeparator: false, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        ui_iv_neighborhood.image = UIImage.init(named: "placeholder_photo_group")
        
        registerCellsNib()
        
        //Notif for updating neighborhood infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateNeighborhood), name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
        
        setupViews()
        
        ui_button_add.isHidden = true
        
        getNeighborhoodDetail()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isShowCreatePost {
            showCreatePost()
            isShowCreatePost = false
        }
    }
    
    func registerCellsNib() {
        ui_tableview.register(UINib(nibName: NeighborhoodPostTextCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostTextCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostImageCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostImageCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodDetailTopCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodDetailTopCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodDetailTopMemberCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodDetailTopMemberCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodEmptyPostCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodEmptyPostCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodEmptyEventCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodEmptyEventCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodEventsTableviewCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodEventsTableviewCell.identifier)
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
        
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshNeighborhood), for: .valueChanged)
        ui_tableview.refreshControl = pullRefreshControl
        
        populateTopView()
    }
    
    func populateTopView() {
        let imageName = "placeholder_photo_group"
        if let _url = self.neighborhood?.image_url, let url = URL(string: _url) {
            self.ui_iv_neighborhood.sd_setImage(with: url, placeholderImage: UIImage.init(named: imageName))
            self.ui_iv_neighborhood_mini.sd_setImage(with: url, placeholderImage: UIImage.init(named: imageName))
        }
        else {
            self.ui_iv_neighborhood.image = UIImage.init(named: imageName)
            self.ui_iv_neighborhood_mini.image = UIImage.init(named: imageName)
        }
        
        self.ui_label_title_neighb.text = self.neighborhood?.name
        self.ui_button_add.isHidden = self.neighborhood?.isMember ?? false ? false : true
    }
    
    // Actions
    @objc private func refreshNeighborhood() {
        updateNeighborhood()
    }
    
    @objc func updateNeighborhood() {
        getNeighborhoodDetail()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Network -
    func getNeighborhoodDetail(hasToRefreshLists:Bool = false) {
        self.currentPagingPage = 1
        self.isLoading = true
        NeighborhoodService.getNeighborhoodDetail(id: neighborhoodId) { group, error in
            self.pullRefreshControl.endRefreshing()
            if let _ = error {
                self.goBack()
            }
            
            self.neighborhood = group
            self.splitMessages()
            self.ui_tableview.reloadData()
            self.isLoading = false
            
            self.populateTopView()
            
            if hasToRefreshLists {
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationNeighborhoodsUpdate), object: nil)
            }
        }
    }
    
    func getMorePosts() {
        self.isLoading = true
        NeighborhoodService.getNeighborhoodPostsPaging(id: neighborhoodId, currentPage: currentPagingPage, per: itemsPerPage) { post, error in
            if let post = post {
                self.neighborhood?.messages?.append(contentsOf: post)
                self.splitMessages()
                if self.hasNewAndOldSections {
                    UIView.performWithoutAnimation {
                        self.ui_tableview.reloadSections(IndexSet(integer: 2), with: .none)
                    }
                }
                else {
                    UIView.performWithoutAnimation {
                        self.ui_tableview.reloadSections(IndexSet(integer: 1), with: .none)
                    }
                }
                self.isLoading = false
            }
            //TODO: Error ?
        }
    }
    
    func splitMessages() {
        guard let messages = neighborhood?.messages else {
            return
        }
        
        messagesNew.removeAll()
        messagesOld.removeAll()
        
        for post in messages {
            if post.isRead {
                messagesOld.append(post)
            }
            else {
                messagesNew.append(post)
            }
        }
        
        hasNewAndOldSections = messagesOld.count > 0 && messagesNew.count > 0
    }
    
    func addRemoveMember(isAdd:Bool) {
        guard let neighborhood = neighborhood else {
            return
        }
        
        IHProgressHUD.show()
        
        if isAdd {
            NeighborhoodService.joinNeighborhood(groupId: neighborhood.uid) { user, error in
                IHProgressHUD.dismiss()
                if let user = user {
                    let member = NeighborhoodUserLight.init(uid: user.uid, username: user.username, imageUrl: user.imageUrl)
                    self.neighborhood?.members.append(member)
                    let count:Int = self.neighborhood?.membersCount != nil ? self.neighborhood!.membersCount + 1 : 1
                    
                    self.neighborhood?.membersCount = count
                    self.ui_tableview.reloadData()
                    self.getNeighborhoodDetail(hasToRefreshLists:true)
                }
            }
        }
        else {
            NeighborhoodService.leaveNeighborhood(groupId: neighborhood.uid, userId: UserDefaults.currentUser!.sid) { group, error in
                IHProgressHUD.dismiss()
                if error == nil {
                    self.neighborhood?.members.removeAll(where: {$0.uid == UserDefaults.currentUser!.sid})
                    let count:Int = self.neighborhood?.membersCount != nil ? self.neighborhood!.membersCount - 1 : 0
                    
                    self.neighborhood?.membersCount = count
                    
                    self.ui_tableview.reloadData()
                    self.getNeighborhoodDetail(hasToRefreshLists:true)
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
    
    //MARK: - IBAction -
    @IBAction func action_show_params(_ sender: Any) {
        if let navVC = UIStoryboard.init(name: "Neighborhood", bundle: nil).instantiateViewController(withIdentifier: "params_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighborhoodParamsGroupViewController {
            vc.neighborhood = neighborhood
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    @IBAction func action_create(_ sender: Any) {
        if let vc = UIStoryboard.init(name: "Neighborhood_Message", bundle: nil).instantiateViewController(withIdentifier: "AddMenuVC") as? NeighborhoodAddMenuViewController {
            vc.modalPresentationStyle = .overCurrentContext
            vc.neighborhoodId = self.neighborhoodId
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showCreatePost() {
        let sb = UIStoryboard.init(name: "Neighborhood_Message", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "addPostVC") as? NeighborhoodPostAddViewController  {
            vc.neighborhoodId = self.neighborhoodId
            self.navigationController?.present(vc, animated: true)
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
        
        let countToAdd = self.neighborhood?.isMember ?? false ? 2 : 1 //If not member we dont' show new/old post header
        let messageCount:Int = (self.neighborhood?.messages?.count ?? 0) > 0 ? self.neighborhood!.messages!.count + countToAdd : 1
        return  messageCount
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                if self.neighborhood!.isMember && !isAfterCreation {
                    let cell = tableView.dequeueReusableCell(withIdentifier: NeighborhoodDetailTopMemberCell.identifier, for: indexPath) as! NeighborhoodDetailTopMemberCell
                    cell.populateCell(neighborhood: self.neighborhood,isFollowingGroup: true, delegate: self)
                    return cell
                }
                else {
                    let cell = tableView.dequeueReusableCell(withIdentifier: NeighborhoodDetailTopCell.identifier, for: indexPath) as! NeighborhoodDetailTopCell
                    cell.populateCell(neighborhood: self.neighborhood, isFollowingGroup: false, delegate: self)
                    return cell
                }
            }
            else {
                if neighborhood?.futureEvents?.count ?? 0 > 0 {
                    let cell = tableView.dequeueReusableCell(withIdentifier: NeighborhoodEventsTableviewCell.identifier, for: indexPath) as! NeighborhoodEventsTableviewCell
                    cell.populateCell(events:neighborhood!.futureEvents!, delegate: self)
                    return cell
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: NeighborhoodEmptyEventCell.identifier, for: indexPath)
                return cell
            }
        }
        
        if self.neighborhood?.messages?.count ?? 0 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NeighborhoodEmptyPostCell.identifier, for: indexPath)
            return cell
        }
        
        if hasNewAndOldSections && indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostTitleDate", for: indexPath) as! NeighborhoodPostHeadersCell
                
                cell.populateCell(title: "neighborhood_post_group_section_old_posts_title".localized, isTopHeader: false)
                return cell
            }
            
            let postmessage:PostMessage = messagesOld[indexPath.row - 1]
            let identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
            cell.populateCell(message: postmessage,delegate: self)
            return cell
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostTitle", for: indexPath) as! NeighborhoodPostHeadersCell
            cell.populateCell(title: "neighborhood_post_group_section_title".localized, isTopHeader: true)
            return cell
        }
        
        //If not member we dont' show new/old post header
        let countToAdd = self.neighborhood?.isMember ?? false ? 2 : 1
        if countToAdd == 2 {
            if indexPath.row == 1 {
                let titleSection = hasNewAndOldSections ? "neighborhood_post_group_section_new_posts_title".localized : "neighborhood_post_group_section_old_posts_title".localized
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellPostTitleDate", for: indexPath) as! NeighborhoodPostHeadersCell
                cell.populateCell(title: titleSection , isTopHeader: false)
                return cell
            }
        }
        
        let postmessage:PostMessage = hasNewAndOldSections ? self.messagesNew[indexPath.row - countToAdd] : self.neighborhood!.messages![indexPath.row - countToAdd]
        
        let identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
        cell.populateCell(message: postmessage,delegate: self)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            return 214
        }
        return UITableView.automaticDimension
    }
    
    //Use to paging tableview ;)
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        
        var realIndex:Int
        
        if hasNewAndOldSections {
            realIndex = indexPath.row - 1
        }
        else {
            realIndex = indexPath.row - 2
        }
        
        let messageCount:Int = neighborhood?.messages?.count ?? 0
        
        let lastIndex = messageCount - nbOfItemsBeforePagingReload
        if realIndex == lastIndex && messageCount >= itemsPerPage * currentPagingPage {
            self.currentPagingPage = self.currentPagingPage + 1
            self.getMorePosts()
        }
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
            vc.delegate = self
            self.navigationController?.present(navvc, animated: true)
        }
    }
}

//MARK: - NeighborhoodPostCellDelegate -
extension NeighborhoodDetailViewController:NeighborhoodPostCellDelegate {
    func showMessages(addComment: Bool, postId:Int) {
        
        let sb = UIStoryboard.init(name: "Neighborhood_Message", bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? NeighborhoodDetailMessagesViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.parentCommentId = postId
            vc.neighborhoodId = neighborhoodId
            vc.neighborhoodName = neighborhood!.name
            vc.isGroupMember = neighborhood!.isMember
            vc.isStartEditing = addComment
            self.navigationController?.present(vc, animated: true)
        }
    }
}

//MARK: - NeighborhoodEventsTableviewCellDelegate -
extension NeighborhoodDetailViewController:NeighborhoodEventsTableviewCellDelegate {
    func showAll() {
        //TODO: Show all events
        Logger.print("***** show all events ;)")
        showWIP(parentVC: self)
    }
    
    func showEvent(eventId: Int) {
        Logger.print("***** show event id : \(eventId)")
        //TODO: a faire
        showWIP(parentVC: self)
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

extension NeighborhoodDetailViewController:NeighborhoodDetailViewControllerDelegate {
    func refreshNeighborhoodModified() {
        self.getNeighborhoodDetail(hasToRefreshLists:true)
    }
}

protocol NeighborhoodDetailViewControllerDelegate: AnyObject {
    func refreshNeighborhoodModified()
}
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
    
    @IBOutlet weak var ui_constraint_button: NSLayoutConstraint!
    @IBOutlet weak var ui_floaty_button: Floaty!
    
    @IBOutlet weak var ui_view_full_image: UIView!
    @IBOutlet weak var ui_scrollview: UIScrollView!
    @IBOutlet weak var ui_iv_preview: UIImageView!
    
    //Use to strech header
    var maxViewHeight:CGFloat = 150
    var minViewHeight:CGFloat = 80//70 + 19
    var maxImageHeight:CGFloat = 73
    var minImageHeight:CGFloat = 0
    var viewNormalHeight:CGFloat = 0

    
    var messagesNew = [PostMessage]()
    var messagesOld = [PostMessage]()
    var neighborhoodId:Int = 0
    var hashedNeighborhoodId:String = ""
    var neighborhood:Neighborhood? = nil
    
    var hasNewAndOldSections = false
    var currentPagingPage = 1 //Default WS
    let itemsPerPage = 25 //Default WS
    let nbOfItemsBeforePagingReload = 5
    var isLoading = false
    var isAfterCreation = true
    var isShowCreatePost = false
    
    let DELETED_POST_CELL_SIZE = 165.0
    let TEXT_POST_CELL_SIZE = 220.0
    let IMAGE_POST_CELL_SIZE = 430.0
    //226 deleted message
    //470 text post message
    //165 image post message
    
    var pullRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: nil, titleFont: nil, titleColor: nil, imageName: nil, backgroundColor: .clear, delegate: self, showSeparator: false, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        ui_iv_neighborhood.image = UIImage.init(named: "placeholder_photo_group")
        
        registerCellsNib()
        
        setupViews()
        ui_floaty_button.isHidden = true
        AnalyticsLoggerManager.logEvent(name: View_GroupFeed__Show)
        
        setupFloatingButton()
        
        self.ui_view_full_image.isHidden = true
        self.ui_scrollview.delegate = self
        self.ui_scrollview.maximumZoomScale = 10
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isShowCreatePost {
            showCreatePost()
            isShowCreatePost = false
        }
        self.getNeighborhoodDetail(hasToRefreshLists:true)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromCreateEvent), name: NSNotification.Name(rawValue: kNotificationEventCreateEnd), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showNewEvent(_:)), name: NSNotification.Name(rawValue: kNotificationCreateShowNewEvent), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFromLeave), name: NSNotification.Name(rawValue: kNotificationUpdateFromLeave), object: nil)
        
        let storyboard = UIStoryboard(name: "Neighborhood", bundle: nil) // Remplace "Main" par le nom de ton Storyboard
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.post(name: NSNotification.Name("FermerReactionsPopup"), object: nil)
    }

    
    func registerCellsNib() {
        ui_tableview.register(UINib(nibName: NeighborhoodPostTextCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostTextCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostSurveyCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostSurveyCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostImageCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostImageCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostDeletedCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostDeletedCell.identifier)

        ui_tableview.register(UINib(nibName: NeighborhoodDetailTopCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodDetailTopCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodDetailTopMemberCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodDetailTopMemberCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodEmptyPostCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodEmptyPostCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostTranslationCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostTranslationCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostImageTranslationCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostImageTranslationCell.identifier)

        ui_tableview.register(UINib(nibName: NeighborhoodEmptyEventCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodEmptyEventCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodEventsTableviewCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodEventsTableviewCell.identifier)
        ui_tableview.register(UINib(nibName: EventListSectionCell.identifier, bundle: nil), forCellReuseIdentifier: EventListSectionCell.identifier)
        ui_tableview.register(UINib(nibName: EventListSectionCell.neighborhoodHeaderIdentifier, bundle: nil), forCellReuseIdentifier: EventListSectionCell.neighborhoodHeaderIdentifier)
        
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
        self.ui_floaty_button?.isHidden = self.neighborhood?.isMember ?? false ? false : true
    }
    
    func setupFloatingButton() {
        let floatItem1 = createButtonItem(title: "neighborhood_menu_post_event".localized, iconName: "ic_menu_button_create_event") { item in
            self.showCreateEvent()
        }
        
        let floatItem2 = createButtonItem(title: "neighborhood_menu_post_survey".localized, iconName: "ic_survey_creation") { item in
            self.showCreateSurvey()
        }
        
        let floatItem3 = createButtonItem(title: "neighborhood_menu_post_post".localized, iconName: "ic_menu_button_create_post") { item in
            AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_NewPost)
            self.showCreatePost()
        }
        
        ui_floaty_button.overlayColor = .white.withAlphaComponent(0.10)
        ui_floaty_button.addBlurOverlay = true
        ui_floaty_button.itemSpace = 24
        ui_floaty_button.addItem(item: floatItem3)
        ui_floaty_button.addItem(item: floatItem2)
        ui_floaty_button.addItem(item: floatItem1)
        ui_floaty_button.sticky = true
        ui_floaty_button.animationSpeed = 0.3
        ui_floaty_button.fabDelegate = self


    }


    
    // Actions
    @objc func showNewEvent(_ notification:Notification) {
        if let eventId = notification.userInfo?[kNotificationEventShowId] as? Int {
            Logger.print("***** ShowNewEvent  : \(eventId)")
            DispatchQueue.main.async {
                //TODO: afficher détail de
                self.showEvent(eventId: eventId, isAfterCreation: true)
            }
        }
    }
    
    @objc private func updateFromCreateEvent() {
        updateNeighborhood()
    }
    @objc func updateFromLeave() {
        updateNeighborhood()
    }
    
    @objc private func refreshNeighborhood() {
        updateNeighborhood()
    }
    
    @objc func updateNeighborhood() {
        self.getNeighborhoodDetail(hasToRefreshLists:true)
    }

    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Network -
    func getNeighborhoodDetail(hasToRefreshLists:Bool = false) {

        self.currentPagingPage = 1
        self.isLoading = true
        var _groupId = ""
        if neighborhoodId != 0 {
            _groupId = String(neighborhoodId)
        }else if hashedNeighborhoodId != "" {
            _groupId = hashedNeighborhoodId
        }
        
        NeighborhoodService.getNeighborhoodDetail(id: _groupId) { group, error in
            self.pullRefreshControl.endRefreshing()
            
            if let _ = error {
                self.goBack()
            }
            if group == nil {
                let alertController = UIAlertController(title: "Attention", message: "Ce groupe a été supprimé", preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Fermer", style: .default, handler: nil)
                alertController.addAction(closeAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
            self.neighborhood = group
            self.splitMessages()
            self.ui_tableview.reloadData()
            self.isLoading = false
            self.populateTopView()
            self.neighborhood?.messages?.removeAll()
            self.getMorePosts()
            if hasToRefreshLists {
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationNeighborhoodsUpdate), object: nil)
            }
        }
    }
    
    func getMorePosts() {
        self.isLoading = true
        NeighborhoodService.getNeighborhoodPostsPaging(id: neighborhoodId, currentPage: currentPagingPage, per: itemsPerPage) { post, error in
            guard let post = post, error == nil else {
                // Gérer l'erreur ici si nécessaire
                self.isLoading = false
                return
            }

            DispatchQueue.main.async {
                // Mettre à jour les données
                self.neighborhood?.messages?.append(contentsOf: post)
                self.splitMessages()

                // Recharger la table view
                self.ui_tableview.reloadData()
                self.isLoading = false
            }
        }
    }


    
    func splitMessages() {
        guard let messages = neighborhood?.messages else {
            return
        }
        
        messagesNew.removeAll()
        messagesOld.removeAll()
        
        for post in messages {
            messagesOld.append(post)
//
//            if post.isRead {
//                messagesOld.append(post)
//            }
//            else {
//                messagesNew.append(post)
//            }
        }
        
        hasNewAndOldSections = messagesOld.count > 0 && messagesNew.count > 0
    }
    
    func addRemoveMember(isAdd:Bool) {
        guard let neighborhood = neighborhood else {
            return
        }
        if isAdd {
            IHProgressHUD.show()

            if (/*(UserDefaults.currentUser?.isAmbassador()) != nil*/ false){
                if let popupVC = storyboard?.instantiateViewController(withIdentifier: "ambassadorAskNotificationPopup") as? AmbassadorAskNotificationPopup {
                    popupVC.delegate = self
                    popupVC.modalPresentationStyle = .overFullScreen // Ajuster le style de présentation si nécessaire
                    popupVC.modalTransitionStyle = .crossDissolve // Ajuster la transition si nécessaire
                    present(popupVC, animated: true, completion: nil)
                }

            }else{
                NeighborhoodService.joinNeighborhood(groupId: neighborhood.uid) { user, error in
                    IHProgressHUD.dismiss()
                    if let user = user {
                        let member = MemberLight.init(uid: user.uid, username: user.username, imageUrl: user.imageUrl)
                        self.neighborhood?.members.append(member)
                        self.neighborhood?.isMember = true
                        let count:Int = self.neighborhood?.membersCount != nil ? self.neighborhood!.membersCount + 1 : 1
                        self.isAfterCreation = true
                        self.neighborhood?.membersCount = count
                        self.getNeighborhoodDetail()
                        self.showWelcomeMessage()
                    }
                }
            }
        }
        else {
            showPopLeave()
        }
    }
    
    func showWelcomeMessage(){
        //I_present_view_pop
        AnalyticsLoggerManager.logEvent(name: I_present_view_pop)

        let title = "welcome_message_title".localized
        let btnTitle = "welcome_message_btn_title".localized
        var message = "welcome_message_placeholder".localized
        if self.neighborhood?.welcomeMessage != nil
            && self.neighborhood?.welcomeMessage != ""
            && neighborhood != nil
        {
            message = (neighborhood?.welcomeMessage)!
        }
        let alertVC = MJAlertController()
        let buttonWelcome = MJAlertButtonType(title: btnTitle, titleStyle:ApplicationTheme.getFontH1Blanc(size: 15), bgColor: .appOrange, cornerRadius: -1)
        alertVC.alertTagName = .welcomeMessage
        
        alertVC.configureAlert(alertTitle: title, message: message, buttonrightType: buttonWelcome, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: false)
        alertVC.delegate = self
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
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
                self.getNeighborhoodDetail(hasToRefreshLists:true)

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
    }
    
    //MARK: - IBAction -
    @IBAction func action_show_params(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_Option)
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "params_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighborhoodParamsGroupViewController {
            vc.neighborhood = neighborhood
            vc.dismissDelegate = self
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    @IBAction func action_tap_close_full_image(_ sender: Any) {
        ui_view_full_image.isHidden = true
    }
    
    //MARK: - Method uiscrollview delegate -
    
    func scrollViewDidScroll( _ scrollView: UIScrollView) {
        NotificationCenter.default.post(name: Notification.Name("FermerReactionsPopup"), object: nil)

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
    
    //MARK: - Nav VCs-
    func showCreatePost() {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhoodMessage, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "addPostVC") as? NeighborhoodPostAddViewController  {
            vc.neighborhoodId = self.neighborhoodId
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showCreateSurvey() {
        let sb = UIStoryboard.init(name: StoryboardName.survey, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "create_survey") as? CreateSurveyViewController  {
            vc.groupId = self.neighborhoodId
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    
    func showCreateEvent() {
        //TODO: a faire lien vers la créa d'event
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_NewEvent)
        let vc = UIStoryboard.init(name: StoryboardName.eventCreate, bundle: nil).instantiateViewController(withIdentifier: "eventCreateVCMain") as! EventCreateMainViewController
        vc.parentController = self.navigationController
        vc.modalPresentationStyle = .fullScreen
        vc.currentNeighborhoodId = neighborhood?.uid
        self.navigationController?.present(vc, animated: true)
    }
    
}

//MARK: - MJAlertControllerDelegate -
extension NeighborhoodDetailViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {
        AnalyticsLoggerManager.logEvent(name: i_present_close_pop)

    }
    
    func validateRightButton(alertTag:MJAlertTAG) {
        self.getNeighborhoodDetail(hasToRefreshLists:true)
        AnalyticsLoggerManager.logEvent(name: I_present_click_i_post)
        showCreatePost()

    }
    func closePressed(alertTag:MJAlertTAG) {
        AnalyticsLoggerManager.logEvent(name: I_present_click_i_post)
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
        
        let messageCount:Int = (self.neighborhood?.messages?.count ?? 0) > 0 ? self.neighborhood!.messages!.count + countToAdd() : 1
        return  messageCount
    }
    
    func resetView() {
        DispatchQueue.main.async {
            // Supprimer toutes les sous-vues et les recharger
            for subview in self.view.subviews {
                subview.removeFromSuperview()
            }
            self.viewDidLoad()
            self.viewWillAppear(false)
            self.viewDidAppear(false)
        }
    }
    
    func countToAdd() -> Int {
        //Is member + new posts
        let countToAdd = (self.neighborhood?.isMember ?? false && self.messagesNew.count > 0) ? 2 : 1 //If not member or only old messages we dont' show new/old post header
        return countToAdd
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let neighborhood = self.neighborhood else {
            return UITableViewCell()
        }

        if indexPath.section >= numberOfSections(in: tableView) || indexPath.row >= tableView.numberOfRows(inSection: indexPath.section) {
            resetView()
            AnalyticsLoggerManager.logEvent(name: crash_from_incorrect_cell_number)
            return UITableViewCell()
        }

        if indexPath.section == 0 {
            if indexPath.row == 0 {
                let isMember = neighborhood.isMember
                let identifier = isMember ? NeighborhoodDetailTopCell.identifier : NeighborhoodDetailTopCell.identifier
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                if isMember, let memberCell = cell as? NeighborhoodDetailTopMemberCell {
                    memberCell.populateCell(neighborhood: neighborhood, isFollowingGroup: true, isFromOnlyDetail: false, delegate: self)
                } else if let topCell = cell as? NeighborhoodDetailTopCell {
                    topCell.populateCell(neighborhood: neighborhood, isFollowingGroup: false, isFromOnlyDetail: false, delegate: self)
                }
                return cell
            } else {
                let events = neighborhood.futureEvents ?? []
                let identifier = events.count > 0 ? NeighborhoodEventsTableviewCell.identifier : NeighborhoodEmptyEventCell.identifier
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                if events.count > 0, let eventsCell = cell as? NeighborhoodEventsTableviewCell {
                    eventsCell.populateCell(events: events, delegate: self)
                }
                return cell
            }
        }

        if neighborhood.messages?.count ?? 0 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NeighborhoodEmptyPostCell.identifier, for: indexPath)
            return cell
        }

        if hasNewAndOldSections && indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.identifier, for: indexPath) as! EventListSectionCell
                cell.populateCell(title: "neighborhood_post_group_section_old_posts_title".localized, isTopHeader: false)
                return cell
            }
            
            if indexPath.row - 1 < messagesOld.count {
                let postmessage = messagesOld[indexPath.row - 1]
                var identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
                
                if !(postmessage.contentTranslations?.from_lang == LanguageManager.getCurrentDeviceLanguage() || UserDefaults.currentUser?.sid == postmessage.user?.sid) {
                    identifier = postmessage.isPostImage ? NeighborhoodPostImageTranslationCell.identifier : NeighborhoodPostTranslationCell.identifier
                }
                
                if(postmessage.contentTranslations == nil){
                    identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
                }
                if postmessage.survey != nil {
                    identifier = NeighborhoodPostSurveyCell.identifier
                }
                if postmessage.status == "deleted" || postmessage.status == "offensive" || postmessage.status == "offensible" {
                    identifier = NeighborhoodPostDeletedCell.identifier
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
                cell.populateCell(message: postmessage,delegate: self,currentIndexPath: indexPath, userId: postmessage.user?.sid, isMember: self.neighborhood?.isMember)
                return cell
            } else {
                return UITableViewCell()
            }
        }

        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.neighborhoodHeaderIdentifier, for: indexPath) as! EventListSectionCell
            cell.populateCell(title: "neighborhood_post_group_section_title".localized, isTopHeader: true)
            return cell
        }

        let countToAdd = countToAdd()
        if countToAdd == 2 && indexPath.row == 1 {
            let titleSection = hasNewAndOldSections || self.messagesOld.count == 0 ? "neighborhood_post_group_section_new_posts_title".localized : "neighborhood_post_group_section_old_posts_title".localized

            let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.identifier, for: indexPath) as! EventListSectionCell
            cell.populateCell(title: titleSection , isTopHeader: false)
            return cell
        }

        if hasNewAndOldSections {
            if indexPath.row - countToAdd < self.messagesNew.count {
                let postmessage = self.messagesNew[indexPath.row - countToAdd]
                var identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
                
                if !(postmessage.contentTranslations?.from_lang == LanguageManager.getCurrentDeviceLanguage() || UserDefaults.currentUser?.sid == postmessage.user?.sid) {
                    identifier = postmessage.isPostImage ? NeighborhoodPostImageTranslationCell.identifier : NeighborhoodPostTranslationCell.identifier
                }
                if(postmessage.contentTranslations == nil){
                    identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
                }
                if postmessage.survey != nil {
                    identifier = NeighborhoodPostSurveyCell.identifier
                }
                if postmessage.status == "deleted" || postmessage.status == "offensive" || postmessage.status == "offensible" {
                    identifier = NeighborhoodPostDeletedCell.identifier
                }
                let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
                cell.populateCell(message: postmessage,delegate: self,currentIndexPath: indexPath, userId: postmessage.user?.sid, isMember: self.neighborhood?.isMember)
                return cell
            } else {
                return UITableViewCell()
            }
        }

        if let messages = neighborhood.messages, indexPath.row - countToAdd < messages.count {
            let postmessage = messages[indexPath.row - countToAdd]
            var identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
           
            if !(postmessage.contentTranslations?.from_lang == LanguageManager.getCurrentDeviceLanguage() || UserDefaults.currentUser?.sid == postmessage.user?.sid) {
                identifier = postmessage.isPostImage ? NeighborhoodPostImageTranslationCell.identifier : NeighborhoodPostTranslationCell.identifier
            }
            if(postmessage.contentTranslations == nil){
                identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
            }
            if postmessage.survey != nil {
                identifier = NeighborhoodPostSurveyCell.identifier
            }
            if postmessage.status == "deleted" || postmessage.status == "offensive" || postmessage.status == "offensible" {
                identifier = NeighborhoodPostDeletedCell.identifier
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
            cell.populateCell(message: postmessage,delegate: self,currentIndexPath: indexPath, userId: postmessage.user?.sid, isMember: self.neighborhood?.isMember)
            return cell
        }

        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Vérifie si la cellule est HomeEventHorizontalCollectionCell
        if indexPath.section == 0 && indexPath.row == 1 {
            return 265
        } else {
            return UITableView.automaticDimension
        }
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
    func updateHeightCell() {
        self.ui_tableview.beginUpdates()
        self.ui_tableview.endUpdates()
    }
    
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
    
    func showWebUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
    
    func showMembers() {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_MoreMembers)
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.neighborhood = neighborhood
            self.navigationController?.present(navVC, animated: true)
        }
    }
    func showMemberReact(postId:Int){
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.neighborhood = neighborhood
            vc.postId = postId
            vc.groupId = neighborhoodId
            vc.isFromReact = true
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    func updatedPostWithReaction(originalPost: PostMessage, reactionId: Int, addReaction: Bool) -> PostMessage {
        var updatedReactions = originalPost.reactions ?? []

        if addReaction {
            // Ajouter une réaction
            if let index = updatedReactions.firstIndex(where: { $0.reactionId == reactionId }) {
                updatedReactions[index].reactionsCount += 1
            } else {
                let newReaction = Reaction(reactionId: reactionId, chatMessageId: originalPost.uid, reactionsCount: 1)
                updatedReactions.append(newReaction)
            }
        } else {
            // Supprimer une réaction
            if let index = updatedReactions.firstIndex(where: { $0.reactionId == reactionId }) {
                if updatedReactions[index].reactionsCount > 1 {
                    updatedReactions[index].reactionsCount -= 1
                } else {
                    updatedReactions.remove(at: index)
                }
            }
        }

        var updatedPost = originalPost
        updatedPost.reactions = updatedReactions
        return updatedPost
    }
    func replacePostInArray(post: PostMessage) {
        if let indexNew = messagesNew.firstIndex(where: { $0.uid == post.uid }) {
            messagesNew[indexNew] = post
        } else if let indexOld = messagesOld.firstIndex(where: { $0.uid == post.uid }) {
            messagesOld[indexOld] = post
        }
    }

    
    func joinLeave() {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_Join)
        joinLeaveGroup()
    }
    
    func showDetailFull() {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_MoreDescription)
        let sb = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil)
        if let navvc = sb.instantiateViewController(withIdentifier: "neighborhoodDetailOnlyNav") as? UINavigationController, let vc = navvc.topViewController as? NeighborhoodDetailOnlyViewController {
            vc.neighborhoodId = self.neighborhoodId
            vc.delegate = self
            self.navigationController?.present(navvc, animated: true)
        }
    }
    func showVote(post:PostMessage){
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.neighborhood = self.neighborhood
            vc.survey = post.survey
            vc.questionTitle = post.content
            vc.postId = post.uid
            vc.isFromSurvey = true
            vc.groupId = self.neighborhoodId
            vc.isFromReact = false
            self.navigationController?.present(navVC, animated: true)
        }
    }
}

//MARK: - NeighborhoodPostCellDelegate -
extension NeighborhoodDetailViewController:NeighborhoodPostCellDelegate {
    func sendVoteView(post: PostMessage) {
        self.showVote(post: post)
    }
    
    func postSurveyResponse(forPostId postId: Int, withResponses responses: [Bool]) {
        let groupId = self.neighborhoodId
        
        SurveyService.postSurveyResponseGroup(groupId: groupId, postId: postId, responses: responses) { isSuccess in
            if isSuccess {
                print("Réponse au sondage postée avec succès.")
            } else {
                print("Échec du postage de la réponse au sondage.")
            }
        }
    }
    
    func ifNotMemberWarnUser() {
        let alertController = UIAlertController(title: "Attention", message: "Vous devez rejoindre le groupe pour effectuer cette action.", preferredStyle: .alert)
                
                let okAction = UIAlertAction(title: "OK", style: .default) { action in
                    // Code à exécuter lorsque l'utilisateur touche le bouton OK
                    // Tu peux le laisser vide si tu ne veux rien faire de spécial
                }
                
                alertController.addAction(okAction)
                
                // Présenter l'alerte à l'utilisateur
                present(alertController, animated: true, completion: nil)
    }
    
    func onReactClickSeeMember(post: PostMessage) {
        showMemberReact(postId: post.uid)
    }
    
    func addReaction(post: PostMessage, reactionType: ReactionType) {
        var reactionWrapper = ReactionWrapper()
        reactionWrapper.reactionId = reactionType.id
        NeighborhoodService.postReactionToGroupPost(groupId: self.neighborhoodId, postId: post.uid, reactionWrapper: reactionWrapper) { error in
            if error == nil {
//                let updatedPost = self.updatedPostWithReaction(originalPost: post, reactionId: reactionType.id, addReaction: true)
//                self.replacePostInArray(post: updatedPost)
//                self.ui_tableview.reloadData()
            }
        }
    }

    func deleteReaction(post: PostMessage, reactionType: ReactionType) {
        NeighborhoodService.deleteReactionToGroupPost(groupId: self.neighborhoodId, postId: post.uid) { error in
            if error == nil {
//                let updatedPost = self.updatedPostWithReaction(originalPost: post, reactionId: reactionType.id, addReaction: false)
//                self.replacePostInArray(post: updatedPost)
//                self.ui_tableview.reloadData()
            }
        }
    }

    
    func showWebviewUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
    
    func showImage(imageUrl: URL?, postId: Int) {
        getDetailPost(neighborhoodId: self.neighborhoodId, parentPostId: postId)
    }
    
    func signalPost(postId: Int, userId:Int, textString:String) {
        if let navvc = UIStoryboard.init(name: StoryboardName.neighborhoodReport, bundle: nil).instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController, let vc = navvc.topViewController as? ReportGroupMainViewController {
            vc.groupId = neighborhoodId
            vc.postId = postId
            vc.parentDelegate = self
            vc.userId = userId
            vc.signalType = .publication
            vc.textString = textString
            self.present(navvc, animated: true)
        }
        
    }
    
    func showMessages(addComment: Bool, postId:Int, indexPathSelected: IndexPath?,postMessage:PostMessage?) {
        
        let sb = UIStoryboard.init(name: StoryboardName.neighborhoodMessage, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? NeighborhoodDetailMessagesViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.parentCommentId = postId
            vc.neighborhoodId = neighborhoodId
            vc.neighborhoodName = neighborhood!.name
            vc.isGroupMember = neighborhood!.isMember
            vc.isStartEditing = addComment
            vc.selectedIndexPath = indexPathSelected
            vc.parentDelegate = self
            vc.postMessage = postMessage
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showUser(userId:Int?) {
        guard let userId = userId else {
            return
        }
        if let navVC = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil).instantiateViewController(withIdentifier: "profileFull") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? ProfilFullViewController {
                _homeVC.userIdToDisplay = "\(userId)"
                self.navigationController?.present(navVC, animated: true)
            }
        }
    }
    
}

//MARK: - NeighborhoodEventsTableviewCellDelegate -
extension NeighborhoodDetailViewController:NeighborhoodEventsTableviewCellDelegate {
    func showAll() {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_MoreEvents)
        
        if let navVC = storyboard?.instantiateViewController(withIdentifier: "navListEvents") as? UINavigationController, let vc = navVC.topViewController as? NeighborhoodListEventsViewController  {
            vc.neighborhood = neighborhood
            navVC.modalPresentationStyle = .fullScreen
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    func showEvent(eventId: Int, isAfterCreation:Bool) {
        Logger.print("***** show event id : \(eventId)")
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_OneEvent)
        if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController, let vc = navVc.topViewController as? EventDetailFeedViewController  {
            vc.eventId = eventId
            vc.event = nil
            vc.isAfterCreation = isAfterCreation
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(navVc, animated: true, completion: nil)
            return
        }
    }
}

//MARK: - UpdateEventCommentDelegate -
extension NeighborhoodDetailViewController:UpdateCommentCountDelegate {
    func updateCommentCount(parentCommentId: Int, nbComments: Int, currentIndexPathSelected:IndexPath?) {
        guard let _ = neighborhood?.messages else {return}
        
        var i = 0
        for _post in neighborhood!.messages! {
            if _post.uid == parentCommentId {
                neighborhood!.messages![i].commentsCount = nbComments
                break
            }
            i = i + 1
        }
        self.splitMessages()
        if let currentIndexPathSelected = currentIndexPathSelected {
            self.ui_tableview.reloadRows(at: [currentIndexPathSelected], with: .none)
        } else {
            self.ui_tableview.reloadData()
        }
    }
}

//MARK: - FloatyDelegate -
extension NeighborhoodDetailViewController:FloatyDelegate {
    func floatyWillOpen(_ floaty: Floaty) {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_Plus)
        // Modifier la contrainte en fonction de la direction du texte
        let newHeight: CGFloat = UIView.userInterfaceLayoutDirection(for: self.view.semanticContentAttribute) == .rightToLeft ? 170 : 16

        // Animer le changement de contrainte
        UIView.animate(withDuration: 0.3) {
            self.ui_constraint_button.constant = newHeight
            self.view.layoutIfNeeded()
        }
    }
    
    func floatyClosed(_ floaty: Floaty) {
        let newHeight: CGFloat = UIView.userInterfaceLayoutDirection(for: self.view.semanticContentAttribute) == .rightToLeft ? 16 : 16

        // Animer le changement de contrainte
        UIView.animate(withDuration: 0.3) {
            self.ui_constraint_button.constant = newHeight
            self.view.layoutIfNeeded()
        }
    }
    
    private func createButtonItem(title:String, iconName:String, handler:@escaping ((FloatyItem) -> Void)) -> FloatyItem {
        let floatyItem = FloatyItem()
        floatyItem.buttonColor = .clear
        floatyItem.icon = UIImage(named: iconName)
        floatyItem.titleLabel.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 15))
        floatyItem.titleShadowColor = .clear
        floatyItem.title = title
        floatyItem.imageSize = CGSize(width: 62, height: 62)
        floatyItem.handler = handler
        return floatyItem
    }
}

//MARK: - MJNavBackViewDelegate -
extension NeighborhoodDetailViewController: MJNavBackViewDelegate {
    func goBack() {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_BackArrow)
        self.navigationController?.dismiss(animated: true)
        
    }
}

extension NeighborhoodDetailViewController:NeighborhoodDetailViewControllerDelegate {
    func refreshNeighborhoodModified() {
        self.getNeighborhoodDetail(hasToRefreshLists:true)

    }
}

//MARK: - UIScrollViewDelegate -
extension NeighborhoodDetailViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.ui_iv_preview
    }
}
extension NeighborhoodDetailViewController:GroupDetailDelegate{
    func translateItem(id: Int) {
        //TODO TRANSLATE
    }
    
    func publicationDeleted() {
        self.getNeighborhoodDetail(hasToRefreshLists:true)
        self.ui_tableview.reloadData()
    }
    
    func showMessage(signalType:GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let title = signalType == .comment ? "report_comment_title".localized : "report_publication_title".localized
        
        alertVC.configureAlert(alertTitle: title, message: "report_group_message_success".localized, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
    }
}


protocol NeighborhoodDetailViewControllerDelegate: AnyObject {
    func refreshNeighborhoodModified()
}

extension NeighborhoodDetailViewController{
    func getDetailPost(neighborhoodId:Int, parentPostId:Int){
        NeighborhoodService.getDetailPostMessage(neighborhoodId: neighborhoodId, parentPostId: parentPostId) { message, error in
            if let _message = message {
                self.setImageForView(message: _message)
            }
        }
    }
    func setImageForView(message:PostMessage){
        guard let urlString = message.messageImageUrl else {
            return
        }
        guard let imageUrl = URL(string: urlString) else {
            return
        }
        
        ui_scrollview.zoomScale = 1.0
        
        ui_iv_preview.sd_setImage(with: imageUrl, placeholderImage: nil, options: .refreshCached) { _image, _error, _type, _ur in
            if _error != nil {
                self.ui_view_full_image.isHidden = true
            }
            else {
                self.ui_view_full_image.isHidden = false
            }
        }
    }
}

extension NeighborhoodDetailViewController:NeighborhoodParamDismissDelegate{
    func onDismiss() {
        self.getNeighborhoodDetail()
    }
}

extension NeighborhoodDetailViewController:CreateSurveyValidationDelegate{
    func onSurveyCreate() {
        self.getNeighborhoodDetail()
    }
}

extension NeighborhoodDetailViewController:AmbassadorAskNotificationPopupDelegate{
    func joinAsOrganizer() {
        NeighborhoodService.joinNeighborhood(groupId: neighborhood?.uid ?? 0) { user, error in
            IHProgressHUD.dismiss()
            if let user = user {
                let member = MemberLight.init(uid: user.uid, username: user.username, imageUrl: user.imageUrl)
                self.neighborhood?.members.append(member)
                self.neighborhood?.isMember = true
                let count:Int = self.neighborhood?.membersCount != nil ? self.neighborhood!.membersCount + 1 : 1
                self.isAfterCreation = true
                self.neighborhood?.membersCount = count
                self.getNeighborhoodDetail()
                self.showWelcomeMessage()
            }
        }
    }
    
    func justParticipate() {
        NeighborhoodService.joinNeighborhood(groupId: neighborhood?.uid ?? 0) { user, error in
            IHProgressHUD.dismiss()
            if let user = user {
                let member = MemberLight.init(uid: user.uid, username: user.username, imageUrl: user.imageUrl)
                self.neighborhood?.members.append(member)
                self.neighborhood?.isMember = true
                let count:Int = self.neighborhood?.membersCount != nil ? self.neighborhood!.membersCount + 1 : 1
                self.isAfterCreation = true
                self.neighborhood?.membersCount = count
                self.getNeighborhoodDetail()
                self.showWelcomeMessage()
            }
        }
    }
    
    
}

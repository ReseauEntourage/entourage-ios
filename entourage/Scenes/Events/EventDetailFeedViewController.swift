//
//  EventDetailFeedViewController.swift
//  entourage
//
//  Created by Jerome on 08/07/2022.
//

import UIKit
import IHProgressHUD
import SDWebImage
import EventKit
import EventKitUI

class EventDetailFeedViewController: UIViewController {
    
    @IBOutlet weak var ui_lbl_canceled: UILabel!
    @IBOutlet weak var ui_view_canceled: UIView!
    @IBOutlet weak var ui_view_top_bg: UIView!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_iv_event: UIImageView!
    @IBOutlet weak var ui_iv_event2: UIImageView!
    @IBOutlet weak var ui_iv_event_mini: UIImageView!
    @IBOutlet weak var ui_label_title_event: UILabel!
    @IBOutlet weak var ui_view_height_constraint: NSLayoutConstraint!
    
    @IBOutlet weak var ui_view_button_back: UIView!
    @IBOutlet weak var ui_view_button_settings: UIView!
    @IBOutlet weak var ui_floaty_button: UIButton!
    
    //To show/hide button join on scroll
    @IBOutlet weak var ui_title_bt_join: UILabel!
    @IBOutlet weak var ui_bt_floating_join: UIView!
    let addHeight:CGFloat = ApplicationTheme.iPhoneHasNotch() ? 0 : 20
    var minTopScrollHeight:CGFloat = 120
    
    //Use to strech header
    var maxViewHeight:CGFloat = 150
    var minViewHeight:CGFloat = 80//70 + 19
    var maxImageHeight:CGFloat = 73
    var minImageHeight:CGFloat = 0
    var viewNormalHeight:CGFloat = 0
    
    var messagesNew = [PostMessage]()
    var messagesOld = [PostMessage]()
    var eventId:Int = 0
    var event:Event? = nil
    
    var hasNewAndOldSections = false
    var currentPagingPage = 1 //Default WS
    let itemsPerPage = 25 //Default WS
    let nbOfItemsBeforePagingReload = 5
    var isLoading = false
    var isAfterCreation = false
    var isShowCreatePost = false
    
    var pullRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        minTopScrollHeight = minTopScrollHeight + addHeight
        
        if !ApplicationTheme.iPhoneHasNotch() {
            maxViewHeight = maxViewHeight - 20
        }
        
        self.addShadowAndRadius(customView: ui_view_button_settings)
        self.addShadowAndRadius(customView: ui_view_button_back)
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: nil, titleFont: nil, titleColor: nil, imageName: "ic_return_mini", backgroundColor: .clear, delegate: self, showSeparator: false, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        ui_view_top_bg.alpha = 1
        ui_iv_event.alpha = 0
        registerCellsNib()
        
        setupViews()
        
        populateTopView(isAfterLoading: false)
        
        ui_floaty_button.isHidden = true
        ui_bt_floating_join.isHidden = true
        
        getEventDetail()
        ui_view_canceled.isHidden = true
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isShowCreatePost {
            showCreatePost()
            isShowCreatePost = false
        }
        //Notif for updating event infos
        NotificationCenter.default.addObserver(self, selector: #selector(updateEvent), name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
    }
    
    func registerCellsNib() {
        ui_tableview.register(UINib(nibName: NeighborhoodPostTextCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostTextCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostImageCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostImageCell.identifier)
        ui_tableview.register(UINib(nibName: EventDetailTopFullCell.identifier, bundle: nil), forCellReuseIdentifier: EventDetailTopFullCell.identifier)
        ui_tableview.register(UINib(nibName: EventDetailTopLightCell.identifier, bundle: nil), forCellReuseIdentifier: EventDetailTopLightCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodEmptyPostCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodEmptyPostCell.identifier)
        
        ui_tableview.register(UINib(nibName: EventListSectionCell.identifier, bundle: nil), forCellReuseIdentifier: EventListSectionCell.identifier)
        ui_tableview.register(UINib(nibName: EventListSectionCell.neighborhoodHeaderIdentifier, bundle: nil), forCellReuseIdentifier: EventListSectionCell.neighborhoodHeaderIdentifier)
    }
    
    private func addShadowAndRadius(customView:UIView) {
        customView.clipsToBounds = false
        customView.layer.cornerRadius = customView.frame.height / 2
        customView.layer.shadowColor = UIColor.appOrangeLight.withAlphaComponent(0.5).cgColor
        customView.layer.shadowOpacity = 1
        customView.layer.shadowOffset = CGSize.init(width: 4, height: 4)
        customView.layer.shadowRadius = 4
    }
    
    func setupViews() {
        maxImageHeight = ui_iv_event.frame.height
        
        ui_view_height_constraint.constant = maxViewHeight
        viewNormalHeight = ui_view_height_constraint.constant
        
        let topPadding = ApplicationTheme.getTopIPhonePadding()
        let inset = UIEdgeInsets(top: viewNormalHeight - topPadding,left: 0,bottom: 0,right: 0)
        minViewHeight = minViewHeight + topPadding - 20
        
        ui_tableview.contentInset = inset
        ui_tableview.scrollIndicatorInsets = inset
        
        ui_label_title_event.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_iv_event_mini.layer.cornerRadius = 8
        ui_iv_event_mini.layer.borderColor = UIColor.appOrangeLight.cgColor
        ui_iv_event_mini.layer.borderWidth = 1
        
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshEvent), for: .valueChanged)
        ui_tableview.refreshControl = pullRefreshControl
        
        ui_bt_floating_join.layer.cornerRadius = ui_bt_floating_join.frame.height / 2
        ui_title_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_title_bt_join.text = "event_detail_button_participe_OFF".localized
        
        ui_view_canceled.layer.cornerRadius = 8
        ui_lbl_canceled.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldBlanc(size: 15))
        ui_lbl_canceled.text = "event_canceled".localized.uppercased()
    }
    
    func populateTopView(isAfterLoading:Bool) {
        let imageName = "placeholder_photo_group"
        if let _url = self.event?.metadata?.landscape_url, let url = URL(string: _url) {
            self.ui_iv_event.sd_setImage(with: url, placeholderImage: nil, completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if error != nil {
                    self?.ui_iv_event.image = UIImage.init(named: imageName)
                }
            })
            
            self.ui_iv_event_mini.sd_setImage(with: url, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if error != nil {
                    self?.ui_iv_event_mini.image = UIImage.init(named: imageName)
                }
            })
            self.ui_iv_event2.sd_setImage(with: url, placeholderImage: nil, completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if error != nil {
                    self?.ui_iv_event2.image = UIImage.init(named: imageName)
                }
            })
        }
        else if isAfterLoading {
            self.ui_iv_event.image = UIImage.init(named: imageName)
            self.ui_iv_event_mini.image = UIImage.init(named: imageName)
            self.ui_iv_event2.image = UIImage.init(named: imageName)
        }
        
        self.ui_label_title_event.text = self.event?.title
        self.ui_floaty_button?.isHidden = self.event?.isMember ?? false ? false : true
        
        self.ui_bt_floating_join.isHidden = true
    }
    
    
    // Actions
    
    @objc private func refreshEvent() {
        updateEvent()
    }
    
    @objc func updateEvent() {
        getEventDetail(hasToRefreshLists: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    
    //MARK: -Network
    @objc func getEventDetail(hasToRefreshLists:Bool = false) {
        self.currentPagingPage = 1
        self.isLoading = true
        EventService.getEventWithId(eventId) { event, error in
            self.pullRefreshControl.endRefreshing()
            if let _ = error {
                self.goBack()
            }
            
            self.event = event
            self.splitMessages()
            self.ui_tableview.reloadData()
            self.isLoading = false
            
            if event?.isCanceled() ?? false {
                self.ui_view_canceled.isHidden = false
            }
            else {
                self.ui_view_canceled.isHidden = true
            }
            
            self.populateTopView(isAfterLoading: true)
            
            if hasToRefreshLists {
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationEventsUpdate), object: nil)
            }
        }
    }
    
    func getMorePosts() {
        //TODO: a tester
        self.isLoading = true
        EventService.getEventPostsPaging(id: eventId, currentPage: currentPagingPage, per: itemsPerPage) { post, error in
            if let post = post {
                self.event?.posts?.append(contentsOf: post)
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
        guard let messages = event?.posts else {
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
        self.ui_tableview.reloadData()
        if isAdd {
            IHProgressHUD.show()
            EventService.joinEvent(eventId: eventId) { user, error in
                IHProgressHUD.dismiss()
                if let user = user {
                    let member = MemberLight.init(uid: user.uid, username: user.username, imageUrl: user.imageUrl)
                    self.event?.members?.append(member)
                    let count:Int = self.event?.membersCount != nil ? self.event!.membersCount! + 1 : 1
                    
                    self.isAfterCreation = true
                    self.event?.membersCount = count
                    self.getEventDetail(hasToRefreshLists:true)
                    
                    DispatchQueue.main.async {
                        if self.event?.metadata?.hasPlaceLimit ?? false {
                            self.showPopInfoPlaces()
                        }
                        else {
                            self.addToCalendar()
                        }
                    }
                }
            }
        }
        else {
            showPopLeave()
        }
    }
    
    func showPopLeave() {
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
                self.event?.members?.removeAll(where: {$0.uid == UserDefaults.currentUser!.sid})
                let count:Int = self.event?.membersCount != nil ? self.event!.membersCount! - 1 : 0
                
                self.event?.membersCount = count
                
                self.ui_tableview.reloadData()
                self.getEventDetail(hasToRefreshLists:true)
            }
        }
    }
    
    func joinLeaveEvent() {
        let currentUserId = UserDefaults.currentUser?.sid
        if event?.author?.uid == currentUserId { return }
        
        if let _ = event?.members?.first(where: {$0.uid == currentUserId}) {
            addRemoveMember(isAdd: false)
        }
        else {
            addRemoveMember(isAdd: true)
        }
    }
    
    //MARK: - IBAction -
    @IBAction func action_show_params(_ sender: Any) {
        if let _event = event {
            if let navvc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "params_eventNav") as? UINavigationController, let vc = navvc.topViewController as? EventParamsViewController {
                vc.event = _event
                vc.modalPresentationStyle = .fullScreen
                self.present(navvc, animated: true, completion: nil)
                return
            }
        }
    }
    
    @IBAction func action_join(_ sender: Any) {
        joinLeaveEvent()
    }
    
    @IBAction func action_create_post(_ sender: Any) {
        showCreatePost()
    }
    
    //MARK: - Nav VCs-
    func showCreatePost() {
        let sb = UIStoryboard.init(name: StoryboardName.neighborhoodMessage, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "addPostVC") as? NeighborhoodPostAddViewController  {
            vc.eventId = self.eventId
            vc.isNeighborhood = false
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showPopInfoPlaces() {
        let customAlert = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle: ApplicationTheme.getFontCourantRegularNoir(size: 15, color: .white), bgColor: .appOrange, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "event_add_contact_places_title".localized, message: "event_add_contact_places_description".localized, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35,parentVC:self)
        
        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
        
    }
    
    //MARK: - Agenda -
    func addToCalendar() {
        let store = EKEventStore()
        store.requestAccess(to: .event, completion: {(granted,error) in
            if granted && error == nil {
                self.showPopCalendar()
            }
            else {
                DispatchQueue.main.async {
                    let alertVC = MJAlertController()
                    alertVC.alertTagName = .AcceptSettings
                    let buttonCancel = MJAlertButtonType(title: "event_add_contact_refuse".localized, titleStyle:MJTextFontColorStyle.init(font: ApplicationTheme.getFontNunitoBold(size: 15), color: .appOrange), bgColor: .appOrangeLight_50, cornerRadius: -1)
                    let buttonValidate = MJAlertButtonType(title: "event_add_contact_activate".localized, titleStyle:MJTextFontColorStyle.init(font: ApplicationTheme.getFontNunitoBold(size: 15), color: .white), bgColor: .appOrange, cornerRadius: -1)
                    alertVC.configureAlert(alertTitle: "errorSettings".localized, message: "event_add_contact_error".localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrangeClair(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true, parentVC: self.navigationController)
                    
                    alertVC.delegate = self
                    alertVC.show()
                }
            }
        })
    }
    
    func showPopCalendar() {
        DispatchQueue.main.async {
            let alertVC = MJAlertController()
            alertVC.alertTagName = .AcceptAdd
            let buttonCancel = MJAlertButtonType(title: "event_add_contact_cancel".localized, titleStyle:MJTextFontColorStyle.init(font: ApplicationTheme.getFontNunitoBold(size: 15), color: .appOrange), bgColor: .appOrangeLight_50, cornerRadius: -1)
            let buttonValidate = MJAlertButtonType(title: "event_add_contact_accept".localized, titleStyle:MJTextFontColorStyle.init(font: ApplicationTheme.getFontNunitoBold(size: 15), color: .white), bgColor: .appOrange, cornerRadius: -1)
            alertVC.configureAlert(alertTitle: "event_add_contact_title".localized, message: "event_add_contact_description".localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrangeClair(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true, parentVC: self.navigationController)
            
            alertVC.delegate = self
            alertVC.show()
        }
    }
    
    func showAddCalendar() {
        let store = EKEventStore()
        store.requestAccess(to: .event, completion: {(granted,error) in
            if granted && error == nil {
                let ekEvent = EKEvent(eventStore: store)
                ekEvent.title = self.event?.title
                ekEvent.startDate = self.event?.getMetadateStartDate()
                ekEvent.endDate = self.event?.getMetadateEndDate()
                
                if let _url = self.event?.onlineEventUrl, let url = URL.init(string: _url) {
                    ekEvent.url = url
                }
                else if let _lat = self.event?.location?.latitude, let _long = self.event?.location?.longitude {
                    let _structLovation = EKStructuredLocation()
                    _structLovation.geoLocation = CLLocation(latitude: _lat, longitude: _long)
                    _structLovation.title = self.event?.addressName
                    ekEvent.structuredLocation = _structLovation
                    ekEvent.location = self.event?.addressName
                }
                
                DispatchQueue.main.async {
                    let vc = EKEventEditViewController()
                    vc.editViewDelegate = self
                    vc.event = ekEvent
                    vc.eventStore = store
                    self.present(vc, animated: true, completion: nil)
                }
            }
        })
    }
}

//MARK: - UITableViewDataSource / Delegate -
extension EventDetailFeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        
        let minimum = self.event != nil ? 2 : 0
        let added = hasNewAndOldSections ? 1 : 0
        return minimum + added
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        
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
        
        let messageCount:Int = (self.event?.posts?.count ?? 0) > 0 ? self.event!.posts!.count + countToAdd() : 1
        return  messageCount
    }
    
    func countToAdd() -> Int {
        //Is member + new posts
        let countToAdd = (self.event?.isMember ?? false && self.messagesNew.count > 0) ? 2 : 1 //If not member or only old messages we dont' show new/old post header
        return countToAdd
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if (self.event!.isMember ?? false) && !isAfterCreation {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailTopLightCell.identifier, for: indexPath) as! EventDetailTopLightCell
                cell.populateCell(event: self.event, delegate: self)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailTopFullCell.identifier, for: indexPath) as! EventDetailTopFullCell
                cell.populateCell(event: self.event, delegate: self)
                return cell
            }
        }
        
        if self.event?.posts?.count ?? 0 == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: NeighborhoodEmptyPostCell.identifier, for: indexPath) as! NeighborhoodEmptyPostCell
            cell.populateCell(isEvent: true)
            return cell
        }
        
        if hasNewAndOldSections && indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.identifier, for: indexPath) as! EventListSectionCell
                
                cell.populateCell(title: "event_detail_post_section_old_posts_title".localized, isTopHeader: false)
                return cell
            }
            
            let postmessage:PostMessage = messagesOld[indexPath.row - 1]
            let identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
            cell.populateCell(message: postmessage,delegate: self,currentIndexPath: indexPath, userId: postmessage.user?.sid)
            return cell
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.neighborhoodHeaderIdentifier, for: indexPath) as! EventListSectionCell
            cell.populateCell(title: "event_detail_post_section_title".localized, isTopHeader: true)
            return cell
        }
        
        //If not member we dont' show new/old post header
        let countToAdd = countToAdd()
        if countToAdd == 2 {
            if indexPath.row == 1 {
                let titleSection = hasNewAndOldSections || self.messagesOld.count == 0 ? "event_detail_post_section_new_posts_title".localized : "event_detail_post_section_old_posts_title".localized
                
                let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.identifier, for: indexPath) as! EventListSectionCell
                cell.populateCell(title: titleSection , isTopHeader: false)
                return cell
            }
        }
        
        let postmessage:PostMessage = hasNewAndOldSections ? self.messagesNew[indexPath.row - countToAdd] : self.event!.posts![indexPath.row - countToAdd]
        
        let identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
        cell.populateCell(message: postmessage,delegate: self,currentIndexPath: indexPath, userId: postmessage.user?.sid)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == 0 && indexPath.row == 1 {
            // return 214
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
        
        let messageCount:Int = event?.posts?.count ?? 0
        
        let lastIndex = messageCount - nbOfItemsBeforePagingReload
        if realIndex == lastIndex && messageCount >= itemsPerPage * currentPagingPage {
            self.currentPagingPage = self.currentPagingPage + 1
            self.getMorePosts()
        }
    }
    
    //MARK: - Method uiscrollview delegate -
    func scrollViewDidScroll( _ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0) {
            let yImage = self.maxImageHeight - (scrollView.contentOffset.y+self.maxImageHeight)
            let diffImage = (self.maxViewHeight - self.maxImageHeight)
            let heightImage = min(max (yImage -  diffImage,self.minImageHeight),self.maxImageHeight)
            
            self.ui_view_button_settings.alpha = heightImage / self.maxImageHeight
            self.ui_view_button_back.alpha = heightImage / self.maxImageHeight
            self.ui_iv_event2.alpha = heightImage / self.maxImageHeight
            self.ui_view_top_bg.alpha = 1 - (heightImage / self.maxImageHeight)
            self.ui_iv_event_mini.alpha = 1 - (heightImage / self.maxImageHeight)
            self.ui_label_title_event.alpha = 1 - (heightImage / self.maxImageHeight)
            self.ui_view_canceled.alpha = heightImage / self.maxImageHeight
            let yView = self.viewNormalHeight - (scrollView.contentOffset.y + self.viewNormalHeight)
            let heightView = min(max (yView,self.minViewHeight),self.maxViewHeight)
            self.ui_view_height_constraint.constant = heightView
            
            //To show/hide button join on scroll
            if !(self.event?.isMember ?? false) {
                if scrollView.contentOffset.y >= self.minTopScrollHeight {
                    self.ui_bt_floating_join.isHidden = false
                }
                else {
                    self.ui_bt_floating_join.isHidden = true
                }
            }
            
            self.view.layoutIfNeeded()
        }
    }
}

//MARK: - MJAlertControllerDelegate -
extension EventDetailFeedViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag:MJAlertTAG) {}
    
    func validateRightButton(alertTag:MJAlertTAG) {
        if alertTag == .None {
            self.sendLeaveGroup()
        }
        
        if alertTag == .AcceptSettings {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:],completionHandler:nil)
            }
        }
        if alertTag == .AcceptAdd {
            self.showAddCalendar()
        }
    }
    func closePressed(alertTag:MJAlertTAG) {}
}

//MARK: - MJNavBackViewDelegate -
extension EventDetailFeedViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

//MARK: - EventDetailTopCellDelegate -
extension EventDetailFeedViewController:EventDetailTopCellDelegate {
    func showMembers() {
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.isEvent = true
            self.navigationController?.present(navVC, animated: true)
        }
    }
    func joinLeave() {
        joinLeaveEvent()
    }
    func showDetailFull() {
        if let navVC = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailFullNav") as? UINavigationController, let vc = navVC.topViewController as? EventDetailFullFeedViewController {
            vc.eventId = eventId
            vc.event = event
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    func showPlace() {
        if event?.isCanceled() ?? false { return }
        
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
}

//MARK: - NeighborhoodPostCellDelegate -
extension EventDetailFeedViewController:NeighborhoodPostCellDelegate {
    func showMessages(addComment:Bool, postId:Int, indexPathSelected: IndexPath?) {
        let sb = UIStoryboard.init(name: StoryboardName.eventMessage, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? EventDetailMessagesViewController {
            vc.modalPresentationStyle = .fullScreen
            vc.parentCommentId = postId
            vc.eventId = eventId
            vc.eventName = event!.title
            vc.isGroupMember = event?.isMember ?? false
            vc.isStartEditing = addComment
            vc.parentDelegate = self
            vc.selectedIndexPath = indexPathSelected
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showUser(userId:Int?) {
        guard let userId = userId else {
            return
        }

        if let navVC = UIStoryboard.init(name: StoryboardName.userDetail, bundle: nil).instantiateViewController(withIdentifier: "userProfileNavVC") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? UserProfileDetailViewController {
                _homeVC.currentUserId = "\(userId)"
                
                self.navigationController?.present(navVC, animated: true)
            }
        }
    }
    
    func showImage(indexPathSelected:IndexPath?) {
        self.showWIP(parentVC: self)
    }
}

//MARK: - UpdateEventCommentDelegate -
extension EventDetailFeedViewController:UpdateCommentCountDelegate {
    func updateCommentCount(parentCommentId: Int, nbComments: Int, currentIndexPathSelected:IndexPath?) {
        guard let _ = event?.posts else {return}
        
        var i = 0
        for _post in event!.posts! {
            if _post.uid == parentCommentId {
                event!.posts![i].commentsCount = nbComments
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

//MARK: - EKEVENT Delegate -
extension EventDetailFeedViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController, didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}

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
    
    @IBOutlet weak var ui_constraint_button: NSLayoutConstraint!
    @IBOutlet weak var ui_view_button_back: UIView!
    @IBOutlet weak var ui_view_button_settings: UIView!
    
    @IBOutlet weak var ui_floaty_bouton: Floaty!
    
    @IBOutlet weak var ui_view_full_image: UIView!
    @IBOutlet weak var ui_scrollview: UIScrollView!
    @IBOutlet weak var ui_iv_preview: UIImageView!
    
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
    var hashedEventId:String = ""
    var event:Event? = nil
    var isUserAmbassador = false
    var hasNewAndOldSections = false
    var currentPagingPage = 1 //Default WS
    let itemsPerPage = 25 //Default WS
    let nbOfItemsBeforePagingReload = 5
    var isLoading = false
    var isAfterCreation = false
    var isShowCreatePost = false
    let DELETED_POST_CELL_SIZE = 165.0
    let TEXT_POST_CELL_SIZE = 220.0
    let IMAGE_POST_CELL_SIZE = 430.0
    
    var pullRefreshControl = UIRefreshControl()
    var users:[UserLightNeighborhood] = [UserLightNeighborhood]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        minTopScrollHeight = minTopScrollHeight + addHeight
        
        if !ApplicationTheme.iPhoneHasNotch() {
            maxViewHeight = maxViewHeight - 20
        }
        setupFloatingButton()

        
        self.addShadowAndRadius(customView: ui_view_button_settings)
        self.addShadowAndRadius(customView: ui_view_button_back)
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: nil, titleFont: nil, titleColor: nil, imageName: "ic_return_mini", backgroundColor: .clear, delegate: self, showSeparator: false, cornerRadius: nil, isClose: false, marginLeftButton: nil)
        ui_view_top_bg.alpha = 1
        ui_iv_event.alpha = 0
        registerCellsNib()
        
        setupViews()
        
        populateTopView(isAfterLoading: false)
        
        ui_floaty_bouton.isHidden = true
        ui_bt_floating_join.isHidden = true
        
        ui_view_canceled.isHidden = true
        
        self.ui_view_full_image.isHidden = true
        self.ui_scrollview.delegate = self
        self.ui_scrollview.maximumZoomScale = 10
        AnalyticsLoggerManager.logEvent(name: Event_detail_main)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isShowCreatePost {
            showCreatePost()
            isShowCreatePost = false
        }
        //Notif for updating event infos
        //NotificationCenter.default.addObserver(self, selector: #selector(updateEvent), name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
        getEventMembers()
        getEventDetail()

    }
    
    func getEventMembers(){
        EventService.getEventUsers(eventId: self.eventId) { users, error in
            if let _users = users{
                self.users = _users
            }
        }
    }
    
    func registerCellsNib() {
        ui_tableview.register(UINib(nibName: NeighborhoodPostTextCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostTextCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostImageCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostImageCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostDeletedCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostDeletedCell.identifier)
        ui_tableview.register(UINib(nibName: EventDetailTopFullCell.identifier, bundle: nil), forCellReuseIdentifier: EventDetailTopFullCell.identifier)
        ui_tableview.register(UINib(nibName: EventDetailTopLightCell.identifier, bundle: nil), forCellReuseIdentifier: EventDetailTopLightCell.identifier)
        
        ui_tableview.register(UINib(nibName: NeighborhoodEmptyPostCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodEmptyPostCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostTranslationCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostTranslationCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostImageTranslationCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostImageTranslationCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostSurveyCell.identifier, bundle: nil), forCellReuseIdentifier: NeighborhoodPostSurveyCell.identifier)
        ui_tableview.register(UINib(nibName: EventListSectionCell.identifier, bundle: nil), forCellReuseIdentifier: EventListSectionCell.identifier)
        ui_tableview.register(UINib(nibName: EventListSectionCell.neighborhoodHeaderIdentifier, bundle: nil), forCellReuseIdentifier: EventListSectionCell.neighborhoodHeaderIdentifier)
    }
    
    func setupFloatingButton() {

        let floatItem2 = createButtonItem(title: "neighborhood_menu_post_survey".localized, iconName: "ic_survey_creation") { item in
            self.showCreateSurvey()
        }
        
        let floatItem3 = createButtonItem(title: "neighborhood_menu_post_post".localized, iconName: "ic_menu_button_create_post") { item in
            AnalyticsLoggerManager.logEvent(name: Event_detail_action_post)
            self.showCreatePost()
        }
        
        ui_floaty_bouton.overlayColor = .white.withAlphaComponent(0.10)
        ui_floaty_bouton.addBlurOverlay = true
        ui_floaty_bouton.itemSpace = 24
        ui_floaty_bouton.addItem(item: floatItem3)
        ui_floaty_bouton.addItem(item: floatItem2)
        ui_floaty_bouton.sticky = true
        ui_floaty_bouton.animationSpeed = 0.3
        ui_floaty_bouton.fabDelegate = self
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
        self.ui_floaty_bouton?.isHidden = self.event?.isMember ?? false ? false : true
        
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
    func getEventusers() {
        guard let event = event else {
            return
        }
        
        EventService.getEventUsers(eventId: event.uid, completion: { users, error in
            if let _ = error {
                self.goBack()
            }
            if let _users = users {
                for _user in _users {
                    if _user.sid == event.author?.uid{
                        if let _roles = _user.communityRoles{
                            if _roles.contains("Équipe Entourage") || _roles.contains("Ambassadeur"){
                                self.isUserAmbassador = true
                            }
                        }
                    }
                }
            }
            self.ui_tableview.reloadData()
        })
    }
    
    //MARK: -Network
    @objc func getEventDetail(hasToRefreshLists:Bool = false) {
        self.currentPagingPage = 1
        self.isLoading = true
        var _eventId = ""
        if eventId != 0 {
            _eventId = String(eventId)
        }else if hashedEventId != "" {
            _eventId = hashedEventId
        }
        EventService.getEventWithId(_eventId) { event, error in
            self.pullRefreshControl.endRefreshing()
            if let _ = error {
                self.goBack()
            }
            if event == nil {
                    let alertController = UIAlertController(title: "Attention", message: "Cet événement a été supprimé", preferredStyle: .alert)
                    let closeAction = UIAlertAction(title: "Fermer", style: .default, handler: nil)
                    alertController.addAction(closeAction)
                    self.present(alertController, animated: true, completion: nil)
                     
            }
            self.event = event
            self.eventId = event?.uid ?? 0
            self.event?.posts?.removeAll()
            self.splitMessages()
            self.getMorePosts()
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
            self.ui_tableview.reloadData()
        }
        getEventusers()
    }
    
    func getMorePosts() {
        self.isLoading = true
        EventService.getEventPostsPaging(id: eventId, currentPage: currentPagingPage, per: itemsPerPage) { post, error in
            guard let post = post, error == nil else {
                // Gérer l'erreur ici si nécessaire
                self.isLoading = false
                return
            }

            DispatchQueue.main.async {
                // Mettre à jour les données
                self.event?.posts?.append(contentsOf: post)
                self.splitMessages()

                // Mise à jour de la vue table en fonction des scénarios
                self.ui_tableview.performBatchUpdates({
                    let currentSections = self.ui_tableview.numberOfSections
                    // Scénario 1: Aucun message
                    if self.event?.posts?.isEmpty ?? true {
                        
                    } else {
                        // Scénario 2: Messages anciens et/ou nouveaux
                        if self.hasNewAndOldSections {
                            if currentSections == 1 {
                                // Ajouter une section pour les nouveaux messages
                                self.ui_tableview.insertSections(IndexSet(integer: 1), with: .fade)
                            }
                            // Recharger la section des messages anciens
                            self.ui_tableview.reloadSections(IndexSet(integer: 2), with: .fade)
                        } else if currentSections == 3 {
                            // Revenir à une seule section si nécessaire
                            self.ui_tableview.deleteSections(IndexSet(integer: 2), with: .fade)
                            self.ui_tableview.reloadSections(IndexSet(integer: 1), with: .fade)
                        } else {
                            // Recharger la section existante
                            self.ui_tableview.reloadSections(IndexSet(integer: 1), with: .fade)
                        }
                    }
                }, completion: nil)

                self.isLoading = false
            }
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
            if let _isamba = UserDefaults.currentUser?.isAmbassador(){
                if _isamba{
                    if let popupVC = storyboard?.instantiateViewController(withIdentifier: "ambassadorAskNotificationPopup") as? AmbassadorAskNotificationPopup {
                        popupVC.delegate = self
                        popupVC.modalPresentationStyle = .overFullScreen // Ajuster le style de présentation si nécessaire
                        popupVC.modalTransitionStyle = .crossDissolve // Ajuster la transition si nécessaire
                        present(popupVC, animated: true, completion: nil)
                    }
                }else{
                    EventService.joinEvent(eventId: eventId) { user, error in
                        IHProgressHUD.dismiss()
                        print("eho error " , error.debugDescription)
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
            }else{
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

        }
        else {
            showPopLeave()
        }
    }
    
    func showPopLeave() {
        let customAlert = MJAlertController()
        let buttonAccept = MJAlertButtonType(title: "params_leave_event_pop_bt_quit".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        let buttonCancel = MJAlertButtonType(title: "params_leave_event_pop_bt_cancel".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "params_leave_event_pop_title".localized, message: "params_leave_event_pop_message".localized, buttonrightType: buttonAccept, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
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
                AnalyticsLoggerManager.logEvent(name: Event_detail_action_param)
                vc.event = _event
                vc.modalPresentationStyle = .fullScreen
                self.present(navvc, animated: true, completion: nil)
                return
            }
        }
    }
    
    @IBAction func action_join(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Event_detail_action_participate)
        joinLeaveEvent()
    }
    

    @IBAction func action_tap_close_full_image(_ sender: Any) {
        ui_view_full_image.isHidden = true
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
    func showCreateSurvey() {
        let sb = UIStoryboard.init(name: StoryboardName.survey, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "create_survey") as? CreateSurveyViewController  {
            vc.eventId = self.eventId
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true)
        }
    }
    func showPopInfoPlaces() {
        let customAlert = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized, titleStyle: ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "event_add_contact_places_title".localized, message: "event_add_contact_places_description".localized, buttonrightType: buttonCancel, buttonLeftType: nil, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35)
        
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
                    let buttonCancel = MJAlertButtonType(title: "event_add_contact_refuse".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
                    let buttonValidate = MJAlertButtonType(title: "event_add_contact_activate".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
                    alertVC.configureAlert(alertTitle: "errorSettings".localized, message: "event_add_contact_error".localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
                    
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
            let buttonCancel = MJAlertButtonType(title: "event_add_contact_no".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrangeLight, cornerRadius: -1)
            
            
            let buttonValidate = MJAlertButtonType(title: "event_add_contact_yes".localized, titleStyle:ApplicationTheme.getFontCourantBoldBlanc(), bgColor: .appOrange, cornerRadius: -1)
            alertVC.configureAlert(alertTitle: "event_add_contact_title".localized, message: "event_add_contact_description".localized, buttonrightType: buttonValidate, buttonLeftType: buttonCancel, titleStyle: ApplicationTheme.getFontCourantBoldOrange(), messageStyle: ApplicationTheme.getFontCourantRegularNoir(), mainviewBGColor: .white, mainviewRadius: 35, isButtonCloseHidden: true)
            
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
                cell.populateCell(event: self.event, delegate: self,isEntourageEvent: isUserAmbassador, members: self.users)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailTopFullCell.identifier, for: indexPath) as! EventDetailTopFullCell
                cell.populateCell(event: self.event, delegate: self, isEntourageEvent: isUserAmbassador)
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
            var identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
            if postmessage.survey != nil {
                identifier = NeighborhoodPostSurveyCell.identifier
            }
            if postmessage.status == "deleted" {
                identifier = NeighborhoodPostDeletedCell.identifier
            }
            if !(postmessage.contentTranslations?.from_lang == LanguageManager.getCurrentDeviceLanguage() || UserDefaults.currentUser?.sid == postmessage.user?.sid) {
                identifier = postmessage.isPostImage ? NeighborhoodPostImageTranslationCell.identifier : NeighborhoodPostTranslationCell.identifier
            }
            if(postmessage.contentTranslations == nil){
                identifier = postmessage.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
            cell.populateCell(message: postmessage,delegate: self,currentIndexPath: indexPath, userId: postmessage.user?.sid, isMember: self.event?.isMember)
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
        if postmessage.status == "deleted" {
            identifier = NeighborhoodPostDeletedCell.identifier
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
        cell.populateCell(message: postmessage,delegate: self,currentIndexPath: indexPath, userId: postmessage.user?.sid, isMember: self.event?.isMember)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
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
    func share() {
        var stringUrl = "https://"
        var title = ""
        if NetworkManager.sharedInstance.getBaseUrl().contains("preprod"){
            stringUrl = stringUrl + "preprod.entourage.social/app/"
        }else{
            stringUrl = stringUrl + "www.entourage.social/app/"
        }
        if let _event = event {
            stringUrl = stringUrl + "outings/" + _event.uuid_v2
            title = "share_event".localized + "\n" + _event.title + ": "

        }
        let url = URL(string: stringUrl)!
        let shareText = "\(title)\n\n\(stringUrl)"
        
        let activityViewController = UIActivityViewController(activityItems: [title, url], applicationActivities: nil)
          // Présenter l’UIActivityViewController
        let viewController = self
          viewController.present(activityViewController, animated: true, completion: nil)
        AnalyticsLoggerManager.logEvent(name: event_share)

    }
    
    func showUser() {
        
    }
    
    func showWebUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
    
    func showMembers() {
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.isEvent = true
            self.navigationController?.present(navVC, animated: true)
        }
    }
    func showMemberReact(postId:Int){
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.postId = postId
            vc.eventId = eventId
            vc.isFromReact = true
            self.navigationController?.present(navVC, animated: true)
        }
    }
    func showVote(post:PostMessage){
        if let navVC = UIStoryboard.init(name: StoryboardName.neighborhood, bundle: nil).instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController, let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.survey = post.survey
            vc.postId = post.uid
            vc.isFromSurvey = true
            vc.eventId = eventId
            vc.isFromReact = false
            vc.questionTitle = post.content
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
            vc.isEntourageEvent = isUserAmbassador
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
    func sendVoteView(post: PostMessage) {
        self.showVote(post: post)
    }
    
    func postSurveyResponse(forPostId postId: Int, withResponses responses: [Bool]) {
        let groupId = self.eventId
        
        SurveyService.postSurveyResponseEvent(eventId: groupId, postId: postId, responses: responses) { isSuccess in
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
        self.showMemberReact(postId: post.uid)
    }
    
    func addReaction(post: PostMessage, reactionType: ReactionType) {
        var reactionWrapper = ReactionWrapper()
        reactionWrapper.reactionId = reactionType.id
        EventService.postReactionToEventPost(eventId: self.eventId, postId: post.uid, reactionWrapper: reactionWrapper) { error in

        }
    }
    
    func deleteReaction(post: PostMessage, reactionType: ReactionType) {
        EventService.deleteReactionToEventPost(eventId: self.eventId, postId: post.uid) { error in
        }
    }
    
    func showWebviewUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
    
    func showImage(imageUrl: URL?, postId: Int) {
        self.getDetailPost(eventId: self.eventId, parentPostId: postId)
    }
    
    func signalPost(postId: Int, userId:Int, textString: String) {
        if let navvc = UIStoryboard.init(name: StoryboardName.neighborhoodReport, bundle: nil).instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController, let vc = navvc.topViewController as? ReportGroupMainViewController {
            vc.eventId = eventId
            vc.postId = postId
            vc.parentDelegate = self
            vc.userId = userId
            vc.signalType = .publication
            vc.textString = textString
            self.present(navvc, animated: true)
        }
    }
    
    func showMessages(addComment:Bool, postId:Int, indexPathSelected: IndexPath?,postMessage:PostMessage?) {
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
            vc.postMessage = postMessage
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

//MARK: - UIScrollViewDelegate -
extension EventDetailFeedViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return self.ui_iv_preview
    }
}

extension EventDetailFeedViewController:GroupDetailDelegate{
    func translateItem(id: Int) {
        //TODO TRANSLATE
    }
    
    func publicationDeleted() {
        getEventDetail()
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

//MARK: Extension for getPostDetail to get a better quality for photozoom
extension EventDetailFeedViewController{
    func getDetailPost(eventId:Int, parentPostId:Int){
        EventService.getDetailPostMessage(eventId: eventId, parentPostId: parentPostId) { message, error in
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

extension EventDetailFeedViewController:CreateSurveyValidationDelegate{
    func onSurveyCreate() {
        self.getEventDetail()
    }
}

//MARK: - FloatyDelegate -
extension EventDetailFeedViewController:FloatyDelegate {
    func floatyWillOpen(_ floaty: Floaty) {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_Plus)
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

enum TableIsOldAndNewPost {
    case onlyOld
    case newAndOld
    case onlyNew
}

extension EventDetailFeedViewController : AmbassadorAskNotificationPopupDelegate{
    func joinAsOrganizer() {
        
        EventService.joinEventAsOrganizer(eventId: eventId) { user, error in
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
    
    func justParticipate() {
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
    
    
}

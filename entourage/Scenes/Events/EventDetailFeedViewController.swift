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
    
    // Pour afficher/cacher le bouton « Participer » lors du scroll
    @IBOutlet weak var ui_title_bt_join: UILabel!
    @IBOutlet weak var ui_bt_floating_join: UIView!
    
    let addHeight: CGFloat = ApplicationTheme.iPhoneHasNotch() ? 0 : 20
    var minTopScrollHeight: CGFloat = 120
    
    // Utilisé pour étirer l'en-tête
    var maxViewHeight: CGFloat = 150
    var minViewHeight: CGFloat = 80 // 70 + 19
    var maxImageHeight: CGFloat = 73
    var minImageHeight: CGFloat = 0
    var viewNormalHeight: CGFloat = 0
    
    var messagesNew = [PostMessage]()
    var messagesOld = [PostMessage]()
    var eventId: Int = 0
    var hashedEventId: String = ""
    var event: Event? = nil
    var isUserAmbassador = false
    var hasNewAndOldSections = false
    var currentPagingPage = 1
    let itemsPerPage = 25
    let nbOfItemsBeforePagingReload = 5
    var isLoading = false
    
    /// Sert uniquement à votre condition :
    /// `if (event.isMember) && !isAfterCreation => LightCell`
    var isAfterCreation = false
    
    var isShowCreatePost = false
    let DELETED_POST_CELL_SIZE = 165.0
    let TEXT_POST_CELL_SIZE = 220.0
    let IMAGE_POST_CELL_SIZE = 430.0
    var shouldOpenNativeAgenda = false
    
    var pullRefreshControl = UIRefreshControl()
    var users: [UserLightNeighborhood] = [UserLightNeighborhood]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        minTopScrollHeight += addHeight
        
        if !ApplicationTheme.iPhoneHasNotch() {
            maxViewHeight -= 20
        }
        setupFloatingButton()
        
        addShadowAndRadius(customView: ui_view_button_settings)
        addShadowAndRadius(customView: ui_view_button_back)
        
        ui_top_view.backgroundColor = .clear
        ui_top_view.populateCustom(title: nil,
                                   titleFont: nil,
                                   titleColor: nil,
                                   imageName: "ic_return_mini",
                                   backgroundColor: .clear,
                                   delegate: self,
                                   showSeparator: false,
                                   cornerRadius: nil,
                                   isClose: false,
                                   marginLeftButton: nil)
        
        ui_view_top_bg.alpha = 1
        ui_iv_event.alpha = 0
        registerCellsNib()
        
        setupViews()
        
        populateTopView(isAfterLoading: false)
        
        ui_floaty_bouton.isHidden = true
        ui_bt_floating_join.isHidden = true
        
        ui_view_canceled.isHidden = true
        
        ui_view_full_image.isHidden = true
        ui_scrollview.delegate = self
        ui_scrollview.maximumZoomScale = 10
        
        AnalyticsLoggerManager.logEvent(name: Event_detail_main)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isShowCreatePost {
            showCreatePost()
            isShowCreatePost = false
        }
        
        // Récupérer quelques infos depuis le serveur
        getEventMembers()
        getEventDetail()
    }
    
    func getEventMembers() {
        EventService.getEventUsers(eventId: self.eventId) { users, error in
            if let _users = users {
                self.users = _users
            }
        }
    }
    
    func registerCellsNib() {
        ui_tableview.register(UINib(nibName: NeighborhoodPostTextCell.identifier, bundle: nil),
                              forCellReuseIdentifier: NeighborhoodPostTextCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostImageCell.identifier, bundle: nil),
                              forCellReuseIdentifier: NeighborhoodPostImageCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostDeletedCell.identifier, bundle: nil),
                              forCellReuseIdentifier: NeighborhoodPostDeletedCell.identifier)
        ui_tableview.register(UINib(nibName: EventDetailTopFullCell.identifier, bundle: nil),
                              forCellReuseIdentifier: EventDetailTopFullCell.identifier)
        ui_tableview.register(UINib(nibName: EventDetailTopLightCell.identifier, bundle: nil),
                              forCellReuseIdentifier: EventDetailTopLightCell.identifier)
        
        ui_tableview.register(UINib(nibName: NeighborhoodEmptyPostCell.identifier, bundle: nil),
                              forCellReuseIdentifier: NeighborhoodEmptyPostCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostTranslationCell.identifier, bundle: nil),
                              forCellReuseIdentifier: NeighborhoodPostTranslationCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostImageTranslationCell.identifier, bundle: nil),
                              forCellReuseIdentifier: NeighborhoodPostImageTranslationCell.identifier)
        ui_tableview.register(UINib(nibName: NeighborhoodPostSurveyCell.identifier, bundle: nil),
                              forCellReuseIdentifier: NeighborhoodPostSurveyCell.identifier)
        ui_tableview.register(UINib(nibName: EventListSectionCell.identifier, bundle: nil),
                              forCellReuseIdentifier: EventListSectionCell.identifier)
        ui_tableview.register(UINib(nibName: EventListSectionCell.neighborhoodHeaderIdentifier, bundle: nil),
                              forCellReuseIdentifier: EventListSectionCell.neighborhoodHeaderIdentifier)
    }
    
    func setupFloatingButton() {
        let floatItem2 = createButtonItem(title: "neighborhood_menu_post_survey".localized,
                                          iconName: "ic_survey_creation") { item in
            self.showCreateSurvey()
        }
        
        let floatItem3 = createButtonItem(title: "neighborhood_menu_post_post".localized,
                                          iconName: "ic_menu_button_create_post") { item in
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
    
    private func addShadowAndRadius(customView: UIView) {
        customView.clipsToBounds = false
        customView.layer.cornerRadius = customView.frame.height / 2
        customView.layer.shadowColor = UIColor.appOrangeLight.withAlphaComponent(0.5).cgColor
        customView.layer.shadowOpacity = 1
        customView.layer.shadowOffset = CGSize(width: 4, height: 4)
        customView.layer.shadowRadius = 4
    }
    
    func setupViews() {
        maxImageHeight = ui_iv_event.frame.height
        
        ui_view_height_constraint.constant = maxViewHeight
        viewNormalHeight = ui_view_height_constraint.constant
        
        let topPadding = ApplicationTheme.getTopIPhonePadding()
        let inset = UIEdgeInsets(top: viewNormalHeight - topPadding, left: 0, bottom: 0, right: 0)
        minViewHeight += topPadding - 20
        
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
    
    func populateTopView(isAfterLoading: Bool) {
        let imageName = "placeholder_photo_group"
        if let _url = self.event?.metadata?.landscape_url,
           let url = URL(string: _url) {
            
            self.ui_iv_event.sd_setImage(with: url, placeholderImage: nil) { [weak self] image, error, _, _ in
                if error != nil {
                    self?.ui_iv_event.image = UIImage(named: imageName)
                }
            }
            
            self.ui_iv_event_mini.sd_setImage(with: url,
                                              placeholderImage: nil,
                                              options: .progressiveLoad) { [weak self] image, error, _, _ in
                if error != nil {
                    self?.ui_iv_event_mini.image = UIImage(named: imageName)
                }
            }
            
            self.ui_iv_event2.sd_setImage(with: url, placeholderImage: nil) { [weak self] image, error, _, _ in
                if error != nil {
                    self?.ui_iv_event2.image = UIImage(named: imageName)
                }
            }
        }
        else if isAfterLoading {
            self.ui_iv_event.image = UIImage(named: imageName)
            self.ui_iv_event_mini.image = UIImage(named: imageName)
            self.ui_iv_event2.image = UIImage(named: imageName)
        }
        
        self.ui_label_title_event.text = self.event?.title
        // On affiche le bouton + seulement si l’event nous considère comme membre
        self.ui_floaty_bouton?.isHidden = !(self.event?.isMember ?? false)
        
        // Le bouton "participer" du bas est caché de base
        self.ui_bt_floating_join.isHidden = true
    }
    
    // MARK: - Actions
    
    @objc private func refreshEvent() {
        updateEvent()
    }
    
    @objc func updateEvent() {
        getEventDetail(hasToRefreshLists: true)
    }
    
    func sendLeaveGroup() {
        IHProgressHUD.show()
        EventService.leaveEvent(eventId: eventId, userId: UserDefaults.currentUser!.sid) { event, error in
            IHProgressHUD.dismiss()
            // On ne change plus rien immédiatement dans l’UI,
            // car on a déjà forcé le mode "Participer" localement.
            self.getEventDetail(hasToRefreshLists: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Récupération Event
    
    @objc func getEventDetail(hasToRefreshLists: Bool = false) {
        self.currentPagingPage = 1
        self.isLoading = true
        
        var _eventId = ""
        if eventId != 0 {
            _eventId = String(eventId)
        } else if !hashedEventId.isEmpty {
            _eventId = hashedEventId
        }
        
        EventService.getEventWithId(_eventId) { event, error in
            self.pullRefreshControl.endRefreshing()
            if let _ = error {
                self.goBack()
            }
            if event == nil {
                let alertController = UIAlertController(title: "Attention",
                                                        message: "Cet événement a été supprimé",
                                                        preferredStyle: .alert)
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
            
            if self.shouldOpenNativeAgenda {
                self.shouldOpenNativeAgenda = false
                self.showAddCalendar()
            }
            if hasToRefreshLists {
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationEventsUpdate),
                                                object: nil)
            }
            self.ui_tableview.reloadData()
        }
        getEventusers()
    }
    
    func getEventusers() {
        guard let event = event else { return }
        EventService.getEventUsers(eventId: event.uid) { users, error in
            if let _ = error {
                self.goBack()
            }
            if let _users = users {
                for _user in _users {
                    if _user.sid == event.author?.uid {
                        if let _roles = _user.communityRoles {
                            if _roles.contains("Équipe Entourage") ||
                               _roles.contains("Ambassadeur") {
                                self.isUserAmbassador = true
                            }
                        }
                    }
                }
            }
            self.ui_tableview.reloadData()
        }
    }
    
    func getMorePosts() {
        self.isLoading = true
        EventService.getEventPostsPaging(id: eventId,
                                         currentPage: currentPagingPage,
                                         per: itemsPerPage) { post, error in
            guard let post = post, error == nil else {
                self.isLoading = false
                return
            }
            DispatchQueue.main.async {
                self.event?.posts?.append(contentsOf: post)
                self.splitMessages()
                
                self.ui_tableview.performBatchUpdates({
                    let currentSections = self.ui_tableview.numberOfSections
                    if self.event?.posts?.isEmpty ?? true {
                        // Aucune publication
                    } else {
                        if self.hasNewAndOldSections {
                            if currentSections == 1 {
                                self.ui_tableview.insertSections(IndexSet(integer: 1), with: .fade)
                            }
                            self.ui_tableview.reloadSections(IndexSet(integer: 2), with: .fade)
                        }
                        else if currentSections == 3 {
                            self.ui_tableview.deleteSections(IndexSet(integer: 2), with: .fade)
                            self.ui_tableview.reloadSections(IndexSet(integer: 1), with: .fade)
                        }
                        else {
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
        hasNewAndOldSections = !messagesOld.isEmpty && !messagesNew.isEmpty
    }
    
    // MARK: - Joindre / Quitter (uniquement action manuelle)
    
    /// Sans dépendre du retour du serveur : on modifie localement `event?.isMember`
    /// et on recharge la tableView pour mettre à jour la cell du haut.
    func addRemoveMember(isAdd: Bool) {
        if isAdd {
            // On veut participer → on force localement la logique
            event?.isMember = true
            isAfterCreation = false
            ui_tableview.reloadSections(IndexSet(integer: 0), with: .automatic)
            
            IHProgressHUD.show()
            EventService.joinEvent(eventId: eventId) { user, error in
                IHProgressHUD.dismiss()
                // Pas de MAJ UI supplémentaire
            }
        }
        else {
            // On quitte l’événement
            event?.isMember = false
            ui_tableview.reloadSections(IndexSet(integer: 0), with: .automatic)
            
            IHProgressHUD.show()
            EventService.leaveEvent(eventId: eventId,
                                    userId: UserDefaults.currentUser!.sid) { event, error in
                IHProgressHUD.dismiss()
            }
        }
    }
    
    /// Appelée lors du clic sur le bouton “Participer/Quitter”
    func joinLeaveEvent() {
        let currentUserId = UserDefaults.currentUser?.sid
        if event?.author?.uid == currentUserId {
            return
        }
        
        if let _ = event?.members?.first(where: { $0.uid == currentUserId }) {
            addRemoveMember(isAdd: false)
        } else {
            addRemoveMember(isAdd: true)
        }
    }
    
    // MARK: - IBAction
    
    @IBAction func action_show_params(_ sender: Any) {
        if let _event = event {
            if let navvc = UIStoryboard(name: StoryboardName.event, bundle: nil)
                .instantiateViewController(withIdentifier: "params_eventNav") as? UINavigationController,
               let vc = navvc.topViewController as? EventParamsViewController {
                AnalyticsLoggerManager.logEvent(name: Event_detail_action_param)
                vc.event = _event
                vc.delegate = self
                vc.modalPresentationStyle = .fullScreen
                present(navvc, animated: true, completion: nil)
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
    
    // MARK: - Autres
    
    func showCreatePost() {
        let sb = UIStoryboard(name: StoryboardName.neighborhoodMessage, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "addPostVC") as? NeighborhoodPostAddViewController {
            vc.eventId = self.eventId
            vc.isNeighborhood = false
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showCreateSurvey() {
        let sb = UIStoryboard(name: StoryboardName.survey, bundle: nil)
        if let vc = sb.instantiateViewController(withIdentifier: "create_survey") as? CreateSurveyViewController {
            vc.eventId = self.eventId
            vc.delegate = self
            vc.modalPresentationStyle = .fullScreen
            self.navigationController?.present(vc, animated: true)
        }
    }
    
    func showPopInfoPlaces() {
        let customAlert = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized,
                                             titleStyle: ApplicationTheme.getFontCourantBoldBlanc(),
                                             bgColor: .appOrange,
                                             cornerRadius: -1)
        
        customAlert.configureAlert(alertTitle: "event_add_contact_places_title".localized,
                                   message: "event_add_contact_places_description".localized,
                                   buttonrightType: buttonCancel,
                                   buttonLeftType: nil,
                                   titleStyle: ApplicationTheme.getFontCourantBoldOrange(),
                                   messageStyle: ApplicationTheme.getFontCourantRegularNoir(),
                                   mainviewBGColor: .white,
                                   mainviewRadius: 35)
        
        customAlert.alertTagName = .Suppress
        customAlert.delegate = self
        customAlert.show()
    }
    
    // MARK: - Agenda
    
    func addToCalendar() {
        let store = EKEventStore()
        store.requestAccess(to: .event) { granted, error in
            if granted && error == nil {
                self.showPopCalendar()
            }
            else {
                DispatchQueue.main.async {
                    let alertVC = MJAlertController()
                    alertVC.alertTagName = .AcceptSettings
                    let buttonCancel = MJAlertButtonType(title: "event_add_contact_refuse".localized,
                                                         titleStyle: ApplicationTheme.getFontCourantBoldBlanc(),
                                                         bgColor: .appOrangeLight,
                                                         cornerRadius: -1)
                    let buttonValidate = MJAlertButtonType(title: "event_add_contact_activate".localized,
                                                           titleStyle: ApplicationTheme.getFontCourantBoldBlanc(),
                                                           bgColor: .appOrange,
                                                           cornerRadius: -1)
                    
                    alertVC.configureAlert(alertTitle: "errorSettings".localized,
                                           message: "event_add_contact_error".localized,
                                           buttonrightType: buttonValidate,
                                           buttonLeftType: buttonCancel,
                                           titleStyle: ApplicationTheme.getFontCourantBoldOrange(),
                                           messageStyle: ApplicationTheme.getFontCourantRegularNoir(),
                                           mainviewBGColor: .white,
                                           mainviewRadius: 35,
                                           isButtonCloseHidden: true)
                    
                    alertVC.delegate = self
                    alertVC.show()
                }
            }
        }
    }
    
    func showPopCalendar() {
        DispatchQueue.main.async {
            let alertVC = MJAlertController()
            alertVC.alertTagName = .AcceptAdd
            let buttonCancel = MJAlertButtonType(title: "event_add_contact_no".localized,
                                                 titleStyle: ApplicationTheme.getFontCourantBoldBlanc(),
                                                 bgColor: .appOrangeLight,
                                                 cornerRadius: -1)
            let buttonValidate = MJAlertButtonType(title: "event_add_contact_yes".localized,
                                                   titleStyle: ApplicationTheme.getFontCourantBoldBlanc(),
                                                   bgColor: .appOrange,
                                                   cornerRadius: -1)
            alertVC.configureAlert(alertTitle: "event_add_contact_title".localized,
                                   message: "event_add_contact_description".localized,
                                   buttonrightType: buttonValidate,
                                   buttonLeftType: buttonCancel,
                                   titleStyle: ApplicationTheme.getFontCourantBoldOrange(),
                                   messageStyle: ApplicationTheme.getFontCourantRegularNoir(),
                                   mainviewBGColor: .white,
                                   mainviewRadius: 35,
                                   isButtonCloseHidden: true)
            
            alertVC.delegate = self
            alertVC.show()
        }
    }
    
    func showAddCalendar() {
        let store = EKEventStore()
        store.requestAccess(to: .event) { granted, error in
            if granted && error == nil {
                let ekEvent = EKEvent(eventStore: store)
                ekEvent.title = self.event?.title
                ekEvent.startDate = self.event?.getMetadateStartDate()
                ekEvent.endDate = self.event?.getMetadateEndDate()
                
                if let _url = self.event?.onlineEventUrl,
                   let url = URL(string: _url) {
                    ekEvent.url = url
                }
                else if let _lat = self.event?.location?.latitude,
                        let _long = self.event?.location?.longitude {
                    let _structLocation = EKStructuredLocation()
                    _structLocation.geoLocation = CLLocation(latitude: _lat, longitude: _long)
                    _structLocation.title = self.event?.addressName
                    ekEvent.structuredLocation = _structLocation
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
        }
    }
}

// MARK: - UITableViewDataSource / Delegate
extension EventDetailFeedViewController: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        let minimum = (self.event != nil) ? 2 : 0
        let added = hasNewAndOldSections ? 1 : 0
        return minimum + added
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 { return 1 }
        
        if hasNewAndOldSections {
            if section == 1 {
                return messagesNew.count + 2
            } else {
                return messagesOld.count + 1
            }
        }
        
        let messageCount = (self.event?.posts?.count ?? 0)
        if messageCount == 0 {
            return 1
        }
        return messageCount + countToAdd()
    }
    
    func countToAdd() -> Int {
        return (self.event?.isMember ?? false) && !messagesNew.isEmpty ? 2 : 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            if (self.event?.isMember ?? false) && (!isAfterCreation) {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailTopLightCell.identifier,
                                                         for: indexPath) as! EventDetailTopLightCell
                cell.populateCell(event: self.event,
                                  delegate: self,
                                  isEntourageEvent: isUserAmbassador,
                                  members: self.users)
                return cell
            }
            else {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailTopFullCell.identifier,
                                                         for: indexPath) as! EventDetailTopFullCell
                cell.populateCell(event: self.event,
                                  delegate: self,
                                  isEntourageEvent: isUserAmbassador)
                return cell
            }
        }
        
        if self.event?.posts?.isEmpty ?? true {
            let cell = tableView.dequeueReusableCell(withIdentifier: NeighborhoodEmptyPostCell.identifier,
                                                     for: indexPath) as! NeighborhoodEmptyPostCell
            cell.populateCell(isEvent: true)
            return cell
        }
        
        if hasNewAndOldSections && indexPath.section == 2 {
            if indexPath.row == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.identifier,
                                                         for: indexPath) as! EventListSectionCell
                cell.populateCell(title: "event_detail_post_section_old_posts_title".localized,
                                  isTopHeader: false)
                return cell
            }
            let postmessage = messagesOld[indexPath.row - 1]
            return makePostCell(post: postmessage, indexPath: indexPath)
        }
        
        if indexPath.row == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.neighborhoodHeaderIdentifier,
                                                     for: indexPath) as! EventListSectionCell
            cell.populateCell(title: "event_detail_post_section_title".localized,
                              isTopHeader: true)
            return cell
        }
        
        let cta = countToAdd()
        if cta == 2, indexPath.row == 1 {
            let titleSection = (hasNewAndOldSections || messagesOld.isEmpty)
                ? "event_detail_post_section_new_posts_title".localized
                : "event_detail_post_section_old_posts_title".localized
            let cell = tableView.dequeueReusableCell(withIdentifier: EventListSectionCell.identifier,
                                                     for: indexPath) as! EventListSectionCell
            cell.populateCell(title: titleSection, isTopHeader: false)
            return cell
        }
        
        let postmessage: PostMessage
        if hasNewAndOldSections {
            postmessage = messagesNew[indexPath.row - cta]
        } else {
            postmessage = event!.posts![indexPath.row - cta]
        }
        
        return makePostCell(post: postmessage, indexPath: indexPath)
    }
    
    private func makePostCell(post: PostMessage, indexPath: IndexPath) -> UITableViewCell {
        var identifier = post.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
        
        if post.survey != nil {
            identifier = NeighborhoodPostSurveyCell.identifier
        }
        if post.status == "deleted" || post.status == "offensive" || post.status == "offensible" {
            identifier = NeighborhoodPostDeletedCell.identifier
        }
        if let fromLang = post.contentTranslations?.from_lang,
           fromLang != LanguageManager.getCurrentDeviceLanguage(),
           UserDefaults.currentUser?.sid != post.user?.sid {
            identifier = post.isPostImage ? NeighborhoodPostImageTranslationCell.identifier : NeighborhoodPostTranslationCell.identifier
        }
        if post.contentTranslations == nil {
            identifier = post.isPostImage ? NeighborhoodPostImageCell.identifier : NeighborhoodPostTextCell.identifier
        }
        
        let cell = ui_tableview.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! NeighborhoodPostCell
        cell.populateCell(message: post,
                          delegate: self,
                          currentIndexPath: indexPath,
                          userId: post.user?.sid,
                          isMember: self.event?.isMember)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView,
                   willDisplay cell: UITableViewCell,
                   forRowAt indexPath: IndexPath) {
        if isLoading { return }
        var realIndex: Int = hasNewAndOldSections ? indexPath.row - 1 : indexPath.row - 2
        let messageCount = event?.posts?.count ?? 0
        let lastIndex = messageCount - nbOfItemsBeforePagingReload
        if realIndex == lastIndex && messageCount >= itemsPerPage * currentPagingPage {
            currentPagingPage += 1
            getMorePosts()
        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        UIView.animate(withDuration: 0) {
            let yImage = self.maxImageHeight - (scrollView.contentOffset.y + self.maxImageHeight)
            let diffImage = self.maxViewHeight - self.maxImageHeight
            let heightImage = min(max(yImage - diffImage, self.minImageHeight), self.maxImageHeight)
            
            self.ui_view_button_settings.alpha = heightImage / self.maxImageHeight
            self.ui_view_button_back.alpha = heightImage / self.maxImageHeight
            self.ui_iv_event2.alpha = heightImage / self.maxImageHeight
            self.ui_view_top_bg.alpha = 1 - (heightImage / self.maxImageHeight)
            self.ui_iv_event_mini.alpha = 1 - (heightImage / self.maxImageHeight)
            self.ui_label_title_event.alpha = 1 - (heightImage / self.maxImageHeight)
            self.ui_view_canceled.alpha = heightImage / self.maxImageHeight
            
            let yView = self.viewNormalHeight - (scrollView.contentOffset.y + self.viewNormalHeight)
            let heightView = min(max(yView, self.minViewHeight), self.maxViewHeight)
            self.ui_view_height_constraint.constant = heightView
            
            if !(self.event?.isMember ?? false) {
                self.ui_bt_floating_join.isHidden = scrollView.contentOffset.y < self.minTopScrollHeight
            }
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - MJAlertControllerDelegate
extension EventDetailFeedViewController: MJAlertControllerDelegate {
    func validateLeftButton(alertTag: MJAlertTAG) {}
    func validateRightButton(alertTag: MJAlertTAG) {
        if alertTag == .None {
            self.event?.isMember = false
            self.isAfterCreation = false
            self.ui_tableview.reloadSections(IndexSet(integer: 0), with: .automatic)
            self.sendLeaveGroup()
        }
        
        if alertTag == .AcceptSettings {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        }
        
        if alertTag == .AcceptAdd {
            self.showAddCalendar()
        }
    }
    
    func closePressed(alertTag: MJAlertTAG) {}
}

// MARK: - MJNavBackViewDelegate
extension EventDetailFeedViewController: MJNavBackViewDelegate {
    func goBack() {
        self.navigationController?.dismiss(animated: true)
    }
}

// MARK: - EventDetailTopCellDelegate
extension EventDetailFeedViewController: EventDetailTopCellDelegate {
    func share() {
        var stringUrl = "https://"
        var title = ""
        if NetworkManager.sharedInstance.getBaseUrl().contains("preprod") {
            stringUrl += "preprod.entourage.social/app/"
        } else {
            stringUrl += "www.entourage.social/app/"
        }
        if let _event = event {
            stringUrl += "outings/" + _event.uuid_v2
            title = "share_event".localized + "\n" + _event.title + ": "
        }
        let url = URL(string: stringUrl)!
        let shareText = "\(title)\n\n\(stringUrl)"
        
        let activityViewController = UIActivityViewController(activityItems: [shareText, url],
                                                              applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        AnalyticsLoggerManager.logEvent(name: event_share)
    }
    
    func showUser() {
        // Implémentation éventuelle
    }
    
    func showWebUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
    
    func showMembers() {
        if let navVC = UIStoryboard(name: StoryboardName.neighborhood, bundle: nil)
            .instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController,
           let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.isEvent = true
            present(navVC, animated: true)
        }
    }
    
    func showMemberReact(postId: Int) {
        if let navVC = UIStoryboard(name: StoryboardName.neighborhood, bundle: nil)
            .instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController,
           let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.postId = postId
            vc.eventId = eventId
            vc.isFromReact = true
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    func showVote(post: PostMessage) {
        if let navVC = UIStoryboard(name: StoryboardName.neighborhood, bundle: nil)
            .instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController,
           let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
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
        if let navVC = UIStoryboard(name: StoryboardName.event, bundle: nil)
            .instantiateViewController(withIdentifier: "eventDetailFullNav") as? UINavigationController,
           let vc = navVC.topViewController as? EventDetailFullFeedViewController {
            vc.eventId = eventId
            vc.event = event
            vc.isEntourageEvent = isUserAmbassador
            self.navigationController?.present(navVC, animated: true)
        }
    }
    
    func showPlace() {
        if event?.isCanceled() ?? false { return }
        if event?.isOnline ?? false,
           let urlStr = event?.onlineEventUrl {
            WebLinkManager.openUrl(url: URL(string: urlStr), openInApp: false, presenterViewController: self)
        }
        else {
            if let _address = event?.metadata?.display_address?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let mapString = String(format: "https://maps.apple.com/?address=%@", _address)
                WebLinkManager.openUrl(url: URL(string: mapString), openInApp: false, presenterViewController: self)
            }
        }
    }
}

// MARK: - NeighborhoodPostCellDelegate
extension EventDetailFeedViewController: NeighborhoodPostCellDelegate {
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
        let alertController = UIAlertController(title: "Attention",
                                                message: "Vous devez rejoindre le groupe pour effectuer cette action.",
                                                preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func onReactClickSeeMember(post: PostMessage) {
        self.showMemberReact(postId: post.uid)
    }
    
    func addReaction(post: PostMessage, reactionType: ReactionType) {
        var reactionWrapper = ReactionWrapper()
        reactionWrapper.reactionId = reactionType.id
        EventService.postReactionToEventPost(eventId: self.eventId, postId: post.uid, reactionWrapper: reactionWrapper) { error in
            // Gestion éventuelle d'erreur
        }
    }
    
    func deleteReaction(post: PostMessage, reactionType: ReactionType) {
        EventService.deleteReactionToEventPost(eventId: self.eventId, postId: post.uid) { error in
            // Gestion éventuelle d'erreur
        }
    }
    
    func showWebviewUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
    
    func showImage(imageUrl: URL?, postId: Int) {
        getDetailPost(eventId: self.eventId, parentPostId: postId)
    }
    
    func signalPost(postId: Int, userId: Int, textString: String) {
        if let navVC = UIStoryboard(name: StoryboardName.neighborhoodReport, bundle: nil)
            .instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController,
           let vc = navVC.topViewController as? ReportGroupMainViewController {
            vc.eventId = eventId
            vc.postId = postId
            vc.parentDelegate = self
            vc.userId = userId
            vc.signalType = .publication
            vc.textString = textString
            self.present(navVC, animated: true)
        }
    }
    
    func showMessages(addComment: Bool,
                      postId: Int,
                      indexPathSelected: IndexPath?,
                      postMessage: PostMessage?) {
        let sb = UIStoryboard(name: StoryboardName.eventMessage, bundle: nil)
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
        if let navVC = UIStoryboard.init(name: StoryboardName.profileParams, bundle: nil).instantiateViewController(withIdentifier: "profileFull") as? UINavigationController {
            if let _homeVC = navVC.topViewController as? ProfilFullViewController {
                _homeVC.userIdToDisplay = "\(userId)"
                self.navigationController?.present(navVC, animated: true)
            }
        }
    }
}

// MARK: - UpdateEventCommentDelegate
extension EventDetailFeedViewController: UpdateCommentCountDelegate {
    func updateCommentCount(parentCommentId: Int,
                            nbComments: Int,
                            currentIndexPathSelected: IndexPath?) {
        guard let posts = event?.posts else { return }
        if let index = posts.firstIndex(where: { $0.uid == parentCommentId }) {
            event?.posts?[index].commentsCount = nbComments
        }
        splitMessages()
        if let idx = currentIndexPathSelected {
            ui_tableview.reloadRows(at: [idx], with: .none)
        } else {
            ui_tableview.reloadData()
        }
    }
}

// MARK: - EKEventEditViewDelegate
extension EventDetailFeedViewController: EKEventEditViewDelegate {
    func eventEditViewController(_ controller: EKEventEditViewController,
                                 didCompleteWith action: EKEventEditViewAction) {
        controller.dismiss(animated: true, completion: nil)
    }
}

// MARK: - UIScrollViewDelegate (pour zoom)
extension EventDetailFeedViewController: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return ui_iv_preview
    }
}

// MARK: - GroupDetailDelegate
extension EventDetailFeedViewController: GroupDetailDelegate {
    func translateItem(id: Int) {
        // Implémenter la traduction si nécessaire
    }
    
    func publicationDeleted() {
        getEventDetail()
        ui_tableview.reloadData()
    }
    
    func showMessage(signalType: GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(title: "OK".localized,
                                             titleStyle: ApplicationTheme.getFontCourantBoldBlanc(),
                                             bgColor: .appOrange,
                                             cornerRadius: -1)
        let title = signalType == .comment ? "report_comment_title".localized : "report_publication_title".localized
        
        alertVC.configureAlert(alertTitle: title,
                               message: "report_group_message_success".localized,
                               buttonrightType: buttonCancel,
                               buttonLeftType: nil,
                               titleStyle: ApplicationTheme.getFontCourantBoldOrange(),
                               messageStyle: ApplicationTheme.getFontCourantRegularNoir(),
                               mainviewBGColor: .white,
                               mainviewRadius: 35,
                               isButtonCloseHidden: true)
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.1) {
            alertVC.show()
        }
    }
}

// MARK: - Zoom sur image HQ
extension EventDetailFeedViewController {
    func getDetailPost(eventId: Int, parentPostId: Int) {
        EventService.getDetailPostMessage(eventId: eventId, parentPostId: parentPostId) { message, error in
            if let msg = message {
                self.setImageForView(message: msg)
            }
        }
    }
    
    func setImageForView(message: PostMessage) {
        guard let urlString = message.messageImageUrl,
              let imageUrl = URL(string: urlString) else {
            return
        }
        ui_scrollview.zoomScale = 1.0
        
        ui_iv_preview.sd_setImage(with: imageUrl, placeholderImage: nil, options: .refreshCached) { _image, _error, _, _ in
            self.ui_view_full_image.isHidden = (_error != nil)
        }
    }
}

// MARK: - CreateSurveyValidationDelegate
extension EventDetailFeedViewController: CreateSurveyValidationDelegate {
    func onSurveyCreate() {
        self.getEventDetail()
    }
}

// MARK: - FloatyDelegate
extension EventDetailFeedViewController: FloatyDelegate {
    func floatyWillOpen(_ floaty: Floaty) {
        AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_Plus)
        let newHeight: CGFloat = 16
        UIView.animate(withDuration: 0.3) {
            self.ui_constraint_button.constant = newHeight
            self.view.layoutIfNeeded()
        }
    }
    func floatyClosed(_ floaty: Floaty) {
        let newHeight: CGFloat = 16
        UIView.animate(withDuration: 0.3) {
            self.ui_constraint_button.constant = newHeight
            self.view.layoutIfNeeded()
        }
    }
    
    private func createButtonItem(title: String,
                                  iconName: String,
                                  handler: @escaping ((FloatyItem) -> Void)) -> FloatyItem {
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

// MARK: - AmbassadorAskNotificationPopupDelegate
extension EventDetailFeedViewController: AmbassadorAskNotificationPopupDelegate {
    func joinAsOrganizer() {
        event?.isMember = true
        isAfterCreation = false
        ui_tableview.reloadSections(IndexSet(integer: 0), with: .automatic)
        
        IHProgressHUD.show()
        EventService.joinEventAsOrganizer(eventId: eventId) { user, error in
            IHProgressHUD.dismiss()
            // Pas de mise à jour UI supplémentaire
        }
    }
    
    func justParticipate() {
        event?.isMember = true
        isAfterCreation = false
        ui_tableview.reloadSections(IndexSet(integer: 0), with: .automatic)
        
        IHProgressHUD.show()
        EventService.joinEvent(eventId: eventId) { user, error in
            IHProgressHUD.dismiss()
        }
    }
}

extension EventDetailFeedViewController: EventParamDelegate {
    func reloadView() {
        updateEvent()
    }
}

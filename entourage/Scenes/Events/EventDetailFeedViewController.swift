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
    
    
    @IBOutlet weak var ui_view_full_image: UIView!
    @IBOutlet weak var ui_scrollview: UIScrollView!
    @IBOutlet weak var ui_iv_preview: UIImageView!
    
    @IBOutlet weak var ui_btn_participate_and_see_conv: UIButton!
    // Pour afficher/cacher le bouton « Participer » lors du scroll
    @IBOutlet weak var ui_title_bt_join: UILabel!
    @IBOutlet weak var ui_bt_floating_join: UIView!
    
    let addHeight: CGFloat = ApplicationTheme.iPhoneHasNotch() ? 0 : 20
    var minTopScrollHeight: CGFloat = 120
    
    // Utilisé pour étirer l’en-tête
    var maxViewHeight: CGFloat = 150
    var minViewHeight: CGFloat = 80 // 70 + 19
    var maxImageHeight: CGFloat = 73
    var minImageHeight: CGFloat = 0
    var viewNormalHeight: CGFloat = 0
    
    var eventId: Int = 0
    var hashedEventId: String = ""
    var event: Event? = nil
    var isUserAmbassador = false
    
    /// Sert uniquement à la condition d’affichage "LightCell" vs "FullCell":
    ///  (event.isMember) && !isAfterCreation => LightCell
    /// Ici on la conserve, mais on n’utilise plus la LightCell
    var isAfterCreation = false
    
    /// Indique si l’écran doit s’ouvrir directement sur la création de post
    var isShowCreatePost = false
    
    /// Pour détecter si l’on doit ouvrir automatiquement le calendrier
    var shouldOpenNativeAgenda = false
    
    /// Permet le pull-to-refresh (mise à jour de l’événement)
    var pullRefreshControl = UIRefreshControl()
    
    // Stocke la liste des utilisateurs participants
    var users: [UserLightNeighborhood] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()

        ui_tableview.dataSource = self
        ui_tableview.delegate = self
        
        minTopScrollHeight += addHeight
        
        if !ApplicationTheme.iPhoneHasNotch() {
            maxViewHeight -= 20
        }
        
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
        
        
        ui_view_canceled.isHidden = true
        
        ui_view_full_image.isHidden = true
        ui_scrollview.delegate = self
        ui_scrollview.maximumZoomScale = 10
        
        // Tracking analytique
        AnalyticsLoggerManager.logEvent(name: Event_detail_main)
        configureOrangeButton(self.ui_btn_participate_and_see_conv, withTitle: "event_conversation".localized)
        ui_btn_participate_and_see_conv.addTarget(self, action: #selector(button_join_leave_see), for: .touchUpInside)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Si on doit ouvrir l’écran de création de post
        if isShowCreatePost {
            showCreatePost()
            isShowCreatePost = false
        }
        
        // Charger les infos côté serveur
        getEventMembers()
        getEventDetail()
    }
    
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 13)
        button.clipsToBounds = true
        if let image = button.imageView?.image {
            let tintedImage = image.withRenderingMode(.alwaysTemplate)
            button.setImage(tintedImage, for: .normal)
            button.tintColor = .white // Force l'icône en noir
        }
    }
    
    
    // MARK: - Setup
    
    func registerCellsNib() {
        // On ne garde que la FullCell
        ui_tableview.register(UINib(nibName: EventDetailTopFullCell.identifier, bundle: nil),
                              forCellReuseIdentifier: EventDetailTopFullCell.identifier)
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
        
        // Pull to refresh => recharger l’événement
        pullRefreshControl.attributedTitle = NSAttributedString(string: "Loading".localized)
        pullRefreshControl.tintColor = .appOrange
        pullRefreshControl.addTarget(self, action: #selector(refreshEvent), for: .valueChanged)
        ui_tableview.refreshControl = pullRefreshControl
        
        // Bouton « Participer » en bas
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
            
            self.ui_iv_event.sd_setImage(with: url, placeholderImage: nil) { [weak self] _, error, _, _ in
                if error != nil {
                    self?.ui_iv_event.image = UIImage(named: imageName)
                }
            }
            
            self.ui_iv_event_mini.sd_setImage(with: url,
                                              placeholderImage: nil,
                                              options: .progressiveLoad) { [weak self] _, error, _, _ in
                if error != nil {
                    self?.ui_iv_event_mini.image = UIImage(named: imageName)
                }
            }
            
            self.ui_iv_event2.sd_setImage(with: url, placeholderImage: nil) { [weak self] _, error, _, _ in
                if error != nil {
                    self?.ui_iv_event2.image = UIImage(named: imageName)
                }
            }
        }
        else if isAfterLoading {
            // Si on a tenté de charger une image et qu’il n’y en a pas
            self.ui_iv_event.image = UIImage(named: imageName)
            self.ui_iv_event_mini.image = UIImage(named: imageName)
            self.ui_iv_event2.image = UIImage(named: imageName)
        }
        
        self.ui_label_title_event.text = self.event?.title
        self.ui_bt_floating_join.isHidden = true
    }
    
    // MARK: - Actions
    
    @objc private func refreshEvent() {
        updateEvent()
    }
    
    @objc func updateEvent() {
        getEventDetail(hasToRefreshLists: true)
    }
    
    /// Quitter l’event (appel direct, ex. si organisateur)
    func sendLeaveGroup() {
        IHProgressHUD.show()
        EventService.leaveEvent(eventId: eventId, userId: UserDefaults.currentUser!.sid) { _, _ in
            IHProgressHUD.dismiss()
            // Après avoir quitté, on recharge l’événement
            self.getEventDetail(hasToRefreshLists: true)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Récupération Event
    
    @objc func getEventDetail(hasToRefreshLists: Bool = false) {
        // On arrête le refresh si le user a fait un pull-to-refresh
        self.pullRefreshControl.endRefreshing()
        
        var _eventId = ""
        if eventId != 0 {
            _eventId = String(eventId)
        } else if !hashedEventId.isEmpty {
            _eventId = hashedEventId
        }
        
        IHProgressHUD.show()
        EventService.getEventWithId(_eventId) { event, error in
            IHProgressHUD.dismiss()
            
            if let _ = error {
                // En cas d’erreur, on ferme l’écran
                self.goBack()
                return
            }
            
            if event == nil {
                let alertController = UIAlertController(title: "Attention",
                                                        message: "Cet événement a été supprimé",
                                                        preferredStyle: .alert)
                let closeAction = UIAlertAction(title: "Fermer", style: .default, handler: nil)
                alertController.addAction(closeAction)
                self.present(alertController, animated: true, completion: nil)
                return
            }
            
            self.event = event
            self.eventId = event?.uid ?? 0
            
            // Si l’événement est annulé => on affiche le bandeau
            if event?.isCanceled() ?? false {
                self.ui_view_canceled.isHidden = false
            }
            else {
                self.ui_view_canceled.isHidden = true
            }
            
            // Met à jour la topView
            self.populateTopView(isAfterLoading: true)
            
            // Ouvre l’agenda natif si besoin
            if self.shouldOpenNativeAgenda {
                self.shouldOpenNativeAgenda = false
                self.showAddCalendar()
            }
            
            // Notifie éventuellement d’autres écrans
            if hasToRefreshLists {
                NotificationCenter.default.post(name: NSNotification.Name(kNotificationEventsUpdate),
                                                object: nil)
            }
            
            // Recharge la table => affichage de la top cell
            self.ui_tableview.reloadData()
        }
    }
    
    func getEventMembers() {
        // Charge la liste des membres (participants)
        EventService.getEventUsers(eventId: self.eventId) { users, _ in
            if let _users = users {
                self.users = _users
            }
        }
    }
    
    // MARK: - Joindre / Quitter (action manuelle)
    
    func addRemoveMember(isAdd: Bool) {
        // Met à jour localement
        event?.isMember = isAdd
        // La variable isAfterCreation est conservée, mais non utilisée pour l’affichage
        // On la laisse telle quelle
        isAfterCreation = false
        ui_tableview.reloadData()
        
        IHProgressHUD.show()
        if isAdd {
            // On rejoint l’événement
            EventService.joinEvent(eventId: eventId) { _, _ in
                IHProgressHUD.dismiss()
                MessagingService.getDetailConversation(conversationId: self.event?.uuid_v2 ?? "") { conversation, error in
                    print("eho " , error)
                    if let convId = conversation?.uid {
                        let sb = UIStoryboard.init(name: StoryboardName.messages, bundle: nil)
                        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                            vc.setupFromOtherVC(conversationId: convId, title: self.event?.title, isOneToOne: true, conversation: conversation)
                            vc.type = "outing"

                            if let presentedVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController,
                               presentedVC is ConversationDetailMessagesViewController {
                                // Si l'écran est déjà affiché, on ne le recrée pas
                                presentedVC.dismiss(animated: false) {
                                    UIApplication.shared.keyWindow?.rootViewController?.present(vc, animated: true)
                                }
                                return
                            }

                            self.present(vc, animated: true)
                        }
                    }
                }
            }
        } else {
            // On quitte l’événement
            EventService.leaveEvent(eventId: eventId, userId: UserDefaults.currentUser!.sid) { _, _ in
                IHProgressHUD.dismiss()
                MessagingService.getDetailConversation(conversationId: self.event?.uuid_v2 ?? "") { conversation, error in
                    print("eho " , error)
                    if let convId = conversation?.uid {
                        let sb = UIStoryboard.init(name: StoryboardName.messages, bundle: nil)
                        if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                            vc.setupFromOtherVC(conversationId: convId, title: self.event?.title, isOneToOne: true, conversation: conversation)
                            self.present(vc, animated: true)
                        }
                    }
                }
            }
        }
    }
    
    func joinLeaveEvent() {
        guard let currentUserId = UserDefaults.currentUser?.sid else { return }
        
        // On empêche l’auteur de quitter son propre événement
        if event?.author?.uid == currentUserId {
            MessagingService.getDetailConversation(conversationId: self.event?.uuid_v2 ?? "") { conversation, error in
                print("eho " , error)
                if let convId = conversation?.uid {
                    let sb = UIStoryboard.init(name: StoryboardName.messages, bundle: nil)
                    if let vc = sb.instantiateViewController(withIdentifier: "detailMessagesVC") as? ConversationDetailMessagesViewController {
                        vc.setupFromOtherVC(conversationId: convId, title: self.event?.title, isOneToOne: true, conversation: conversation)
                        self.present(vc, animated: true)
                    }
                }
            }
            return
        }
        
        let alreadyMember = event?.members?.contains(where: { $0.uid == currentUserId }) ?? false
        addRemoveMember(isAdd: !alreadyMember)

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
    
    @objc func button_join_leave_see(){
        AnalyticsLoggerManager.logEvent(name: Event_detail_action_participate)
        joinLeaveEvent()
    }
    
    @IBAction func action_join(_ sender: Any) {
        AnalyticsLoggerManager.logEvent(name: Event_detail_action_participate)
        joinLeaveEvent()
    }
    
    @IBAction func action_tap_close_full_image(_ sender: Any) {
        ui_view_full_image.isHidden = true
    }
    
    // MARK: - Création Post / Survey
    
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
        store.requestAccess(to: .event) { granted, _ in
            if granted {
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
                    let structLoc = EKStructuredLocation()
                    structLoc.geoLocation = CLLocation(latitude: _lat, longitude: _long)
                    structLoc.title = self.event?.addressName
                    ekEvent.structuredLocation = structLoc
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
    
    /// Une seule section => on affiche toujours la "FullCell"
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   numberOfRowsInSection section: Int) -> Int {
        // Affiche 0 tant que l’event n’est pas chargé
        guard event != nil else { return 0 }
        return 1
    }
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // Toujours la FullCell, même si la logique du isAfterCreation existe encore
        let cell = tableView.dequeueReusableCell(withIdentifier: EventDetailTopFullCell.identifier,
                                                 for: indexPath) as! EventDetailTopFullCell
        cell.populateCell(event: event,
                          delegate: self,
                          isEntourageEvent: isUserAmbassador)
        return cell
    }
    
    func tableView(_ tableView: UITableView,
                   heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // Gère le scroll pour animer le header
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
            
            // Affichage du bouton “Participer” en bas
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
        // Tag .None => confirmation pour quitter
        if alertTag == .None {
            self.event?.isMember = false
            // on conserve isAfterCreation, mais on n’en fait rien ici
            isAfterCreation = false
            self.ui_tableview.reloadData()
            self.sendLeaveGroup()
        }
        
        // Paramètres pour autoriser l’accès au calendrier
        if alertTag == .AcceptSettings {
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:])
            }
        }
        
        // Ajout au calendrier
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
    func showAgenda() {
        self.addToCalendar()
    }
    
    
    func share() {
        var baseUrl = "https://www.entourage.social/app/"
        if NetworkManager.sharedInstance.getBaseUrl().contains("preprod") {
            baseUrl = "https://preprod.entourage.social/app/"
        }
        guard let _event = event else { return }
        let fullUrl = baseUrl + "outings/" + _event.uuid_v2
        let title = "share_event".localized + "\n" + _event.title + ": "
        
        let shareText = "\(title)\n\n\(fullUrl)"
        let activityViewController = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
        present(activityViewController, animated: true, completion: nil)
        
        AnalyticsLoggerManager.logEvent(name: event_share)
    }
    
    func showUser() {
        // Montre le profil de l’organisateur, si besoin
    }
    
    func showWebUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
    
    func showMembers() {
        // Ouvre la liste des participants
        if let navVC = UIStoryboard(name: StoryboardName.neighborhood, bundle: nil)
            .instantiateViewController(withIdentifier: "users_groupNav") as? UINavigationController,
           let vc = navVC.topViewController as? NeighBorhoodEventListUsersViewController {
            vc.event = event
            vc.isEvent = true
            present(navVC, animated: true)
        }
    }
    
    func showMemberReact(postId: Int) {
        // Plus de feed => rien
    }
    
    func showVote(post: PostMessage) {
        // Plus de feed => rien
    }
    
    func joinLeave() {
        joinLeaveEvent()
    }
    
    func showDetailFull() {
        // Montre l’écran "full" (EventDetailFullFeedViewController) si vous le conservez
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
        // Si l’événement est annulé => on ne fait rien
        if event?.isCanceled() ?? false {
            return
        }
        
        // Événement en ligne => ouvre l’URL
        if event?.isOnline ?? false,
           let urlStr = event?.onlineEventUrl,
           let url = URL(string: urlStr) {
            WebLinkManager.openUrl(url: url, openInApp: false, presenterViewController: self)
        }
        else {
            // Événement physique => ouvre Plans/Maps
            if let _address = event?.metadata?.display_address?.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) {
                let mapString = String(format: "https://maps.apple.com/?address=%@", _address)
                if let url = URL(string: mapString) {
                    WebLinkManager.openUrl(url: url, openInApp: false, presenterViewController: self)
                }
            }
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

// MARK: - CreateSurveyValidationDelegate
extension EventDetailFeedViewController: CreateSurveyValidationDelegate {
    func onSurveyCreate() {
        // Lorsqu’on revient de l’écran de création de sondage, on re-charge l’event
        self.getEventDetail()
    }
}



// MARK: - AmbassadorAskNotificationPopupDelegate
extension EventDetailFeedViewController: AmbassadorAskNotificationPopupDelegate {
    func joinAsOrganizer() {
        event?.isMember = true
        // isAfterCreation reste, mais on ne l’utilise plus pour la cell
        isAfterCreation = false
        ui_tableview.reloadData()
        
        IHProgressHUD.show()
        EventService.joinEventAsOrganizer(eventId: eventId) { _, _ in
            IHProgressHUD.dismiss()
        }
    }
    
    func justParticipate() {
        event?.isMember = true
        isAfterCreation = false
        ui_tableview.reloadData()
        
        IHProgressHUD.show()
        EventService.joinEvent(eventId: eventId) { _, _ in
            IHProgressHUD.dismiss()
        }
    }
}

// MARK: - EventParamDelegate
extension EventDetailFeedViewController: EventParamDelegate {
    func reloadView() {
        updateEvent()
    }
}

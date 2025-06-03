//
//  ConversationDetailMessagesViewController.swift
//  entourage
//
//  Created by Jerome on 23/08/2022.
//  Adapté pour intégrer la fonctionnalité de mention (liste de suggestions, insertion d’AttributedString, etc.)
//  Le filtrage des mentions se fait localement sur la liste de members de la Conversation.
//  Si le query est vide, on affiche 3 membres par défaut.
//

import UIKit
import IQKeyboardManagerSwift
import IHProgressHUD

// MARK: - Struct et Enums

/// Use to transform messages to section date with messages
/// (la structure d’origine pour gérer la transformation des messages en sections de dates)
struct MessagesSorted {
    var messages = [Any]()
    var datesSections = 0
}

/// Enum représentant les types de cellules de la tableView principale (les messages).
/// On veut regrouper au même endroit :
/// - Les cellules “date”
/// - Les cellules “message” standard
/// - Les cellules “message en échec / retry”
private enum ConversationCellDTO {
    case dateString(title:String)
    case message(message:PostMessage)
    case retryMessage(message:PostMessage, positionRetry: Int)
}

/// Enum représentant les types de cellules de la tableView des mentions.
private enum MentionCellDTO {
    case mention(UserLightNeighborhood)
}

class ConversationDetailMessagesViewController: UIViewController {

    // MARK: - IBOutlets
    @IBOutlet weak var ui_bt_title_user: UIButton!
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_view_txtview: UIView!
    @IBOutlet weak var ui_iv_bt_send: UIImageView!
    @IBOutlet weak var ui_view_button_send: UIView!
    @IBOutlet weak var ui_constraint_bottom_view_Tf: NSLayoutConstraint!
    @IBOutlet weak var ui_textview_message: MJTextViewPlaceholder!
    @IBOutlet weak var ui_view_empty: UIView!
    @IBOutlet weak var ui_title_empty: UILabel!

    @IBOutlet weak var ui_constraint_tableview_top_top: NSLayoutConstraint!
    @IBOutlet weak var ui_constraint_tableview_top_margin: NSLayoutConstraint!
    @IBOutlet weak var ui_view_new_conversation: UIView!
    @IBOutlet weak var ui_title_new_conv: UILabel!
    @IBOutlet weak var ui_subtitle_new_conv: UILabel!

    @IBOutlet var ui_tap_gesture: UITapGestureRecognizer!
    @IBOutlet weak var ui_view_block: UIView!
    @IBOutlet weak var ui_title_block: UILabel!
    
    // >>>> Ajoutées dans votre code <<<<
    @IBOutlet weak var ui_iv_event: UIImageView!
    @IBOutlet weak var ui_label_event_discut: UILabel!
    @IBOutlet weak var ui_view_event_discut: UIView!
    @IBOutlet weak var ui_btn_camera: UIButton!
    
    // MARK: - Outlets pour la fonctionnalité de mention
    @IBOutlet weak var ui_tableview_mentions: UITableView! // TableView des suggestions
    @IBOutlet weak var table_view_mention_height: NSLayoutConstraint!
    
    // MARK: - Variables principales
    private var conversationId: Int = 0
    private var hashedConversationId: String = ""
    private var currentMessageTitle: String? = nil
    private var currentUserId: Int = 0
    private var hasToShowFirstMessage = false
    private var isOneToOne = true
    private var selectedIndexPath: IndexPath? = nil
    var isFromMatching = false
    private weak var parentDelegate: UpdateUnreadCountDelegate? = nil
    var type:String = ""
    var isSmallTalkMode = false
    var smallTalkId: String = ""
    var meetUrl:String = ""
    var uuidv2:String = ""
    private var autoRefreshTimer: Timer?
    private let autoRefreshInterval: TimeInterval = 5
    private var isSilentRefresh = false

    /// Liste brute de messages issus de l’API
    var messages = [PostMessage]()
    /// Structure “MessagesSorted” qui contient la liste triée (sections date + messages)
    var messagesExtracted = MessagesSorted()
    /// Identifiant de l’utilisateur courant
    var meId: Int = 0
    /// Liste des messages à retenter (ceux qui ont échoué à l’envoi)
    var messagesForRetry = [PostMessage]()

    /// Placeholder par défaut de la zone de texte
    let placeholderTxt = "messaging_message_placeholder_discut".localized

    /// Contrainte de base avant l’ouverture du clavier
    var bottomConstraint: CGFloat = 0
    var isStartEditing = false

    // MARK: - Pagination
    var currentPage = 1
    let numberOfItemsForWS = 50
    let nbOfItemsBeforePagingReload = 5
    var isLoading = false

    var paramVC: UIViewController? = nil
    var currentConversation: Conversation? = nil

    // MARK: - Propriétés pour la fonctionnalité de mention
    /// (Auparavant on utilisait un tableau de `[UserLightNeighborhood]`. On va maintenant
    ///  stocker un tableau de `MentionCellDTO` pour la tableView des mentions.)
    private var mentionCellDTOs: [MentionCellDTO] = []

    /// Hauteur d’une cellule “MentionCell”
    private let mentionCellHeight: CGFloat = 44.0

    // MARK: - Nouveau : tableau enum pour la tableView principale
    /// On remplace `messagesExtracted.messages + messagesForRetry` par un tableau unique
    /// de ConversationCellDTO
    private var conversationCellDTOs: [ConversationCellDTO] = []

    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // GESTION DU TAP GESTURE
        ui_tap_gesture.cancelsTouchesInView = false
        ui_tap_gesture.delegate = self
        ui_tableview.prefetchDataSource = nil   // désactive le prefetch

        // Configuration label "event_discut"
        ui_label_event_discut.text = "event_discut_title".localized
        ui_label_event_discut.setFontTitle(size: 13)

        IQKeyboardManager.shared.enable = false
        ui_bt_title_user.isHidden = !isOneToOne

        ui_tableview.register(UINib(nibName: DiscussionEventCell.identifier, bundle: nil),
                              forCellReuseIdentifier: DiscussionEventCell.identifier)

        // Vue "vide"
        ui_title_empty.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title_empty.text = "messaging_message_no_message".localized
        ui_view_empty.isHidden = true

        // Zone texte
        ui_view_txtview.layer.borderWidth = 1
        ui_view_txtview.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_txtview.layer.cornerRadius = ui_view_txtview.frame.height / 2

        ui_textview_message.delegate = self
        ui_textview_message.hasToCenterTextVerticaly = true

        ui_view_button_send.backgroundColor = .clear
        ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")

        // Blocage
        ui_view_block.layer.borderWidth = 1
        ui_view_block.layer.borderColor = UIColor.appGris112.cgColor
        ui_view_block.layer.cornerRadius = ui_view_block.frame.height / 2
        ui_title_block.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15, color: .appGris112))
        ui_view_block.isHidden = true

        // Toolbar
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        let buttonDone = UIBarButtonItem(title: "messaging_message_send".localized, style: .plain, target: self, action: #selector(closeKb(_:)))
        ui_textview_message.addToolBar(width: _width, buttonValidate: buttonDone)
        ui_textview_message.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_textview_message.placeholderText = placeholderTxt
        ui_textview_message.placeholderColor = .appOrange

        // Current user
        guard let me = UserDefaults.currentUser else {
            return goBack()
        }
        meId = me.sid

        // MENTIONS
        ui_tableview_mentions.delegate = self
        ui_tableview_mentions.dataSource = self
        ui_tableview_mentions.register(UINib(nibName: MentionCell.identifier, bundle: nil), forCellReuseIdentifier: MentionCell.identifier)
        ui_tableview_mentions.isHidden = true
        table_view_mention_height.constant = 0

        // NOTIFS
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
        bottomConstraint = ui_constraint_bottom_view_Tf.constant

        NotificationCenter.default.addObserver(self, selector: #selector(closeFromParams), name: NSNotification.Name(rawValue: kNotificationMessagesUpdate), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userBlockedFromParams), name: NSNotification.Name(rawValue: kNotificationMessagesUpdateUserBlocked), object: nil)

        // Vue “nouvelle conversation”
        ui_title_new_conv.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        ui_subtitle_new_conv.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title_new_conv.text = "message_title_new_conv".localized
        ui_subtitle_new_conv.text = "message_subtitle_new_conv".localized
        hideViewNew()

        // CONFIG TYPE (outing/smalltalk/other)
        if type == "outing" {
            ui_constraint_tableview_top_margin.constant = 90
            ui_view_new_conversation.isHidden = false
            ui_view_event_discut.isHidden = false
            ui_view_new_conversation.backgroundColor = UIColor.white
            ui_title_new_conv.text = ""
            ui_subtitle_new_conv.text = ""
        } else {
            ui_constraint_tableview_top_margin.constant = 0
            ui_view_new_conversation.backgroundColor = UIColor.appBeige
            ui_title_new_conv.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
            ui_subtitle_new_conv.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
            ui_title_new_conv.text = "message_title_new_conv".localized
            ui_subtitle_new_conv.text = "message_subtitle_new_conv".localized

            // ➕ Active aussi la vue en SmallTalk
            if isSmallTalkMode {
                showViewNew()
                ui_view_event_discut.isHidden = false
                ui_view_new_conversation.isHidden = false
                ui_view_new_conversation.backgroundColor = UIColor.clear
                ui_title_new_conv.text = ""
                ui_subtitle_new_conv.text = ""
                ui_label_event_discut.text = "small_talk_btn_charte".localized
                ui_iv_event.image = UIImage(named: "ic_charte")
            } else {
                ui_view_event_discut.isHidden = true
            }
        }
        let tapCharte = UITapGestureRecognizer(target: self, action: #selector(handleCharteTapped))
        ui_view_event_discut.addGestureRecognizer(tapCharte)
        ui_view_event_discut.isUserInteractionEnabled = true

        ui_textview_message.typingAttributes = [
            .font: UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15),
            .foregroundColor: UIColor.black
        ]

        // ANALYTICS
        AnalyticsLoggerManager.logEvent(name: Message_view_detail)

        // CHARGEMENT DES DONNÉES (classique vs smalltalk)
        if isSmallTalkMode {
            fetchSmallTalkData()
        } else {
            getMessages()
            getDetailConversation()
        }
        ui_btn_camera.addTarget(self, action: #selector(didTapCameraButton), for: .touchUpInside)
    }
    
    @objc private func handleCharteTapped() {
        let vc = GoodPracticesViewController()
        vc.modalPresentationStyle = .fullScreen
        self.present(vc, animated: true, completion: nil)
    }

    
    @objc private func handleEventViewTap() {
        EventService.getEventWithId(self.currentConversation?.uuid ?? "") { event, error in
            if let navVc = UIStoryboard.init(name: StoryboardName.event, bundle: nil).instantiateViewController(withIdentifier: "eventDetailNav") as? UINavigationController,
               let vc = navVc.topViewController as? EventDetailFeedViewController {
                
                vc.eventId = event?.uid ?? 0
                vc.event = event
                vc.modalPresentationStyle = .fullScreen

                if let presentedVC = UIApplication.shared.keyWindow?.rootViewController?.presentedViewController,
                   presentedVC is UINavigationController {
                    // Si l'écran événement est déjà affiché, on le remet au premier plan
                    presentedVC.dismiss(animated: false) {
                        UIApplication.shared.keyWindow?.rootViewController?.present(navVc, animated: true)
                    }
                    return
                }

                self.present(navVc, animated: true, completion: nil)
            }
        }
        
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isStartEditing {
            isStartEditing = false
            _ = ui_textview_message.becomeFirstResponder()
        }
        
        startAutoRefresh()

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopAutoRefresh()             // 🆕
    }
        
    deinit {
        stopAutoRefresh()             // 🆕 sécurise en cas de fuite
        NotificationCenter.default.removeObserver(self)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // S'assure que la table des mentions est bien devant
        self.view.bringSubviewToFront(ui_tableview_mentions)
    }

    private func startAutoRefresh() {
        stopAutoRefresh()
        autoRefreshTimer = Timer.scheduledTimer(withTimeInterval: autoRefreshInterval,
                                                repeats: true) { [weak self] _ in
            self?.autoRefreshMessages()
        }
    }
    
    private func autoRefreshMessages() {                    // 🆕
        guard !isLoading, !isSmallTalkMode else { return }
        
        // 1. Mémorise la position avant reload
        let wasAtBottom            = isTableViewAtBottom()
        let previousContentHeight  = ui_tableview.contentSize.height
        let previousOffset         = ui_tableview.contentOffset
        
        // 2. Recharge la page 1 (les derniers messages)
        currentPage = 1
        isSilentRefresh = true          // 🆕  désactive le scroll auto

        getMessages()
        
        // 3. Après le reload (quasi-immédiat côté UI), on rétablit l’offset si besoin
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            if !wasAtBottom {
                let newContentHeight = self.ui_tableview.contentSize.height
                let delta            = newContentHeight - previousContentHeight
                let newOffset        = CGPoint(x: previousOffset.x,
                                               y: previousOffset.y + delta)
                self.ui_tableview.setContentOffset(newOffset, animated: false)
            }
        }
    }


    private func stopAutoRefresh() {
        autoRefreshTimer?.invalidate()
        autoRefreshTimer = nil
    }
    
    private func isTableViewAtBottom() -> Bool {      // 🆕
        let contentHeight = ui_tableview.contentSize.height
        let tableHeight   = ui_tableview.bounds.height
        let offsetY       = ui_tableview.contentOffset.y
        return offsetY >= contentHeight - tableHeight - 1
    }
    
    func generateJitsiURL(displayName: String, roomName: String = "Bonnes ondes ") -> URL? {
        let uniqueRoomName = roomName + self.uuidv2
        let baseURL = "https://meet.jit.si/\(uniqueRoomName)"
        let encodedName = displayName.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "Invité"
        let fragment = "#userInfo.displayName=%22\(encodedName)%22&config.startWithAudioMuted=false&config.startWithVideoMuted=false"
        let fullURLString = baseURL + fragment
        return URL(string: fullURLString)
    }
    
    
    @objc private func didTapCameraButton() {
        AnalyticsLoggerManager.logEvent(name: Action_SmallTalk_Visio_Icon)
        if let url = URL(string: self.meetUrl), !self.meetUrl.isEmpty {
            WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
        } else {
            print("❌ URL invalide ou vide :", self.meetUrl)
        }
    }
    
    private func generateSmallTalkTitle(from members: [UserProfile]) -> String {
        let currentUserId = UserDefaults.currentUser?.sid ?? 0
        let others = members
            .filter { $0.id != currentUserId }
            .prefix(5)
            .map { $0.display_name }

        return others.joined(separator: ", ")
    }
    
    
    func setupFromSmallTalk(smallTalkId: Int, title: String?, delegate: UpdateUnreadCountDelegate? = nil) {
        self.isSmallTalkMode = true
        self.smallTalkId = String(smallTalkId)
        self.currentMessageTitle = title
        self.parentDelegate = delegate
    }
    private func fetchSmallTalkData() {
        DispatchQueue.main.async {
            IHProgressHUD.show()
        }

        SmallTalkService.getSmallTalk(id: smallTalkId) { smallTalk, error in
            
            guard let smallTalk = smallTalk else {
                DispatchQueue.main.async {
                    IHProgressHUD.dismiss()
                }
                return
            }
            self.meetUrl = smallTalk.meeting_url ?? ""
            self.uuidv2 = smallTalk.uuid_v2

            DispatchQueue.main.async {
                let displayTitle = self.generateSmallTalkTitle(from: smallTalk.members)
                self.currentMessageTitle = displayTitle // si tu veux le stocker
                self.ui_top_view.populateCustom(
                    title: displayTitle,
                    titleFont: ApplicationTheme.getFontQuickSandBold(size: 15),
                    titleColor: .black,
                    imageName: nil,
                    backgroundColor: .appBeigeClair,
                    delegate: self,
                    showSeparator: true,
                    cornerRadius: nil,
                    isClose: false,
                    marginLeftButton: nil
                )
                if self.meetUrl == "" {
                    self.ui_btn_camera.isHidden = true
                }else{
                    self.ui_btn_camera.isHidden = false
                }
                self.currentConversation = Conversation(from: smallTalk)
                self.currentUserId = UserDefaults.currentUser?.sid ?? 0
                self.isOneToOne = false
                self.updateInputInfos()
            }

            SmallTalkService.listMessages(id: self.smallTalkId) { messages, error in
                DispatchQueue.main.async {
                    IHProgressHUD.dismiss()
                    guard let messages = messages else { return }
                    self.messages = messages
                    self.buildConversationCellDTOs()
                    self.ui_view_empty.isHidden = !self.conversationCellDTOs.isEmpty
                    self.ui_tableview.reloadData()
                    self.scrollToBottomIfNeeded()
                }
            }
        }
    }


    private func scrollToBottomIfNeeded() {
        if !conversationCellDTOs.isEmpty {
            DispatchQueue.main.async {
                let lastIndex = self.conversationCellDTOs.count - 1
                let indexPath = IndexPath(row: lastIndex, section: 0)
                self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: false)
            }
        }
    }

    //MARK: - Setup & Navigation
    func setupFromOtherVC(
        conversationId: Int,
        title: String?,
        isOneToOne: Bool,
        conversation: Conversation? = nil,
        delegate: UpdateUnreadCountDelegate? = nil,
        selectedIndexPath: IndexPath? = nil
    ) {
        self.parentDelegate = delegate
        self.selectedIndexPath = selectedIndexPath
        self.conversationId = conversationId
        self.currentMessageTitle = title
        self.isOneToOne = isOneToOne
        self.hasToShowFirstMessage = conversation?.hasToShowFirstMessage() ?? true
        self.currentUserId = conversation?.user?.uid ?? 0
    }

    func setupFromOtherVCWithHash(
        conversationId: String,
        title: String?,
        isOneToOne: Bool,
        conversation: Conversation? = nil,
        delegate: UpdateUnreadCountDelegate? = nil,
        selectedIndexPath: IndexPath? = nil
    ) {
        self.parentDelegate = delegate
        self.selectedIndexPath = selectedIndexPath
        self.hashedConversationId = conversationId
        self.currentMessageTitle = title
        self.isOneToOne = isOneToOne
        self.hasToShowFirstMessage = conversation?.hasToShowFirstMessage() ?? true
        self.currentUserId = conversation?.user?.uid ?? 0
    }

    @objc func closeFromParams() {
        self.paramVC?.dismiss(animated: false)
        self.goBack()
    }

    @objc func userBlockedFromParams() {
        self.paramVC?.dismiss(animated: false)
        self.getDetailConversation()
    }

    // MARK: - View New Conversation
    func checkNewConv() {
        if !isOneToOne { return }
        for message in self.messages {
            if let _user = message.user,
               let _role = _user.roles {
                if _role.contains("Équipe Entourage") {
                    hasToShowFirstMessage = false
                }
            }
        }
        if hasToShowFirstMessage {
            showViewNew()
        }
    }

    func showViewNew() {
        if self.currentConversation?.type != "outing" || !isSmallTalkMode {
            self.ui_constraint_tableview_top_top.priority = .defaultLow
            self.ui_constraint_tableview_top_margin.priority = .required
            self.ui_constraint_tableview_top_margin.constant = ui_view_new_conversation.frame.height
            UIView.animate(withDuration: 0.3) {
                self.view.layoutIfNeeded()
            }
        }
    }

    func hideViewNew() {
        self.ui_constraint_tableview_top_top.priority = .defaultLow
        self.ui_constraint_tableview_top_margin.priority = .required
        self.ui_constraint_tableview_top_margin.constant = 0
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
    }

    // MARK: - Keyboard Notif
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else { return }
        self.ui_constraint_bottom_view_Tf.constant = keyboardSize.height
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        // Masquer la vue vide
        if conversationCellDTOs.isEmpty {
            ui_view_empty.isHidden = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        ui_constraint_bottom_view_Tf.constant = bottomConstraint
        if conversationCellDTOs.isEmpty {
            ui_view_empty.isHidden = false
        }
    }

    // MARK: - Network – chargement des messages
    func getMessages() {

        // 0. Mode SmallTalk ? → on ne charge rien
        if isSmallTalkMode { return }

        // 1. Déjà en cours ? → on sort
        if isLoading { return }

        // 2. Première ouverture ? → on vide visuellement pour éviter le flash
        if conversationCellDTOs.isEmpty {
            ui_tableview.reloadData()
        }

        // 3. HUD uniquement si ce n’est PAS un refresh silencieux
        if !isSilentRefresh {
            IHProgressHUD.show()
        }

        // 4. Identifiant de la conversation (id ou hash)
        let convIdStr: String = {
            if conversationId != 0        { return String(conversationId) }
            if !hashedConversationId.isEmpty { return hashedConversationId }
            return ""
        }()

        isLoading = true

        // 5. Appel réseau
        MessagingService.getMessagesFor(
            conversationId: convIdStr,
            currentPage: currentPage,
            per: numberOfItemsForWS
        ) { [weak self] messages, error in
            guard let self = self else { return }

            //------------------------------------------------------------
            // 6. Always : HUD OFF & états réinitialisés
            //------------------------------------------------------------
            if !self.isSilentRefresh      { IHProgressHUD.dismiss() }
            defer {
                self.isSilentRefresh = false          // réactive le scroll pour les appels normaux
                self.setLoadingFalse()                // libère le verrou isLoading (timer 1 s)
            }

            //------------------------------------------------------------
            // 7. Erreur ? On quitte proprement
            //------------------------------------------------------------
            guard let messages = messages else { return }

            //------------------------------------------------------------
            // 8. Mise à jour des sources
            //------------------------------------------------------------
            if self.currentPage > 1 {
                self.messages.append(contentsOf: messages)
            } else {
                self.messages = messages
            }

            //------------------------------------------------------------
            // 9. Vue « nouvelle conversation », DTOs, reload
            //------------------------------------------------------------
            self.checkNewConv()
            self.buildConversationCellDTOs()
            self.ui_view_empty.isHidden = !self.conversationCellDTOs.isEmpty
            self.ui_tableview.reloadData()

            //------------------------------------------------------------
            // 10. Scroll AUTO uniquement si ce n’est PAS un silent refresh
            //------------------------------------------------------------
            if self.currentPage == 1,
               !self.conversationCellDTOs.isEmpty,
               !self.isSilentRefresh {

                DispatchQueue.main.async {
                    let lastRow = self.conversationCellDTOs.count - 1
                    let ip      = IndexPath(row: lastRow, section: 0)
                    self.ui_tableview.scrollToRow(at: ip, at: .bottom, animated: false)
                }
            }

            //------------------------------------------------------------
            // 11. Badge « non lus » sur l’écran précédent
            //------------------------------------------------------------
            self.parentDelegate?.updateUnreadCount(
                conversationId: self.conversationId,
                currentIndexPathSelected: self.selectedIndexPath
            )
        }
    }


    func getDetailConversation() {
        var _convId = ""
        if self.conversationId != 0 {
            _convId = String(conversationId)
        } else if hashedConversationId != "" {
            _convId = hashedConversationId
        }
        MessagingService.getDetailConversation(conversationId: _convId) { conversation, error in
            if let conversation = conversation {
                // Mise à jour du titre si oneToOne
                if self.isOneToOne {
                    if conversation.members_count ?? 0 > 2 {
                        self.isOneToOne = false
                    }
                    self.currentMessageTitle = conversation.members?
                        .first(where: { $0.uid != self.meId })?
                        .username
                    print("eho name " , conversation.members_count)
                    if let members = conversation.members, members.count > 2 {
                        let displayNames = members
                            .filter { $0.uid != self.meId }
                            .prefix(5)
                            .compactMap { $0.username }
                            .map { name -> String in
                                let endIndex = name.index(name.endIndex, offsetBy: -2, limitedBy: name.startIndex) ?? name.startIndex
                                return String(name[..<endIndex]).trimmingCharacters(in: .whitespaces)
                            }
                        self.currentMessageTitle = displayNames.joined(separator: ", ")
                    }
                    let _title = self.currentMessageTitle ?? "messaging_message_title".localized
                    self.ui_top_view.setTitlesOneLine()
                    self.ui_top_view.updateTitle(title: _title)
                }
                
                self.currentConversation = conversation

                // Si on a le type “outing”, on cherche le titre exact de l’événement
                if self.type == "outing" {
                    self.ui_view_empty.isHidden = true
                    EventService.getEventWithId(self.currentConversation?.uuid ?? "") { event, error in
                        let _title = event?.title ?? "messaging_message_title".localized
                        self.ui_top_view.populateView(
                            title: _title,
                            titleFont: ApplicationTheme.getFontQuickSandBold(size: 15),
                            titleColor: .black,
                            delegate: self,
                            backgroundColor: .appBeigeClair,
                            isClose: false,
                            doubleRightMargin: true,
                            event: event
                        )
                    }
                } else {
                    let _title = self.currentMessageTitle ?? "messaging_message_title".localized
                    self.ui_top_view.populateView(
                        title: _title,
                        titleFont: ApplicationTheme.getFontQuickSandBold(size: 15),
                        titleColor: .black,
                        delegate: self,
                        backgroundColor: .appBeigeClair,
                        isClose: false,
                        doubleRightMargin: true
                    )
                }
                self.updateInputInfos()
            }
        }
    }

    /// Gère l’affichage ou non du bloc de blocage
    func updateInputInfos() {
        guard !isSmallTalkMode else {
            ui_view_block.isHidden = true
            return
        }
        if currentConversation?.hasBlocker() ?? false {
            ui_view_block.isHidden = false
        } else {
            ui_view_block.isHidden = true
        }
        let _name = currentMessageTitle ?? ""
        if currentConversation?.imBlocker() ?? false {
            ui_title_block.text = String(format: "message_user_blocked_by_me".localized, _name)
        } else {
            ui_title_block.text = String(format: "message_user_blocked_by_other".localized, _name)
        }
    }

    /// Reconstitue le tableau `conversationCellDTOs` à partir de `messages` et `messagesForRetry`.
    private func buildConversationCellDTOs() {
        // 1) On trie d’abord les messages "normaux" pour les regrouper par date
        let newMessagessSorted = PostMessage.getArrayOfDateSorted(messages: messages, isAscendant: true)
        var newDTOs: [ConversationCellDTO] = []

        for (k, v) in newMessagessSorted {
            // k: date + dateString
            newDTOs.append(.dateString(title: k.dateString))
            for msg in v {
                newDTOs.append(.message(message: msg))
            }
        }

        // 2) On ajoute les messages en “retry”
        for (idx, retryMsg) in messagesForRetry.enumerated() {
            newDTOs.append(.retryMessage(message: retryMsg, positionRetry: idx))
        }

        // 3) On affecte le tableau final
        self.conversationCellDTOs = newDTOs
    }

    private func setLoadingFalse() {
        let timer = Timer(
            fireAt: Date().addingTimeInterval(1),
            interval: 0,
            target: self,
            selector: #selector(self.loadingAtFalse),
            userInfo: nil,
            repeats: false
        )
        RunLoop.current.add(timer, forMode: .common)
    }

    @objc private func loadingAtFalse() {
        self.isLoading = false
    }
    
    private func handleMessageSent(message: PostMessage?, error: EntourageNetworkError?, isRetry: Bool, messageStr: String, positionForRetry: Int) {
        self.isLoading = false

        DispatchQueue.main.async {
            if let _ = message {
                if isRetry {
                    self.messagesForRetry.remove(at: positionForRetry)
                }
                self.currentPage = 1
                if self.isSmallTalkMode {
                    self.fetchSmallTalkData()
                } else {
                    self.getMessages()
                }
            } else if !isRetry {
                var postMsg = PostMessage()
                postMsg.content = messageStr
                postMsg.user = UserLightNeighborhood()
                postMsg.isRetryMsg = true
                self.messagesForRetry.append(postMsg)
                self.isStartEditing = false
                self.ui_view_empty.isHidden = true
                self.buildConversationCellDTOs()
                self.ui_tableview.reloadData()
                self.scrollToBottomIfNeeded()
                self.setLoadingFalse()
            }

            self.ui_iv_bt_send.isUserInteractionEnabled = false
            IHProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.ui_iv_bt_send.isUserInteractionEnabled = true
                IHProgressHUD.dismiss()
            }
        }
    }



    // MARK: - Envoi d'un message
    func sendMessage(messageStr: String, isRetry: Bool, positionForRetry: Int = 0) {
        DispatchQueue.main.async {
            self.ui_textview_message.text = nil
            self.ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")
        }

        if self.isLoading { return }
        self.isLoading = true

        if isSmallTalkMode {
            SmallTalkService.createMessage(id: smallTalkId, content: messageStr) { message, error in
                self.handleMessageSent(
                    message: message,
                    error: error,
                    isRetry: isRetry,
                    messageStr: messageStr,
                    positionForRetry: positionForRetry
                )
            }
        } else {
            MessagingService.postCommentFor(conversationId: self.conversationId, message: messageStr) { message, error in
                self.handleMessageSent(
                    message: message,
                    error: error,
                    isRetry: isRetry,
                    messageStr: messageStr,
                    positionForRetry: positionForRetry
                )
            }
        }
    }



    // MARK: - Actions
    @IBAction func action_tap_view(_ sender: Any) {
        _ = ui_textview_message.resignFirstResponder()
        hideMentionSuggestions()
    }

    @IBAction func action_send_message(_ sender: Any) {
        self.closeKb(nil)
    }

    @IBAction func action_show_params(_ sender: Any) {
        if let navvc = storyboard?.instantiateViewController(withIdentifier: "params_nav") as? UINavigationController,
           let vc = navvc.topViewController as? ConversationParametersViewController {
            AnalyticsLoggerManager.logEvent(name: Message_action_param)
            vc.modalPresentationStyle = .fullScreen
            vc.userId = currentUserId
            vc.isSmallTalkMode = self.isSmallTalkMode
            vc.smallTalkId = self.smallTalkId
            if currentConversation?.type == "outing"{
                vc.isEvent = true
            }else{
                vc.isEvent = false
            }
            vc.conversationId = conversationId
            vc.isOneToOne = isOneToOne
            if let _members = self.currentConversation?.members {
                if _members.count > 2 {
                    vc.isSeveral = true
                }
            }
            vc.username = currentMessageTitle ?? "-"
            vc.imBlocker = currentConversation?.imBlocker() ?? false
            self.paramVC = vc
            self.present(navvc, animated: true, completion: nil)
            return
        }
    }

    @IBAction func action_show_user(_ sender: Any) {
        if isOneToOne{
            showUser(userId: currentUserId)
        }else{
            if let vc = storyboard?.instantiateViewController(withIdentifier: "list_membersVC") as? ConversationListMembersViewController {
                vc.conversationId = self.currentConversation?.uid
                vc.modalPresentationStyle = .overCurrentContext
                self.present(vc, animated: true)
            }
        }
    }

    @IBAction func action_close_new_view(_ sender: Any) {
        self.hideViewNew()
    }

    // MARK: - Méthodes pour la fonctionnalité de mention
    /// Met à jour la liste de suggestions en fonction du query (après un "@...").
    func updateMentionSuggestions(query: String) {
        guard let members = currentConversation?.members, !members.isEmpty else {
            hideMentionSuggestions()
            return
        }
        
        let q = query.lowercased()
        
        // Filtre : on exclut l’utilisateur courant
        let filtered: [MemberLight]
        if q.isEmpty {
            // Si query est vide, on affiche 3 membres (hors moi) par défaut
            filtered = members.filter { $0.uid != meId }
        } else {
            filtered = members.filter {
                let nameLC = $0.username?.lowercased() ?? ""
                return nameLC.contains(q) && $0.uid != meId
            }
        }
        
        // Limitation à 3 suggestions
        let limited = Array(filtered.prefix(3))
        
        if limited.isEmpty {
            hideMentionSuggestions()
            return
        }
        
        // On convertit en MentionCellDTO
        mentionCellDTOs = limited.map { member in
            var user = UserLightNeighborhood()
            user.sid = member.uid
            user.displayName = member.username ?? ""
            user.avatarURL = member.imageUrl
            return .mention(user)
        }
        
        // Ajustement de la contrainte d'affichage en hauteur
        UIView.animate(withDuration: 0.2) {
            self.table_view_mention_height.constant = self.mentionCellHeight * CGFloat(self.mentionCellDTOs.count)
            self.view.layoutIfNeeded()
        }
        
        ui_tableview_mentions.reloadData()
        animateShowTableViewMentions()
    }

    /// Affiche la tableView des mentions avec animation
    private func animateShowTableViewMentions() {
        ui_tableview_mentions.transform = CGAffineTransform(translationX: 0, y: 20)
        ui_tableview_mentions.alpha = 0
        ui_tableview_mentions.isHidden = false
        
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseOut,
            animations: {
                self.ui_tableview_mentions.transform = .identity
                self.ui_tableview_mentions.alpha = 1
            },
            completion: nil
        )
    }

    func hideMentionSuggestions() {
        mentionCellDTOs.removeAll()
        ui_tableview_mentions.reloadData()
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            // On ramène la hauteur à 0
            self.table_view_mention_height.constant = 0
            // On déplace et fait disparaître la tableview
            self.ui_tableview_mentions.transform = CGAffineTransform(translationX: 0, y: 20)
            self.ui_tableview_mentions.alpha = 0
            
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.ui_tableview_mentions.isHidden = true
            // Réinitialiser la transformation pour la prochaine apparition
            self.ui_tableview_mentions.transform = .identity
        })
    }

    /// Insère la mention dans le TextView, sous forme d’un NSAttributedString cliquable
    func insertMention(user: UserLightNeighborhood) {
        let currentAttributedText: NSMutableAttributedString
        if let attributed = ui_textview_message.attributedText, attributed.length > 0 {
            currentAttributedText = NSMutableAttributedString(attributedString: attributed)
        } else {
            currentAttributedText = NSMutableAttributedString(string: ui_textview_message.text ?? "")
        }

        let cursorLocation = ui_textview_message.selectedRange.location
        let fullTextNSString = currentAttributedText.string as NSString
        let searchRange = NSRange(location: 0, length: cursorLocation)
        let atRange = fullTextNSString.range(of: "@", options: .backwards, range: searchRange)
        if atRange.location != NSNotFound {
            let replaceRange = NSRange(location: atRange.location, length: cursorLocation - atRange.location)
            let baseUrl: String
            if NetworkManager.sharedInstance.getBaseUrl().contains("preprod") {
                baseUrl = "https://preprod.entourage.social/app/"
            } else {
                baseUrl = "https://www.entourage.social/app/"
            }
            let linkURLString = baseUrl + "users/\(user.sid)"
            guard let linkURL = URL(string: linkURLString) else { return }
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .link: linkURL,
                .foregroundColor: UIColor.blue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let cleanedDisplayName = user.displayName.cleanedForMention()

            let mentionAttributedString = NSAttributedString(
                string: "@\(cleanedDisplayName)",
                attributes: linkAttributes
            )
            currentAttributedText.replaceCharacters(in: replaceRange, with: mentionAttributedString)
            ui_textview_message.attributedText = currentAttributedText

            let newCursorPosition = atRange.location + mentionAttributedString.length
            ui_textview_message.selectedRange = NSRange(location: newCursorPosition, length: 0)
        }
        hideMentionSuggestions()

        // Remet la police de base
        let style = ApplicationTheme.getFontCourantRegularNoir()
        ui_textview_message.typingAttributes = [
            .font: style.font,
            .foregroundColor: style.color
        ]
    }

    // MARK: - Conversion en HTML
    /// Convertit l'attributedText du UITextView en une chaîne HTML et en extrait le contenu du <body>.
    func getHTMLMessage() -> String? {
        guard let attributedText = ui_textview_message.attributedText else { return nil }
        do {
            let htmlData = try attributedText.data(
                from: NSRange(location: 0, length: attributedText.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
            )
            if var htmlString = String(data: htmlData, encoding: .utf8) {
                // Extraction du contenu entre <body> et </body>
                if let bodyStartRange = htmlString.range(of: "<body>"),
                   let bodyEndRange = htmlString.range(of: "</body>") {
                    htmlString = String(htmlString[bodyStartRange.upperBound..<bodyEndRange.lowerBound])
                }
                return htmlString.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Erreur lors de la conversion en HTML: \(error)")
        }
        return nil
    }

    // MARK: - Tools
    @objc func closeKb(_ sender: UIBarButtonItem?) {
        // 1) On récupère le HTML de l'attributedText
        if let htmlMessage = getHTMLMessage(),
           !htmlMessage.isEmpty,
           htmlMessage != placeholderTxt {
           
            // 2) On envoie ce HTML plutôt que textView.text
            self.sendMessage(messageStr: htmlMessage, isRetry: false)
        }
        _ = ui_textview_message.resignFirstResponder()
        hideMentionSuggestions()
        
        // Réinitialisation complète du UITextView (placeholder, style, etc.)
        ui_textview_message.text = placeholderTxt
        ui_textview_message.attributedText = NSAttributedString(string: placeholderTxt)
        let styleReset = ApplicationTheme.getFontRegular13Orange()  // Style initial
        ui_textview_message.typingAttributes = [
            .font: styleReset.font,
            .foregroundColor: styleReset.color
        ]
        ui_textview_message.textColor = UIColor.appOrange
    }
}

// MARK: - TableView DataSource & Delegate
extension ConversationDetailMessagesViewController: UITableViewDataSource, UITableViewDelegate {

    //---- TABLE DE MENTIONS ou TABLE DE MESSAGES ? ----
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ui_tableview_mentions {
            // TableView des mentions
            return mentionCellDTOs.count
        } else {
            // TableView principale (messages)
            return conversationCellDTOs.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // == TableView des mentions ==
        if tableView == ui_tableview_mentions {
            let dto = mentionCellDTOs[indexPath.row]
            switch dto {
            case .mention(let user):
                if let cell = ui_tableview_mentions.dequeueReusableCell(withIdentifier: MentionCell.identifier) as? MentionCell {
                    cell.selectionStyle = .none
                    cell.configure(igm: user.avatarURL ?? "placeholder_user", name: user.displayName)
                    return cell
                }
            }
            return UITableViewCell()
        }

        // == TableView principal (messages) ==
        let dto = conversationCellDTOs[indexPath.row]
        switch dto {
        case .dateString(let txt):
            // Cellule “Date”
            if let cell = tableView.dequeueReusableCell(
                withIdentifier: EventListSectionCell.identifier
            ) as? EventListSectionCell {
                cell.populateMessageSectionCell(title: txt)
                return cell
            }
            return UITableViewCell()

        case .message(let message):
            // Cellule “Message standard”
            let isMe = (message.user?.sid == self.meId)
            let cellId = isMe ? "cellMe" : "cellOther"
            if let cell = tableView.dequeueReusableCell(withIdentifier: cellId) as? NeighborhoodMessageCell {
                cell.populateCellConversation(
                    isMe: isMe,
                    message: message,
                    isRetry: false,
                    isOne2One: self.isOneToOne,
                    delegate: self
                )
                return cell
            }
            return UITableViewCell()

        case .retryMessage(let message, let positionRetry):
            // Cellule “Message en retry”
            // Toujours isMe = true car c’est nous qui avons échoué l’envoi
            if let cell = tableView.dequeueReusableCell(withIdentifier: "cellMe") as? NeighborhoodMessageCell {
                cell.populateCell(
                    isMe: true,
                    message: message,
                    isRetry: true,
                    positionRetry: positionRetry,
                    delegate: self,
                    isTranslated: false
                )
                return cell
            }
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == ui_tableview_mentions {
            let dto = mentionCellDTOs[indexPath.row]
            switch dto {
            case .mention(let selectedUser):
                // Animation sur la cellule
                if let cell = tableView.cellForRow(at: indexPath) as? MentionCell {
                    UIView.animate(withDuration: 0.2, animations: {
                        cell.contentView.backgroundColor = UIColor.appBeige
                    }, completion: { _ in
                        // On insère la mention
                        self.insertMention(user: selectedUser)
                        // Optionnel: réinitialiser la couleur
                        UIView.animate(withDuration: 0.2) {
                            cell.contentView.backgroundColor = UIColor.appBeigeClair2
                        }
                        tableView.deselectRow(at: indexPath, animated: true)
                    })
                }
            }
        }
    }

    // Pagination
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        if tableView == ui_tableview_mentions { return }

        // On relance un getMessages si on atteint le nbOfItemsBeforePagingReload
        if indexPath.row == nbOfItemsBeforePagingReload && messages.count >= numberOfItemsForWS * currentPage {
            self.currentPage += 1
            self.getMessages()
        }
    }
}

// MARK: - MJNavBackViewDelegate
extension ConversationDetailMessagesViewController: MJNavBackViewDelegate {
    func didTapEvent() {
        if type == "outing" {
            handleEventViewTap()
        } else {
            if let vc = storyboard?.instantiateViewController(withIdentifier: "list_membersVC") as? ConversationListMembersViewController {
                vc.conversationId = self.currentConversation?.uid
                vc.modalPresentationStyle = .currentContext
                self.present(vc, animated: true)
            }
        }
    }
    
    func goBack() {
        print("eho")
        if isFromMatching {
            isFromMatching = false
            AppState.navigateToMainApp()
        }else{
            self.parentDelegate?.updateUnreadCount(
                conversationId: conversationId,
                currentIndexPathSelected: selectedIndexPath
            )
            if self.navigationController?.viewControllers.count ?? 0 > 1 {
                self.navigationController?.popViewController(animated: true)
            } else {
                self.dismiss(animated: true)
            }
        }
    }
}

// MARK: - UITextViewDelegate
extension ConversationDetailMessagesViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        // Gestion de l’icône "envoyer"
        if textView.text.count == 0 && text.count == 1 {
            ui_iv_bt_send.image = UIImage(named: "ic_send_comment")
        }
        else if textView.text.count == 1 && text.count == 0 {
            ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")
        }
        else if textView.text.count > 0 {
            ui_iv_bt_send.image = UIImage(named: "ic_send_comment")
        }
        else {
            ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")
        }
        return true
    }
    func textViewDidBeginEditing(_ textView: UITextView) {
        // Si on arrive depuis le placeholder orange, on l’efface
        if textView.textColor == .appOrange || textView.text == placeholderTxt {
            textView.text = ""
        }
        // Rétablit la couleur & la police de saisie par défaut
        let style = ApplicationTheme.getFontCourantRegularNoir()
        textView.typingAttributes = [
            .font: style.font,
            .foregroundColor: style.color
        ]
        textView.textColor = style.color
    }
    
    func textViewDidChange(_ textView: UITextView) {

           //------------------------------------------------------------
           // 0. Icône « envoyer » ON / OFF
           //------------------------------------------------------------
           if textView.text.isEmpty {
               ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")
           } else {
               ui_iv_bt_send.image = UIImage(named: "ic_send_comment")
           }

           //------------------------------------------------------------
           // 1. Détection du “@” et affichage des suggestions
           //------------------------------------------------------------
           let fullText = textView.text ?? ""
           let cursor   = textView.selectedRange.location

           // ► Slicing SAFE : ne dépasse jamais la longueur
           guard !fullText.isEmpty, cursor <= fullText.count else {
               hideMentionSuggestions()
               return
           }

           let textUpToCursor = String(fullText.prefix(cursor))

           if let atIndex = textUpToCursor.lastIndex(of: "@") {
               // Nouveau « @ » = au début OU précédé d’un espace
               let isNewAt = (atIndex == textUpToCursor.startIndex) ||
                             (textUpToCursor[textUpToCursor.index(before: atIndex)] == " ")

               if isNewAt {
                   let mentionSubstring = textUpToCursor[atIndex...]
                   if mentionSubstring.contains(" ") {
                       hideMentionSuggestions()
                   } else {
                       // ► On enlève le @ pour construire la query
                       let query = String(mentionSubstring.dropFirst())
                       updateMentionSuggestions(query: query)
                   }
               } else {
                   hideMentionSuggestions()
               }
           } else {
               hideMentionSuggestions()
           }

           //------------------------------------------------------------
           // 2. Nettoyage des attributs de lien si mention incomplète
           //------------------------------------------------------------
           let mutableAttrText = NSMutableAttributedString(attributedString: textView.attributedText)
           let fullRange       = NSRange(location: 0, length: mutableAttrText.length)

           mutableAttrText.enumerateAttributes(in: fullRange, options: []) { attrs, range, _ in
               guard attrs[.link] != nil else { return }

               let mentionText = (mutableAttrText.string as NSString).substring(with: range)

               // Mention invalide → on retire le lien + souligné
               if mentionText.count < 2 || !mentionText.hasPrefix("@") {
                   mutableAttrText.removeAttribute(.link,            range: range)
                   mutableAttrText.removeAttribute(.underlineStyle,  range: range)
                   mutableAttrText.addAttribute(.foregroundColor, value: UIColor.black, range: range)
                   if let font = UIFont(name: "NunitoSans-Regular", size: 15) {
                       mutableAttrText.addAttribute(.font, value: font, range: range)
                   }
               }
           }

           textView.attributedText = mutableAttrText
       }


    // Intercepte le clic sur un lien dans le UITextView
    func textView(_ textView: UITextView,
                  shouldInteractWith URL: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        WebLinkManager.openUrl(url: URL, openInApp: true, presenterViewController: self)
        return false
    }
}

// MARK: - MessageCellSignalDelegate
extension ConversationDetailMessagesViewController: MessageCellSignalDelegate {
    func signalMessage(messageId: Int, userId: Int, textString: String) {
        if let navvc = UIStoryboard(name: StoryboardName.neighborhoodReport, bundle: nil)
            .instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController,
           let vc = navvc.topViewController as? ReportGroupMainViewController {
            vc.parentDelegate = self
            vc.messageId = messageId
            vc.signalType = .comment
            vc.userId = userId
            vc.messageId = messageId
            vc.conversationId = conversationId
            vc.textString = textString
            self.present(navvc, animated: true)
        }
    }

    func retrySend(message: String, positionForRetry: Int) {
        self.sendMessage(messageStr: message, isRetry: true, positionForRetry: positionForRetry)
    }

    func showUser(userId: Int?) {
        guard let userId = userId else {
            return
        }
        if let profileVC = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
            .instantiateViewController(withIdentifier: "profileFull") as? ProfilFullViewController {
            profileVC.userIdToDisplay = "\(userId)"
            profileVC.modalPresentationStyle = .fullScreen
            self.present(profileVC, animated: true)
        }
    }

    func showWebUrl(url: URL) {
        // Si c’est une URL Entourage, on ferme avant d’ouvrir
        if WebLinkManager.isOurPatternURL(url) {
            self.dismiss(animated: true) {
                WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
            }
        } else {
            WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
        }
    }
}

// MARK: - UpdateUnreadCountDelegate
protocol UpdateUnreadCountDelegate: AnyObject {
    func updateUnreadCount(conversationId: Int, currentIndexPathSelected: IndexPath?)
}

// MARK: - GroupDetailDelegate
extension ConversationDetailMessagesViewController: GroupDetailDelegate {
    func translateItem(id: Int) {
        // TODO: Gérer la traduction si nécessaire
    }

    func showMessage(signalType: GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(
            title: "OK".localized,
            titleStyle: ApplicationTheme.getFontCourantBoldOrange(),
            bgColor: .appOrange,
            cornerRadius: -1
        )
        let title = (signalType == .comment)
            ? "report_comment_title".localized
            : "report_publication_title".localized

        alertVC.configureAlert(
            alertTitle: title,
            message: "report_group_message_success".localized,
            buttonrightType: buttonCancel,
            buttonLeftType: nil,
            titleStyle: ApplicationTheme.getFontCourantBoldOrange(),
            messageStyle: ApplicationTheme.getFontCourantRegularNoir(),
            mainviewBGColor: .white,
            mainviewRadius: 35,
            isButtonCloseHidden: true
        )

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            alertVC.show()
        }
    }

    func publicationDeleted() {
        DispatchQueue.main.async {
            self.getMessages()
        }
    }
}

// MARK: - UIGestureRecognizerDelegate
extension ConversationDetailMessagesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Si on clique sur la tableView des mentions, on ne veut pas fermer la mentionView
        if let view = touch.view, view.isDescendant(of: ui_tableview_mentions) {
            return false
        }
        return true
    }
}

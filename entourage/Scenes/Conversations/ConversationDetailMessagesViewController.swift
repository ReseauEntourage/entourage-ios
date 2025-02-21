//
//  ConversationDetailMessagesViewController.swift
//  entourage
//
//  Created by Jerome on 23/08/2022.
//  Adapté pour intégrer la fonctionnalité de mention (liste de suggestions, insertion AttributedString, etc.)
//  Le filtrage des mentions se fait localement sur la liste de members de la Conversation.
//

import UIKit
import IQKeyboardManagerSwift
import IHProgressHUD

// Use to transform messages to section date with messages
struct MessagesSorted {
    var messages = [Any]()
    var datesSections = 0
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
    
    // MARK: - Outlets pour la fonctionnalité de mention
    @IBOutlet weak var ui_tableview_mentions: UITableView!            // TableView des suggestions
    @IBOutlet weak var table_view_mention_height: NSLayoutConstraint!
    
    // MARK: - Variables principales
    private var conversationId: Int = 0
    private var hashedConversationId: String = ""
    private var currentMessageTitle: String? = nil
    private var currentUserId: Int = 0
    private var hasToShowFirstMessage = false
    private var isOneToOne = true
    private var selectedIndexPath: IndexPath? = nil
    private weak var parentDelegate: UpdateUnreadCountDelegate? = nil

    var messages = [PostMessage]()
    var messagesExtracted = MessagesSorted()
    var meId: Int = 0
    var messagesForRetry = [PostMessage]()

    let placeholderTxt = "messaging_message_placeholder_discut".localized
    var bottomConstraint: CGFloat = 0
    var isStartEditing = false

    // MARK: - Pagination
    var currentPage = 1
    let numberOfItemsForWS = 50 // Arbitrary nb of items used for paging
    let nbOfItemsBeforePagingReload = 5 // Arbitrary nb of items from the top to send new call
    var isLoading = false

    var paramVC: UIViewController? = nil
    var currentConversation: Conversation? = nil

    // MARK: - Propriétés pour la fonctionnalité de mention
    /// Liste filtrée affichée dans le tableau des suggestions
    var mentionSuggestions: [UserLightNeighborhood] = []

    /// Hauteur d’une cellule “MentionCell” (à adapter selon ta maquette)
    private let mentionCellHeight: CGFloat = 44.0

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // -- Ajout important pour laisser les interactions sur la tableView des mentions --
        ui_tap_gesture.cancelsTouchesInView = false
        ui_tap_gesture.delegate = self

        IQKeyboardManager.shared.enable = false
        ui_bt_title_user.isHidden = !isOneToOne

        let _title = currentMessageTitle ?? "messaging_message_title".localized
        ui_top_view.populateView(
            title: _title,
            titleFont: ApplicationTheme.getFontQuickSandBold(size: 15),
            titleColor: .black,
            delegate: self,
            backgroundColor: .appBeigeClair,
            isClose: false,
            doubleRightMargin: true
        )

        // Vue vide
        ui_title_empty.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title_empty.text = "messaging_message_no_message".localized
        ui_view_empty.isHidden = true

        // Vue textView
        ui_view_txtview.layer.borderWidth = 1
        ui_view_txtview.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_txtview.layer.cornerRadius = ui_view_txtview.frame.height / 2

        // UITextView
        ui_textview_message.delegate = self
        ui_textview_message.hasToCenterTextVerticaly = true

        // Bouton envoyer
        ui_view_button_send.backgroundColor = .clear
        ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")

        // Vue blocage
        ui_view_block.layer.borderWidth = 1
        ui_view_block.layer.borderColor = UIColor.appGris112.cgColor
        ui_view_block.layer.cornerRadius = ui_view_block.frame.height / 2
        ui_title_block.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 14, color: .appGris112))
        ui_view_block.isHidden = true

        // Toolbar sur textView
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        let buttonDone = UIBarButtonItem(
            title: "messaging_message_send".localized,
            style: .plain,
            target: self,
            action: #selector(closeKb(_:))
        )
        ui_textview_message.addToolBar(width: _width, buttonValidate: buttonDone)
        ui_textview_message.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_textview_message.placeholderText = placeholderTxt
        ui_textview_message.placeholderColor = .appOrange

        // Récupération de l'utilisateur courant
        guard let me = UserDefaults.currentUser else {
            return goBack()
        }
        meId = me.sid

        // Charge les messages
        getMessages()

        // Observateurs clavier
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
        bottomConstraint = ui_constraint_bottom_view_Tf.constant

        // Vue "nouvelle conversation"
        ui_title_new_conv.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldOrange())
        ui_subtitle_new_conv.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_title_new_conv.text = "message_title_new_conv".localized
        ui_subtitle_new_conv.text = "message_subtitle_new_conv".localized
        hideViewNew()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(closeFromParams),
            name: NSNotification.Name(rawValue: kNotificationMessagesUpdate),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(userBlockedFromParams),
            name: NSNotification.Name(rawValue: kNotificationMessagesUpdateUserBlocked),
            object: nil
        )

        // Récupère détails conversation
        self.getDetailConversation()

        AnalyticsLoggerManager.logEvent(name: Message_view_detail)

        // Configuration de la tableView des mentions
        ui_tableview_mentions.delegate = self
        ui_tableview_mentions.dataSource = self
        ui_tableview_mentions.register(
            UINib(nibName: MentionCell.identifier, bundle: nil),
            forCellReuseIdentifier: MentionCell.identifier
        )
        ui_tableview_mentions.isHidden = true

        // On met la hauteur à 0 au départ
        table_view_mention_height.constant = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isStartEditing {
            isStartEditing = false
            _ = ui_textview_message.becomeFirstResponder()
        }
    }

    // -- Ajout pour s'assurer que la tableView des mentions passe bien devant la tableView principale
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        self.view.bringSubviewToFront(ui_tableview_mentions)
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
        self.hasToShowFirstMessage = conversation?.hasToShowFirstMessage() ?? false
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
        self.hasToShowFirstMessage = conversation?.hasToShowFirstMessage() ?? false
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
        self.ui_constraint_tableview_top_top.priority = .defaultLow
        self.ui_constraint_tableview_top_margin.priority = .required
        self.ui_constraint_tableview_top_margin.constant = ui_view_new_conversation.frame.height
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
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
        // Hide empty view to prevent weird layout
        if messagesExtracted.messages.count == 0 {
            ui_view_empty.isHidden = true
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        ui_constraint_bottom_view_Tf.constant = bottomConstraint
        if messagesExtracted.messages.count == 0 {
            ui_view_empty.isHidden = false
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Network
    func getMessages() {
        if self.isLoading { return }
        if self.messagesExtracted.messages.isEmpty {
            self.ui_tableview.reloadData()
        }

        IHProgressHUD.show()

        var _convId = ""
        if self.conversationId != 0 {
            _convId = String(conversationId)
        } else if hashedConversationId != "" {
            _convId = hashedConversationId
        }
        self.isLoading = true

        MessagingService.getMessagesFor(
            conversationId: _convId,
            currentPage: currentPage,
            per: numberOfItemsForWS
        ) { messages, error in
            IHProgressHUD.dismiss()
            if let messages = messages {
                if self.currentPage > 1 {
                    self.messages.append(contentsOf: messages)
                } else {
                    self.messages = messages
                }
                self.checkNewConv()
                self.extractDict()

                self.ui_view_empty.isHidden = self.messagesExtracted.messages.count > 0
                self.ui_tableview.reloadData()

                if self.currentPage == 1 && self.messagesExtracted.messages.count + self.messagesForRetry.count > 0 {
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(
                            row: self.messagesExtracted.messages.count + self.messagesForRetry.count - 1,
                            section: 0
                        )
                        self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: false)
                    }
                }
                self.parentDelegate?.updateUnreadCount(
                    conversationId: self.conversationId,
                    currentIndexPathSelected: self.selectedIndexPath
                )
            }
            self.setLoadingFalse()
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
                if self.isOneToOne {
                    // Mise à jour du titre
                    self.currentMessageTitle = conversation.members?
                        .first(where: { $0.uid != self.meId })?
                        .username
                    if conversation.members_count ?? 0 > 2 {
                        let count = (conversation.members_count ?? 1) - 1
                        self.currentMessageTitle = (self.currentMessageTitle ?? "") + " + " + String(count) + " membres"
                    }
                    let _title = self.currentMessageTitle ?? "messaging_message_title".localized
                    self.ui_top_view.setTitlesOneLine()
                    self.ui_top_view.updateTitle(title: _title)
                }
                self.currentConversation = conversation
                self.updateInputInfos()
            }
        }
    }

    func updateInputInfos() {
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

    /// Transforme la liste de messages bruts en sections de dates
    func extractDict() {
        let newMessagessSorted = PostMessage.getArrayOfDateSorted(messages: messages, isAscendant: true)
        var newMessages = [Any]()
        for (k,v) in newMessagessSorted {
            newMessages.append(k.dateString)
            for _msg in v {
                newMessages.append(_msg)
            }
        }
        let messagesSorted = MessagesSorted(messages: newMessages, datesSections: newMessagessSorted.count)
        self.messagesExtracted.messages.removeAll()
        self.messagesExtracted = messagesSorted
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

    // MARK: - Envoi d'un message
    func sendMessage(messageStr: String, isRetry: Bool, positionForRetry: Int = 0) {
        self.ui_textview_message.text = nil
        ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")

        if self.isLoading { return }
        self.isLoading = true

        MessagingService.postCommentFor(
            conversationId: self.conversationId,
            message: messageStr
        ) { message, error in
            self.isLoading = false

            if let _ = message {
                if isRetry {
                    self.messagesForRetry.remove(at: positionForRetry)
                }
                self.currentPage = 1
                self.getMessages()
            } else {
                // Échec => on stocke un message en retry
                if !isRetry {
                    var postMsg = PostMessage()
                    postMsg.content = messageStr
                    postMsg.user = UserLightNeighborhood()
                    postMsg.isRetryMsg = true
                    self.messagesForRetry.append(postMsg)

                    self.isStartEditing = false
                    self.ui_view_empty.isHidden = true
                    self.ui_tableview.reloadData()

                    if self.messagesExtracted.messages.count + self.messagesForRetry.count > 0 {
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(
                                row: self.messagesExtracted.messages.count + self.messagesForRetry.count - 1,
                                section: 0
                            )
                            self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                    }
                    self.setLoadingFalse()
                }
            }

            // Petit “loading”
            self.ui_iv_bt_send.isUserInteractionEnabled = false
            IHProgressHUD.show()
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.ui_iv_bt_send.isUserInteractionEnabled = true
                IHProgressHUD.dismiss()
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
        showUser(userId: currentUserId)
    }

    @IBAction func action_close_new_view(_ sender: Any) {
        self.hideViewNew()
    }

    // MARK: - Méthodes pour la fonctionnalité de mention (pas d'appel API, simple filtre local sur members)
    func updateMentionSuggestions(query: String) {
        // On filtre localement les members de la conversation
        guard let members = currentConversation?.members, !members.isEmpty else {
            hideMentionSuggestions()
            return
        }
        let q = query.lowercased()

        // Filtrage du displayName (username)
        var filtered = members.filter {
            let nameLC = $0.username?.lowercased() ?? ""
            return nameLC.contains(q) && $0.uid != meId
        }

        // On limite à 3
        filtered = Array(filtered.prefix(3))

        // S'il n'y a aucun résultat => on cache la table
        if filtered.isEmpty {
            hideMentionSuggestions()
            return
        }

        // On convertit ces MemberLight en "UserLightNeighborhood" (ou structure équivalente)
        mentionSuggestions = filtered.map { member -> UserLightNeighborhood in
            var user = UserLightNeighborhood()
            user.sid = member.uid
            user.displayName = member.username ?? ""
            user.avatarURL = member.imageUrl
            return user
        }

        // Ajuste la contrainte de hauteur
        UIView.animate(withDuration: 0.2) {
            self.table_view_mention_height.constant = self.mentionCellHeight * CGFloat(self.mentionSuggestions.count)
            self.view.layoutIfNeeded()
        }

        // Reload & animation d’apparition
        ui_tableview_mentions.reloadData()
        animateShowTableViewMentions()
    }

    func hideMentionSuggestions() {
        mentionSuggestions = []
        ui_tableview_mentions.reloadData()

        // Ramène la hauteur à 0
        UIView.animate(withDuration: 0.2) {
            self.table_view_mention_height.constant = 0
            self.view.layoutIfNeeded()
        }
        animateHideTableViewMentions()
    }

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
            let linkURLString = "https://myapp.entourage.social/app/users/\(user.sid)"
            guard let linkURL = URL(string: linkURLString) else { return }
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .link: linkURL,
                .foregroundColor: UIColor.blue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let mentionAttributedString = NSAttributedString(
                string: "@\(user.displayName)",
                attributes: linkAttributes
            )
            currentAttributedText.replaceCharacters(in: replaceRange, with: mentionAttributedString)
            ui_textview_message.attributedText = currentAttributedText
            let newCursorPosition = atRange.location + mentionAttributedString.length
            ui_textview_message.selectedRange = NSRange(location: newCursorPosition, length: 0)
        }
        hideMentionSuggestions()

        // On remet la police de base
        let style = ApplicationTheme.getFontCourantRegularNoir()
        ui_textview_message.typingAttributes = [
            .font: style.font,
            .foregroundColor: style.color
        ]
    }

    // MARK: - Animations tableView Mentions
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

    private func animateHideTableViewMentions() {
        UIView.animate(
            withDuration: 0.3,
            delay: 0,
            options: .curveEaseIn,
            animations: {
                self.ui_tableview_mentions.transform = CGAffineTransform(translationX: 0, y: 20)
                self.ui_tableview_mentions.alpha = 0
            },
            completion: { _ in
                self.ui_tableview_mentions.isHidden = true
            }
        )
    }

    // MARK: - Tools
    @objc func closeKb(_ sender: UIBarButtonItem?) {
        if let txt = ui_textview_message.text,
           txt != placeholderTxt,
           !txt.isEmpty {
            self.sendMessage(messageStr: txt, isRetry: false)
        }
        _ = ui_textview_message.resignFirstResponder()
        hideMentionSuggestions()
    }
}

// MARK: - TableView (Messages & Mentions)
extension ConversationDetailMessagesViewController: UITableViewDataSource, UITableViewDelegate {

    //---- TABLE PRINCIPALE (messages) ---
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ui_tableview_mentions {
            return mentionSuggestions.count
        }
        return messagesExtracted.messages.count + messagesForRetry.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // == TableView des mentions ==
        if tableView == ui_tableview_mentions {
            let user = mentionSuggestions[indexPath.row]
            if let cell = ui_tableview_mentions.dequeueReusableCell(withIdentifier: "MentionCell") as? MentionCell {
                cell.selectionStyle = .none
                cell.configure(igm: user.avatarURL ?? "placeholder_user", name: user.displayName)
                return cell
            }
        }

        // == TableView principal (messages)
        if messagesForRetry.count > 0 {
            if indexPath.row >= messagesExtracted.messages.count {
                let message = messagesForRetry[indexPath.row - messagesExtracted.messages.count]
                let cell = tableView.dequeueReusableCell(withIdentifier: "cellMe", for: indexPath) as! NeighborhoodMessageCell
                cell.populateCell(
                    isMe: true,
                    message: message,
                    isRetry: true,
                    positionRetry: indexPath.row - messagesExtracted.messages.count,
                    delegate: self,
                    isTranslated: false
                )
                return cell
            }
        }

        // Récupération d’un item dans messagesExtracted
        let messageExtracted = messagesExtracted.messages[indexPath.row]

        // Si c’est un String => c’est une "date" => cell de section
        if let txt = messageExtracted as? String {
            let cell = tableView.dequeueReusableCell(
                withIdentifier: EventListSectionCell.identifier,
                for: indexPath
            ) as! EventListSectionCell
            cell.populateMessageSectionCell(title: txt)
            return cell
        }

        // Sinon c’est un PostMessage
        let message = messageExtracted as! PostMessage
        var cellId = "cellOther"
        var isMe = false
        if message.user?.sid == self.meId {
            cellId = "cellMe"
            isMe = true
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NeighborhoodMessageCell
        cell.populateCellConversation(
            isMe: isMe,
            message: message,
            isRetry: false,
            isOne2One: self.isOneToOne,
            delegate: self
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == ui_tableview_mentions {
            let selectedUser = mentionSuggestions[indexPath.row]
            insertMention(user: selectedUser)
            tableView.deselectRow(at: indexPath, animated: true)
        }
    }

    // Pagination
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if isLoading { return }
        if tableView == ui_tableview_mentions { return }

        if indexPath.row == nbOfItemsBeforePagingReload
           && self.messages.count >= numberOfItemsForWS * currentPage {
            self.currentPage += 1
            self.getMessages()
        }
    }
}

// MARK: - MJNavBackViewDelegate
extension ConversationDetailMessagesViewController: MJNavBackViewDelegate {
    func goBack() {
        self.parentDelegate?.updateUnreadCount(conversationId: conversationId, currentIndexPathSelected: selectedIndexPath)
        self.dismiss(animated: true)
        self.navigationController?.dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension ConversationDetailMessagesViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
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

    func textViewDidChange(_ textView: UITextView) {
        let cursorPosition = textView.selectedRange.location
        let textNSString = textView.text as NSString
        let textUpToCursor = textNSString.substring(to: cursorPosition)

        // Recherche de la dernière occurrence de "@"
        if let atIndex = textUpToCursor.lastIndex(of: "@") {
            // Vérifie si c’est un nouvel @ (début ou précédé d’un espace)
            if atIndex == textUpToCursor.startIndex
               || textUpToCursor[textUpToCursor.index(before: atIndex)] == " " {
                let mentionSubstring = textUpToCursor[atIndex...]
                if mentionSubstring.contains(" ") {
                    hideMentionSuggestions()
                } else {
                    let query = String(mentionSubstring.dropFirst()) // retire le "@"
                    updateMentionSuggestions(query: query)
                }
            } else {
                hideMentionSuggestions()
            }
        } else {
            hideMentionSuggestions()
        }
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
        // Gère la logique d'ouverture (interne/externe)
        if WebLinkManager.isOurPatternURL(url) {
            self.dismiss(animated: true) {
                WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
            }
        } else {
            WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
        }
    }
}

// MARK: - UpdateUnreadCountDelegate (si besoin)
protocol UpdateUnreadCountDelegate: AnyObject {
    func updateUnreadCount(conversationId: Int, currentIndexPathSelected: IndexPath?)
}

// MARK: - GroupDetailDelegate (signalement)
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
        let title = signalType == .comment ? "report_comment_title".localized : "report_publication_title".localized

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
        // Si le toucher est sur la table view des suggestions, on ne ferme pas le clavier
        if let view = touch.view, view.isDescendant(of: ui_tableview_mentions) {
            return false
        }
        return true
    }
}

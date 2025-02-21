//
//  EventDetailMessagesViewController.swift
//  entourage
//
//  Created by Jerome on 28/07/2022.
//  Mise à jour pour intégrer la fonctionnalité de mention avec un appel API dynamique (query),
//  insertion d’un lien cliquable, conversion de l'attributedText en HTML pour l'envoi,
//  empêcher le UITapGestureRecognizer d'intercepter les touches sur la table view des suggestions,
//  réinitialiser correctement le UITextView après l'envoi (suppression du style URL),
//  et appliquer à nouveau une police de base après l'envoi (ex: getFontRegular13Orange()).
//  Désormais, on limite à 3 suggestions max et on affiche déjà des suggestions quand query est vide.
import UIKit
import IQKeyboardManagerSwift

class EventDetailMessagesViewController: UIViewController {

    // MARK: - IBOutlets existants
    @IBOutlet weak var ui_tableview: UITableView!
    @IBOutlet weak var ui_top_view: MJNavBackView!
    @IBOutlet weak var ui_view_txtview: UIView!
    @IBOutlet weak var ui_iv_bt_send: UIImageView!
    @IBOutlet weak var ui_view_button_send: UIView!
    @IBOutlet weak var ui_constraint_bottom_view_Tf: NSLayoutConstraint!
    @IBOutlet weak var ui_textview_message: MJTextViewPlaceholder!
    @IBOutlet weak var ui_title_not_auth: UILabel!
    @IBOutlet weak var ui_view_not_auth: UIView!
    @IBOutlet weak var ui_view_empty: UIView!
    @IBOutlet weak var ui_title_empty: UILabel!
    @IBOutlet var ui_tap_gesture: UITapGestureRecognizer!
    
    // MARK: - Nouvel outlet pour la liste de suggestions de mention
    @IBOutlet weak var ui_tableview_mentions: UITableView!
    @IBOutlet weak var table_view_mention_height: NSLayoutConstraint!
    
    // MARK: - Variables existantes
    var eventId: Int = 0
    var hashedEventId: String = ""
    var parentCommentId: Int = 0
    var hashedCommentId: String = ""
    var eventName = ""
    var isGroupMember = false
    var translatedMessageIDs = Set<Int>()
    
    var messages = [PostMessage]()
    var meId: Int = 0
    var messagesForRetry = [PostMessage]()
    
    let placeholderTxt = "event_comments_placeholder_discut".localized
    var bottomConstraint: CGFloat = 0
    var isStartEditing = false
    var selectedIndexPath: IndexPath? = nil
    weak var parentDelegate: UpdateCommentCountDelegate? = nil
    var postMessage: PostMessage? = nil
    
    // MARK: - Propriétés pour la fonctionnalité de mention
    /// Liste filtrée affichée dans le tableau des suggestions (obtenue via l’appel query)
    var mentionSuggestions: [UserLightNeighborhood] = []
    
    // Hauteur d’une cellule “MentionCell” (à adapter selon ta maquette)
    private let mentionCellHeight: CGFloat = 44.0
    
    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Pour que le tapGesture n’intercepte pas les touches destinées à d’autres vues
        ui_tap_gesture.cancelsTouchesInView = false
        ui_tap_gesture.delegate = self
        
        // Désactiver IQKeyboardManager sur cette vue
        IQKeyboardManager.shared.enable = false
        
        // Configuration de la barre de navigation
        ui_top_view.populateView(
            title: "event_comments_title".localized,
            titleFont: ApplicationTheme.getFontQuickSandBold(size: 15),
            titleColor: .black,
            delegate: self,
            backgroundColor: .appBeigeClair,
            isClose: false
        )
        
        // Configuration des labels et placeholders pour la vue vide / non-auth
        ui_title_empty.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title_empty.text = "event_no_messageComment".localized
        ui_view_empty.isHidden = true
        
        ui_title_not_auth.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        ui_title_not_auth.text = String(format: "event_messageComment_notAuth".localized, eventName)
        ui_view_not_auth.isHidden = isGroupMember
        
        // Mise en forme de la zone de saisie
        ui_view_txtview.layer.borderWidth = 1
        ui_view_txtview.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_txtview.layer.cornerRadius = ui_view_txtview.frame.height / 2
        
        // Configuration du UITextView
        ui_textview_message.delegate = self
        ui_textview_message.hasToCenterTextVerticaly = true
        ui_textview_message.placeholderText = placeholderTxt
        ui_textview_message.placeholderColor = .appOrange
        
        // Configuration du bouton envoyer
        ui_view_button_send.backgroundColor = .clear
        ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")
        
        // Ajout d’une toolbar (bouton Done) au UITextView
        let screenWidth = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        let buttonDone = UIBarButtonItem(
            title: "event_comments_send".localized,
            style: .plain,
            target: self,
            action: #selector(closeKb(_:))
        )
        ui_textview_message.addToolBar(width: screenWidth, buttonValidate: buttonDone)
        ui_textview_message.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        // Récupération de l’utilisateur courant
        guard let me = UserDefaults.currentUser else {
            return goBack()
        }
        meId = me.sid
        
        // Enregistrement des cellules
        registerCellsNib()
        
        // Récupération des messages
        getMessages()
        
        // Notifications clavier
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
        
        // Configuration du tableau des suggestions de mention
        ui_tableview_mentions.delegate = self
        ui_tableview_mentions.dataSource = self
        ui_tableview_mentions.register(UINib(nibName: MentionCell.identifier, bundle: nil), forCellReuseIdentifier: MentionCell.identifier)
        ui_tableview_mentions.isHidden = true
        // Initialiser la hauteur de la table des suggestions à 0
        table_view_mention_height.constant = 0
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if isGroupMember && isStartEditing {
            isStartEditing = false
            _ = ui_textview_message.becomeFirstResponder()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // S'assurer que la table des suggestions reste au-dessus
        self.view.bringSubviewToFront(ui_tableview_mentions)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Clavier
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        ui_constraint_bottom_view_Tf.constant = keyboardFrame.height
        UIView.animate(withDuration: 1) {
            self.view.layoutIfNeeded()
        }
        if messages.count == 0 {
            ui_view_empty.isHidden = true
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        ui_constraint_bottom_view_Tf.constant = bottomConstraint
        if messages.count == 0 {
            ui_view_empty.isHidden = false
        }
    }
    
    // MARK: - Méthodes utilitaires
    func setItemsTranslated(messages: [PostMessage]) {
        if LanguageManager.getTranslatedByDefaultValue() {
            for msg in messages {
                translatedMessageIDs.insert(msg.uid)
            }
        }
    }
    
    func registerCellsNib() {
        ui_tableview.register(
            UINib(nibName: DetailMessageTopPostImageCell.identifier, bundle: nil),
            forCellReuseIdentifier: DetailMessageTopPostImageCell.identifier
        )
        ui_tableview.register(
            UINib(nibName: DetailMessageTopPostTextCell.identifier, bundle: nil),
            forCellReuseIdentifier: DetailMessageTopPostTextCell.identifier
        )
    }
    
    // MARK: - Conversion en HTML
    func getHTMLMessage() -> String? {
        guard let attributedText = ui_textview_message.attributedText else { return nil }
        do {
            let htmlData = try attributedText.data(
                from: NSRange(location: 0, length: attributedText.length),
                documentAttributes: [.documentType: NSAttributedString.DocumentType.html]
            )
            if var htmlString = String(data: htmlData, encoding: .utf8) {
                if let bodyStartRange = htmlString.range(of: "<body>"),
                   let bodyEndRange = htmlString.range(of: "</body>") {
                    htmlString = String(htmlString[bodyStartRange.upperBound..<bodyEndRange.lowerBound])
                }
                return htmlString.trimmingCharacters(in: .whitespacesAndNewlines)
            }
        } catch {
            print("Erreur conversion HTML: \(error)")
        }
        return nil
    }
    
    // MARK: - Réseau
    func getMessages() {
        let _eventId = (eventId != 0) ? String(eventId) : hashedEventId
        let _postId = (parentCommentId != 0) ? String(parentCommentId) : hashedCommentId
        
        EventService.getCommentsFor(eventId: _eventId, parentPostId: _postId) { messages, error in
            if let messages = messages {
                self.messages = messages
                self.ui_view_empty.isHidden = (self.messages.count > 0)
                self.setItemsTranslated(messages: messages)
                self.ui_tableview.reloadData()
                
                if self.postMessage == nil {
                    self.getDetailPost()
                    return
                }
                
                if self.messages.count + self.messagesForRetry.count > 0 {
                    DispatchQueue.main.async {
                        let indexPath = IndexPath(row: self.messages.count + self.messagesForRetry.count - 1, section: 0)
                        self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }
    
    func getDetailPost() {
        EventService.getDetailPostMessage(eventId: eventId, parentPostId: parentCommentId) { message, error in
            self.postMessage = message
            self.ui_tableview.reloadData()
            
            if self.messages.count + self.messagesForRetry.count > 0 {
                DispatchQueue.main.async {
                    let indexPath = IndexPath(row: self.messages.count + self.messagesForRetry.count - 1, section: 0)
                    self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }
    
    func sendMessage(message: String, isRetry: Bool, positionForRetry: Int = 0) {
        ui_textview_message.text = ""
        ui_textview_message.attributedText = NSAttributedString(string: "")
        ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")
        
        EventService.postCommentFor(eventId: eventId, parentPostId: parentCommentId, message: message) { error in
            if error == nil {
                if isRetry, positionForRetry >= 0, positionForRetry < self.messagesForRetry.count {
                    self.messagesForRetry.remove(at: positionForRetry)
                }
                self.getMessages()
            } else {
                if !isRetry {
                    var postMsg = PostMessage()
                    postMsg.content = message
                    postMsg.user = UserLightNeighborhood()
                    postMsg.isRetryMsg = true
                    self.messagesForRetry.append(postMsg)
                    self.isStartEditing = false
                    self.ui_view_empty.isHidden = true
                    self.ui_tableview.reloadData()
                    
                    if self.messages.count + self.messagesForRetry.count > 0 {
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(row: self.messages.count + self.messagesForRetry.count - 1, section: 0)
                            self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                    }
                }
            }
            // Ici, à défaut d'un HUD, on peut désactiver temporairement l'interaction sur le bouton
            self.ui_iv_bt_send.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                self.ui_iv_bt_send.isUserInteractionEnabled = true
            }
        }
    }
    
    // MARK: - IBActions
    @IBAction func action_tap_view(_ sender: Any) {
        _ = ui_textview_message.resignFirstResponder()
        hideMentionSuggestions()
    }
    
    @IBAction func action_send_message(_ sender: Any) {
        closeKb(nil)
    }
    
    @IBAction func action_signal(_ sender: Any) {
        if let navvc = UIStoryboard(name: StoryboardName.neighborhoodReport, bundle: nil).instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController,
           let vc = navvc.topViewController as? ReportGroupMainViewController {
            vc.eventId = eventId
            vc.postId = parentCommentId
            vc.parentDelegate = self
            vc.signalType = .publication
            self.present(navvc, animated: true)
        }
    }
    
    // MARK: - Méthodes pour la fonctionnalité de mention
    func updateMentionSuggestions(query: String) {
        EventService.getEventUsersWithQuery(eventId: eventId, query: query) { [weak self] users, error in
            guard let self = self else { return }
            if let users = users, !users.isEmpty {
                let limitedUsers = Array(users.prefix(3))
                self.mentionSuggestions = limitedUsers
                
                let rowCount = self.mentionSuggestions.count
                UIView.animate(withDuration: 0.2) {
                    self.table_view_mention_height.constant = self.mentionCellHeight * CGFloat(rowCount)
                    self.view.layoutIfNeeded()
                }
                
                self.ui_tableview_mentions.reloadData()
                self.animateShowTableViewMentions()
            } else {
                self.hideMentionSuggestions()
            }
        }
    }
    
    func hideMentionSuggestions() {
        mentionSuggestions = []
        ui_tableview_mentions.reloadData()
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
            self.table_view_mention_height.constant = 0
            self.ui_tableview_mentions.transform = CGAffineTransform(translationX: 0, y: 20)
            self.ui_tableview_mentions.alpha = 0
            self.view.layoutIfNeeded()
        }, completion: { _ in
            self.ui_tableview_mentions.isHidden = true
            self.ui_tableview_mentions.transform = .identity
        })
    }
    
    func animateShowTableViewMentions() {
        ui_tableview_mentions.transform = CGAffineTransform(translationX: 0, y: 20)
        ui_tableview_mentions.alpha = 0
        ui_tableview_mentions.isHidden = false
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.ui_tableview_mentions.transform = .identity
            self.ui_tableview_mentions.alpha = 1
        }, completion: nil)
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
            let linkURLString = "https://preprod.entourage.social/app/users/\(user.sid)"
            guard let linkURL = URL(string: linkURLString) else { return }
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .link: linkURL,
                .foregroundColor: UIColor.blue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let mentionAttributedString = NSAttributedString(string: "@\(user.displayName)", attributes: linkAttributes)
            currentAttributedText.replaceCharacters(in: replaceRange, with: mentionAttributedString)
            ui_textview_message.attributedText = currentAttributedText
            let newCursorPosition = atRange.location + mentionAttributedString.length
            ui_textview_message.selectedRange = NSRange(location: newCursorPosition, length: 0)
        }
        hideMentionSuggestions()
        
        let style = ApplicationTheme.getFontCourantRegularNoir()
        ui_textview_message.typingAttributes = [
            .font: style.font,
            .foregroundColor: style.color
        ]
    }
    
    @objc func closeKb(_ sender: UIBarButtonItem?) {
        if let htmlMessage = getHTMLMessage(), !htmlMessage.isEmpty, htmlMessage != placeholderTxt {
            sendMessage(message: htmlMessage, isRetry: false)
        }
        _ = ui_textview_message.resignFirstResponder()
        hideMentionSuggestions()
        
        ui_textview_message.text = ""
        ui_textview_message.attributedText = NSAttributedString(string: "")
        
        let styleReset = ApplicationTheme.getFontRegular13Orange()
        ui_textview_message.typingAttributes = [
            .font: styleReset.font,
            .foregroundColor: styleReset.color
        ]
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension EventDetailMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ui_tableview_mentions {
            return mentionSuggestions.count
        } else {
            let hasTop = postMessage != nil ? 1 : 0
            return messages.count + messagesForRetry.count + hasTop
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView == ui_tableview_mentions {
            let user = mentionSuggestions[indexPath.row]
            if let cell = ui_tableview_mentions.dequeueReusableCell(withIdentifier: "MentionCell") as? MentionCell {
                cell.selectionStyle = .none
                cell.configure(igm: user.avatarURL ?? "placeholder_user", name: user.displayName)
                return cell
            }
        }
        
        if indexPath.row == 0, let post = postMessage {
            let identifier = post.isPostImage ? DetailMessageTopPostImageCell.identifier : DetailMessageTopPostTextCell.identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! DetailMessageTopPostCell
            cell.populateCell(message: post)
            cell.delegate = self
            return cell
        }
        
        let realIndex = (postMessage == nil) ? indexPath.row : indexPath.row - 1
        
        if messagesForRetry.count > 0, realIndex >= messages.count {
            let message = messagesForRetry[realIndex - messages.count]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMe", for: indexPath) as! NeighborhoodMessageCell
            let isTranslated = translatedMessageIDs.contains(message.uid)
            cell.populateCell(isMe: true, message: message, isRetry: true, positionRetry: realIndex - messages.count, delegate: self, isTranslated: isTranslated)
            return cell
        }
        
        let message = messages[realIndex]
        var cellId = "cellOther"
        var isMe = false
        if message.user?.sid == self.meId {
            cellId = "cellMe"
            isMe = true
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! NeighborhoodMessageCell
        let isTranslated = translatedMessageIDs.contains(message.uid)
        cell.populateCell(isMe: isMe, message: message, isRetry: false, delegate: self, isTranslated: isTranslated)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == ui_tableview_mentions {
            if let cell = tableView.cellForRow(at: indexPath) as? MentionCell {
                UIView.animate(withDuration: 0.2, animations: {
                    cell.contentView.backgroundColor = UIColor.appBeige
                }, completion: { _ in
                    let selectedUser = self.mentionSuggestions[indexPath.row]
                    self.insertMention(user: selectedUser)
                    UIView.animate(withDuration: 0.2) {
                        cell.contentView.backgroundColor = UIColor.appBeigeClair2
                    }
                    tableView.deselectRow(at: indexPath, animated: true)
                })
            }
        }
    }
}

// MARK: - MJNavBackViewDelegate
extension EventDetailMessagesViewController: MJNavBackViewDelegate {
    func goBack() {
        parentDelegate?.updateCommentCount(parentCommentId: parentCommentId, nbComments: messages.count, currentIndexPathSelected: selectedIndexPath)
        dismiss(animated: true)
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension EventDetailMessagesViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let newLength = (textView.text as NSString).replacingCharacters(in: range, with: text).count
        ui_iv_bt_send.image = (newLength > 0) ? UIImage(named: "ic_send_comment") : UIImage(named: "ic_send_comment_off")
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        let cursorPosition = textView.selectedRange.location
        let textNSString = textView.text as NSString
        let textUpToCursor = textNSString.substring(to: cursorPosition)
        
        if let atIndex = textUpToCursor.lastIndex(of: "@") {
            if atIndex == textUpToCursor.startIndex || textUpToCursor[textUpToCursor.index(before: atIndex)] == " " {
                let mentionSubstring = textUpToCursor[atIndex...]
                if mentionSubstring.contains(" ") {
                    hideMentionSuggestions()
                } else {
                    let query = String(mentionSubstring.dropFirst())
                    updateMentionSuggestions(query: query)
                }
            } else {
                hideMentionSuggestions()
            }
        } else {
            hideMentionSuggestions()
        }
    }
    
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {
        WebLinkManager.openUrl(url: URL, openInApp: true, presenterViewController: self)
        return false
    }
}

// MARK: - MessageCellSignalDelegate
extension EventDetailMessagesViewController: MessageCellSignalDelegate {
    func signalMessage(messageId: Int, userId: Int, textString: String) {
        if let navvc = UIStoryboard(name: StoryboardName.neighborhoodReport, bundle: nil).instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController,
           let vc = navvc.topViewController as? ReportGroupMainViewController {
            vc.eventId = eventId
            vc.postId = parentCommentId
            vc.parentDelegate = self
            vc.signalType = .comment
            vc.userId = userId
            vc.messageId = messageId
            vc.textString = textString
            self.present(navvc, animated: true)
        }
    }
    
    func retrySend(message: String, positionForRetry: Int) {
        sendMessage(message: message, isRetry: true, positionForRetry: positionForRetry)
    }
    
    func showUser(userId: Int?) {
        guard let userId = userId else { return }
        if let profileVC = UIStoryboard(name: StoryboardName.profileParams, bundle: nil)
            .instantiateViewController(withIdentifier: "profileFull") as? ProfilFullViewController {
            profileVC.userIdToDisplay = "\(userId)"
            profileVC.modalPresentationStyle = .fullScreen
            self.present(profileVC, animated: true)
        }
    }
    
    func showWebUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
}

// MARK: - GroupDetailDelegate
extension EventDetailMessagesViewController: GroupDetailDelegate {
    func translateItem(id: Int) {
        if translatedMessageIDs.contains(id) {
            translatedMessageIDs.remove(id)
        } else {
            translatedMessageIDs.insert(id)
        }
        if let index = messages.firstIndex(where: { $0.uid == id }) {
            let indexPath = IndexPath(row: index + (postMessage != nil ? 1 : 0), section: 0)
            ui_tableview.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func publicationDeleted() {
        getMessages()
        ui_tableview.reloadData()
    }
    
    func showMessage(signalType: GroupDetailSignalType) {
        let alertVC = MJAlertController()
        let buttonCancel = MJAlertButtonType(
            title: "OK".localized,
            titleStyle: ApplicationTheme.getFontCourantBoldOrange(),
            bgColor: .appOrange,
            cornerRadius: -1
        )
        let title = (signalType == .comment) ? "report_comment_title".localized : "report_publication_title".localized
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
}

// MARK: - DetailMessageTopCellDelegate
extension EventDetailMessagesViewController: DetailMessageTopCellDelegate {
    func showWebView(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension EventDetailMessagesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: ui_tableview_mentions) {
            return false
        }
        return true
    }
}
protocol UpdateCommentCountDelegate: AnyObject {
  func updateCommentCount(parentCommentId: Int, nbComments: Int, currentIndexPathSelected: IndexPath?)
}

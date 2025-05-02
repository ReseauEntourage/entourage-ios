//
//  NeighborhoodDetailMessagesViewController.swift
//  entourage
//
//  Créé par Jerome le 16/05/2022.
//  Mis à jour pour intégrer la fonctionnalité de mention avec requête côté serveur,
//  insertion d’un lien cliquable, conversion de l'attributedText en HTML pour l'envoi,
//  empêcher le UITapGestureRecognizer d'intercepter les touches sur la table view des suggestions,
//  réinitialiser correctement le UITextView après l'envoi (suppression du style URL),
//  et appliquer à nouveau une police de base après l'envoi (ex: getFontRegular13Orange()).
//  Désormais, on appelle l’API même si query est vide pour afficher 3 résultats max dès “@”.
//  La hauteur de la table de mentions s’adapte dynamiquement au nombre de résultats (max 3).
//

import UIKit
import IHProgressHUD
import IQKeyboardManagerSwift

class NeighborhoodDetailMessagesViewController: UIViewController {

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
    
    // Nouvelle contrainte pour la hauteur de la table de mentions
    @IBOutlet weak var table_view_mention_height: NSLayoutConstraint!
    
    // MARK: - Nouvel outlet pour la liste de suggestions de mention
    @IBOutlet weak var ui_tableview_mentions: UITableView!

    // MARK: - Variables existantes
    var hashedNeighborhoodId: String = ""
    var neighborhoodId: Int = 0
    var hashedParentCommentId: String = ""
    var parentCommentId: Int = 0
    var neighborhoodName = ""
    var isGroupMember = false
    var translatedMessageIDs = Set<Int>()

    var messages = [PostMessage]()
    var meId: Int = 0
    var messagesForRetry = [PostMessage]()

    let placeholderTxt = "neighborhood_comments_placeholder_discut".localized
    var bottomConstraint: CGFloat = 0
    var isStartEditing = false
    var selectedIndexPath: IndexPath? = nil
    weak var parentDelegate: UpdateCommentCountDelegate? = nil
    var postMessage: PostMessage? = nil

    // MARK: - Propriétés pour la fonctionnalité de mention
    /// Liste filtrée affichée dans le tableau des suggestions (obtenue via l’appel serveur)
    var mentionSuggestions: [UserLightNeighborhood] = []
    
    /// Hauteur d’une cellule “MentionCell” (à adapter selon ta maquette)
    private let mentionCellHeight: CGFloat = 44.0

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        // Désactivation du gestionnaire clavier par défaut
        ui_tap_gesture.cancelsTouchesInView = false
        ui_tap_gesture.delegate = self
        IQKeyboardManager.shared.enable = false

        // Configuration de la barre de navigation
        ui_top_view.populateView(
            title: "neighborhood_comments_title".localized,
            titleFont: ApplicationTheme.getFontQuickSandBold(size: 15),
            titleColor: .black,
            delegate: self,
            backgroundColor: .appBeigeClair,
            isClose: false
        )

        // Configuration de la vue "vide" et du message pour non authentifié
        ui_title_empty.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title_empty.text = "neighborhood_no_messageComment".localized
        ui_view_empty.isHidden = true

        ui_title_not_auth.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        ui_title_not_auth.text = String(format: "neighborhood_messageComment_notAuth".localized, neighborhoodName)
        ui_view_not_auth.isHidden = isGroupMember

        // Mise en forme de la zone de saisie
        ui_view_txtview.layer.borderWidth = 1
        ui_view_txtview.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_txtview.layer.cornerRadius = ui_view_txtview.frame.height / 2

        // Configuration du UITextView
        ui_textview_message.delegate = self
        ui_textview_message.hasToCenterTextVerticaly = true

        // Configuration du bouton envoyer
        ui_view_button_send.backgroundColor = .clear
        ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")

        // Ajout d’une toolbar au UITextView
        let screenWidth = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        let buttonDone = UIBarButtonItem(
            title: "neighborhood_comments_send".localized,
            style: .plain,
            target: self,
            action: #selector(closeKb(_:))
        )
        ui_textview_message.addToolBar(width: screenWidth, buttonValidate: buttonDone)
        ui_textview_message.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_textview_message.placeholderText = placeholderTxt
        ui_textview_message.placeholderColor = .appOrange

        // Récupération de l'utilisateur courant
        guard let me = UserDefaults.currentUser else {
            return goBack()
        }
        meId = me.sid

        // Enregistrement des cellules et chargement des messages
        registerCellsNib()
        getMessages()

        // Notifications pour le clavier
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
        
        // On met la hauteur à 0 au départ
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
        // On s'assure que le tableau des suggestions est toujours au premier plan.
        self.view.bringSubviewToFront(ui_tableview_mentions)
    }

    // MARK: - Helpers
    func setItemsTranslated(messages: [PostMessage]) {
        if LanguageManager.getTranslatedByDefaultValue() {
            for message in messages {
                translatedMessageIDs.insert(message.uid)
            }
        }
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
        else {
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

    deinit {
        NotificationCenter.default.removeObserver(self)
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

    // MARK: - Réseau
    func getMessages() {
        NeighborhoodService.getCommentsFor(neighborhoodId: neighborhoodId, parentPostId: parentCommentId) { messages, error in
            Logger.print("***** Messages ? \(String(describing: messages)) - Error: \(String(describing: error?.message))")
            if let messages = messages {
                self.messages = messages
                self.ui_view_empty.isHidden = self.messages.count > 0
                self.setItemsTranslated(messages: messages)
                self.ui_tableview.reloadData()

                if self.postMessage == nil {
                    self.getDetailPost()
                    return
                }

                // Scroller tout en bas
                let lastSection = self.ui_tableview.numberOfSections - 1
                if lastSection >= 0 {
                    let lastRow = self.ui_tableview.numberOfRows(inSection: lastSection) - 1
                    if lastRow >= 0 {
                        let indexPath = IndexPath(row: lastRow, section: lastSection)
                        self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    }
                }
            }
        }
    }

    func sendMessage(message: String, isRetry: Bool, positionForRetry: Int = 0) {
        // On vide le contenu du UITextView et on désactive le bouton d'envoi
        ui_textview_message.text = ""
        ui_textview_message.attributedText = NSAttributedString(string: "")
        ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")

        NeighborhoodService.postCommentFor(
            neighborhoodId: self.neighborhoodId,
            parentPostId: self.parentCommentId,
            message: message
        ) { error in
            if error == nil {
                if isRetry, positionForRetry >= 0, positionForRetry < self.messagesForRetry.count {
                    self.messagesForRetry.remove(at: positionForRetry)
                }
                // On attend 2 secondes avant de rafraîchir
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.getMessages()
                }
            } else {
                if !isRetry {
                    var postMsg = PostMessage()
                    postMsg.content = message
                    postMsg.user = UserLightNeighborhood()
                    postMsg.isRetryMsg = true
                    self.messagesForRetry.append(postMsg)
                    self.ui_textview_message.text = ""
                    self.isStartEditing = false
                    self.ui_view_empty.isHidden = true
                    self.ui_tableview.reloadData()

                    if self.messages.count + self.messagesForRetry.count > 0 {
                        DispatchQueue.main.async {
                            let indexPath = IndexPath(
                                row: self.messages.count + self.messagesForRetry.count - 1,
                                section: 0
                            )
                            self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                        }
                    }
                }
            }
            IHProgressHUD.show()
            self.ui_iv_bt_send.isUserInteractionEnabled = false
            self.ui_view_txtview.isUserInteractionEnabled = false
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.ui_iv_bt_send.isUserInteractionEnabled = true
                self.ui_view_txtview.isUserInteractionEnabled = true
                IHProgressHUD.dismiss()
            }
        }
    }

    func getDetailPost() {
        NeighborhoodService.getDetailPostMessage(
            neighborhoodId: neighborhoodId,
            parentPostId: parentCommentId
        ) { message, error in
            self.postMessage = message
            self.ui_tableview.reloadData()
            if self.messages.count + self.messagesForRetry.count > 0 {
                DispatchQueue.main.async {
                    let indexPath = IndexPath(
                        row: self.messages.count + self.messagesForRetry.count - 1,
                        section: 0
                    )
                    self.ui_tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
                }
            }
        }
    }

    // MARK: - IBActions
    @IBAction func action_tap_view(_ sender: Any) {
        // Ce geste est déclenché pour les zones hors du tableau des suggestions.
        _ = ui_textview_message.resignFirstResponder()
        hideMentionSuggestions()
    }

    @IBAction func action_send_message(_ sender: Any) {
        closeKb(nil)
    }

    @IBAction func action_signal(_ sender: Any) {
        if let navVC = UIStoryboard(name: StoryboardName.neighborhoodReport, bundle: nil)
            .instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController,
           let vc = navVC.topViewController as? ReportGroupMainViewController {
            vc.groupId = neighborhoodId
            vc.postId = parentCommentId
            vc.parentDelegate = self
            vc.signalType = .publication
            self.present(navVC, animated: true)
        }
    }

    // MARK: - Méthodes pour la fonctionnalité de mention
    /// Met à jour la liste des suggestions en appelant le back-end, même si query est vide,
    /// et limite l'affichage à 3 utilisateurs maximum.
    func updateMentionSuggestions(query: String) {
        // Pas de test "if query.isEmpty" => on appelle toujours l'API
        NeighborhoodService.getNeighborhoodUsersWithQuery(
            neighborhoodId: neighborhoodId,
            query: query
        ) { [weak self] users, error in
            guard let self = self else { return }
            // Filtrer les utilisateurs pour exclure l'utilisateur courant
            let filteredUsers = users?.filter { $0.sid != UserDefaults.currentUser?.sid } ?? []
            
            if !filteredUsers.isEmpty {
                // On limite à 3 suggestions
                let limitedUsers = Array(filteredUsers.prefix(3))
                self.mentionSuggestions = limitedUsers
                
                // Calcul de la hauteur à afficher en fonction du nombre de suggestions
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


    /// Masque le tableau des suggestions de mention (avec animation)
    func hideMentionSuggestions() {
        mentionSuggestions = []
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


    /// Insère dans le UITextView, sans quitter le mode édition, un NSAttributedString
    /// avec un lien cliquable vers le profil
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
            let linkURLString: String
            linkURLString = baseUrl + "users/\(user.sid)"
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

        let style = ApplicationTheme.getFontCourantRegularNoir()
        ui_textview_message.typingAttributes = [
            .font: style.font,
            .foregroundColor: style.color
        ]
    }

    // MARK: - Action de fermeture du clavier et envoi (conversion en HTML)
    @objc func closeKb(_ sender: UIBarButtonItem?) {
        // Conversion de l'attributedText en HTML (extraction du contenu <body>)
        if let htmlMessage = getHTMLMessage(), !htmlMessage.isEmpty, htmlMessage != placeholderTxt {
            sendMessage(message: htmlMessage, isRetry: false)
        }
        _ = ui_textview_message.resignFirstResponder()
        hideMentionSuggestions()

        // Réinitialisation complète du UITextView pour supprimer toute mise en forme
        ui_textview_message.text = placeholderTxt
        ui_textview_message.attributedText = NSAttributedString(string: placeholderTxt)

        // ⬇️ Remettre la police d'origine après l'envoi
        let styleReset = ApplicationTheme.getFontRegular13Orange()
        ui_textview_message.typingAttributes = [
            .font: styleReset.font,
            .foregroundColor: styleReset.color
        ]
        ui_textview_message.textColor = UIColor.appOrange

    }

    // MARK: - Animations pour la tableview des mentions
    private func animateShowTableViewMentions() {
        // Préparation de la vue pour l'animation
        ui_tableview_mentions.transform = CGAffineTransform(translationX: 0, y: 20)
        ui_tableview_mentions.alpha = 0
        ui_tableview_mentions.isHidden = false

        // Animation d’apparition
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
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension NeighborhoodDetailMessagesViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView == ui_tableview_mentions {
            return mentionSuggestions.count
        } else {
            let hasTop = postMessage != nil ? 1 : 0
            return messages.count + messagesForRetry.count + hasTop
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        // TableView des mentions
        if tableView == ui_tableview_mentions {
            let user = mentionSuggestions[indexPath.row]
            if let cell = ui_tableview_mentions.dequeueReusableCell(withIdentifier: "MentionCell") as? MentionCell {
                cell.selectionStyle = .none
                cell.configure(igm: user.avatarURL ?? "placeholder_user", name: user.displayName)
                return cell
            }
        }

        // TableView principal (messages)
        if indexPath.row == 0, let post = postMessage {
            let identifier = post.isPostImage
                ? DetailMessageTopPostImageCell.identifier
                : DetailMessageTopPostTextCell.identifier
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
                as! DetailMessageTopPostCell
            cell.populateCell(message: post)
            cell.delegate = self
            return cell
        }

        let realIndex = (postMessage == nil) ? indexPath.row : indexPath.row - 1

        // Cas message retry
        if messagesForRetry.count > 0, realIndex >= messages.count {
            let message = messagesForRetry[realIndex - messages.count]
            let cell = tableView.dequeueReusableCell(withIdentifier: "cellMe", for: indexPath)
                as! NeighborhoodMessageCell
            let isTranslated = translatedMessageIDs.contains(message.uid)
            cell.populateCell(
                isMe: true,
                message: message,
                isRetry: true,
                positionRetry: realIndex - messages.count,
                delegate: self,
                isTranslated: isTranslated
            )
            return cell
        }

        // Cas message normal
        let message = messages[realIndex]
        var cellId = "cellOther"
        var isMe = false
        if message.user?.sid == self.meId {
            cellId = "cellMe"
            isMe = true
        }
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath)
            as! NeighborhoodMessageCell
        let isTranslated = translatedMessageIDs.contains(message.uid)
        cell.populateCell(
            isMe: isMe,
            message: message,
            isRetry: false,
            delegate: self,
            isTranslated: isTranslated
        )
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView == ui_tableview_mentions {
            // Récupérer la cellule sélectionnée
            if let cell = tableView.cellForRow(at: indexPath) as? MentionCell {
                // Animation: changement de background en orange
                UIView.animate(withDuration: 0.2, animations: {
                    cell.contentView.backgroundColor = UIColor.appBeige
                }, completion: { _ in
                    // Une fois l'animation terminée, on insère la mention
                    let selectedUser = self.mentionSuggestions[indexPath.row]
                    self.insertMention(user: selectedUser)
                    
                    // Optionnel: réinitialiser la couleur de fond pour que la cellule redevienne normale
                    UIView.animate(withDuration: 0.2) {
                        cell.contentView.backgroundColor = UIColor.appBeigeClair2
                    }
                    
                    // Désélectionner la cellule
                    tableView.deselectRow(at: indexPath, animated: true)
                })
            }
        }
    }
}

// MARK: - MJNavBackViewDelegate
extension NeighborhoodDetailMessagesViewController: MJNavBackViewDelegate {
    func didTapEvent() {
        //Nothing yet

    }
    
    func goBack() {
        parentDelegate?.updateCommentCount(
            parentCommentId: parentCommentId,
            nbComments: messages.count,
            currentIndexPathSelected: selectedIndexPath
        )
        dismiss(animated: true)
        navigationController?.dismiss(animated: true)
    }
}

// MARK: - UITextViewDelegate
extension NeighborhoodDetailMessagesViewController: UITextViewDelegate {
    func textView(_ textView: UITextView,
                  shouldChangeTextIn range: NSRange,
                  replacementText text: String) -> Bool {
        if textView.text.count == 0 && text.count == 1 {
            ui_iv_bt_send.image = UIImage(named: "ic_send_comment")
        } else if textView.text.count == 1 && text.count == 0 {
            ui_iv_bt_send.image = UIImage(named: "ic_send_comment_off")
        } else if textView.text.count > 0 {
            ui_iv_bt_send.image = UIImage(named: "ic_send_comment")
        } else {
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
                    let query = String(mentionSubstring.dropFirst())
                    // On appelle la fonction => limite 3
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
extension NeighborhoodDetailMessagesViewController: MessageCellSignalDelegate {
    func signalMessage(messageId: Int, userId: Int, textString: String) {
        if let navVC = UIStoryboard(name: StoryboardName.neighborhoodReport, bundle: nil)
            .instantiateViewController(withIdentifier: "reportNavVC") as? UINavigationController,
           let vc = navVC.topViewController as? ReportGroupMainViewController {
            vc.groupId = neighborhoodId
            vc.postId = messageId
            vc.parentDelegate = self
            vc.signalType = .comment
            vc.userId = userId
            vc.messageId = messageId
            vc.textString = textString
            present(navVC, animated: true)
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
            present(profileVC, animated: true)
        }
    }

    func showWebUrl(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
}

// MARK: - GroupDetailDelegate
extension NeighborhoodDetailMessagesViewController: GroupDetailDelegate {
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
            titleStyle: ApplicationTheme.getFontCourantBoldBlanc(),
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
}

// MARK: - DetailMessageTopCellDelegate
extension NeighborhoodDetailMessagesViewController: DetailMessageTopCellDelegate {
    func showWebView(url: URL) {
        WebLinkManager.openUrl(url: url, openInApp: true, presenterViewController: self)
    }
}

// MARK: - UIGestureRecognizerDelegate
extension NeighborhoodDetailMessagesViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        // Si le toucher est sur la table view des suggestions ou sur une de ses cellules, retourner false.
        if let view = touch.view, view.isDescendant(of: ui_tableview_mentions) {
            return false
        }
        return true
    }
}

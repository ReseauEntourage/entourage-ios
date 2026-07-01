//
//  NeighborhoodPostAddViewController.swift
//  entourage
//
//  Créé par Jerome le 19/05/2022.
//  Modifié pour intégrer le système de mention dans l'UITextView du post.
//  Distinction entre NeighborhoodServices et EventServices selon isNeighborhood.
//

import UIKit
import SVProgressHUD

class NeighborhoodPostAddViewController: UIViewController {

    // MARK: - IBOutlets existants
    @IBOutlet weak var ui_top_view: MJNavBackView!
    
    @IBOutlet weak var ui_lb_message: UILabel!
    @IBOutlet weak var ui_lb_message_dsc: UILabel!
    @IBOutlet weak var ui_lb_photo: UILabel!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_image_placeholder: UIImageView!
    @IBOutlet weak var ui_lb_photo_dsc: UILabel!
    
    @IBOutlet weak var ui_view_button_validate: UIView!
    
    @IBOutlet weak var ui_iv_bt_add_remove: UIImageView!
    @IBOutlet weak var ui_title_button_validate: UILabel!
    @IBOutlet weak var ui_tv_message: MJTextViewPlaceholder!
    
    @IBOutlet weak var ui_tv_error: UILabel!
    @IBOutlet weak var ui_view_error: UIView!
    
    // MARK: - Nouveaux IBOutlets pour le système de mention
    @IBOutlet weak var ui_tableview_mentions: UITableView!
    @IBOutlet weak var table_view_mention_height: NSLayoutConstraint!
    
    @IBOutlet var ui_tap_gesture: UITapGestureRecognizer!
    @IBOutlet weak var textViewHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Propriétés existantes
    var currentImage: UIImage? = nil
    let cornerRadiusImage: CGFloat = 14
    var isValid = false

    var neighborhoodId: Int = 0
    var eventId: Int = 0
    var neighborhood: Neighborhood? = nil

    var isNeighborhood = true

    var isLoading = false

    // MARK: - Propriétés pour la fonctionnalité de mention
    var mentionSuggestions: [UserLightNeighborhood] = []
    private let mentionCellHeight: CGFloat = 50.0

    // MARK: - Chips d'inspiration
    private struct PostChip {
        let label: String
        let draft: String
    }

    private static let generalisteChips: [PostChip] = [
        PostChip(label: "Info de quartier 📢", draft: "Je voulais partager une info qui concerne notre quartier : "),
        PostChip(label: "Proposer une activité 🎉", draft: "J'organise une petite activité et j'aimerais vous inviter ! "),
        PostChip(label: "Demander un coup de main 🤝", draft: "Bonjour à tous, j'aurais besoin d'un petit coup de main pour "),
        PostChip(label: "Dire bonjour 👋", draft: "Bonjour à tous ! Je voulais juste prendre contact avec le groupe 😊"),
    ]

    private static let thematiqueChips: [PostChip] = [
        PostChip(label: "Partager un contenu 💡", draft: "J'ai trouvé quelque chose d'intéressant à partager avec vous : "),
        PostChip(label: "Poser une question ❓", draft: "Bonjour, j'aurais une question pour le groupe : "),
        PostChip(label: "Proposer un échange 💬", draft: "J'aimerais qu'on échange sur ce sujet ensemble : "),
        PostChip(label: "Organiser une rencontre 📅", draft: "Et si on se retrouvait prochainement ? Je propose "),
    ]

    private var selectedChipButton: UIButton? = nil

    // MARK: - View Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()

        if isNeighborhood {
            setupInspirationChips()
        }

        // Configuration de la barre de navigation et des labels
        ui_top_view.populateView(title: "neighborhood_add_post_title".localized,
                                 titleFont: ApplicationTheme.getFontQuickSandBold(size: 15),
                                 titleColor: .black,
                                 delegate: self,
                                 isClose: false)
        ui_lb_message.text = "neighborhood_add_post_message_title".localized
        ui_lb_message_dsc.text = "neighborhood_add_post_message_subtitle".localized
        
        ui_lb_photo.text = "neighborhood_add_post_image_title".localized
        ui_lb_photo_dsc.text = "neighborhood_add_post_image_subtitle".localized
        ui_title_button_validate.text = "neighborhood_add_post_send_button".localized
        ui_title_button_validate.setFontBody(size: 15)
        
        ui_tv_message.placeholderText = "neighborhood_add_post_message_placeholder".localized
        ui_tv_message.placeholderColor = .lightGray
        
        let buttonDone = UIBarButtonItem(title: "validate".localized, style: .plain, target: self, action: #selector(closeKb))
        let _width = UIApplication.shared.delegate?.window??.frame.width ?? view.frame.size.width
        ui_tv_message.addToolBar(width: _width, buttonValidate: buttonDone)
        
        ui_lb_message.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_lb_photo.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_lb_message_dsc.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        ui_lb_photo_dsc.setupFontAndColor(style: ApplicationTheme.getFontLegend())
        
        ui_title_button_validate.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_view_button_validate.layer.cornerRadius = ui_view_button_validate.frame.height / 2
        ui_image.layer.cornerRadius = cornerRadiusImage
        ui_view_error.isHidden = true
        ui_tv_error.text = "neighborhood_add_post_error".localized
        ui_tv_error.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegularItalic(size: 11), color: .rougeErreur))
        
        showButton(isAdd: true)
        changeButtonShare()
        
        // Intégration du delegate du UITextView pour la gestion des mentions
        ui_tv_message.delegate = self
        
        // Configuration du tableau des suggestions de mention
        ui_tableview_mentions.delegate = self
        ui_tableview_mentions.dataSource = self
        ui_tableview_mentions.register(UINib(nibName: MentionCell.identifier, bundle: nil), forCellReuseIdentifier: MentionCell.identifier)
        ui_tableview_mentions.isHidden = true
        table_view_mention_height.constant = 0
        
        // Configuration du UITapGestureRecognizer pour ne pas intercepter les touches sur le tableau des suggestions
        ui_tap_gesture.delegate = self
        ui_tap_gesture.cancelsTouchesInView = false
        
        if isNeighborhood {
            AnalyticsLoggerManager.logEvent(name: View_GroupFeed_NewPost_Screen)
        }
    }
    
    // MARK: - Méthode de configuration de bouton (existant)
    func configureOrangeButton(_ button: UIButton, withTitle title: String) {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.appOrange
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = ApplicationTheme.getFontQuickSandBold(size: 14)
        button.clipsToBounds = true
    }
    
    // MARK: - Fermeture du clavier
    @objc func closeKb() {
        _ = ui_tv_message.resignFirstResponder()
        changeButtonShare()
        hideMentionSuggestions()
    }
    
    // MARK: - Chips d'inspiration setup
    private func setupInspirationChips() {
        let isThematic = neighborhood?.zone == nil
        let chips = isThematic ? Self.thematiqueChips : Self.generalisteChips

        guard let messageSection = ui_tv_message.superview,
              let outerContainer = messageSection.superview else { return }

        let photoSection = ui_image.superview

        // Label "Besoin d'inspiration ?"
        let inspirationLabel = UILabel()
        inspirationLabel.translatesAutoresizingMaskIntoConstraints = false
        inspirationLabel.text = "neighborhood_post_inspiration_title".localized
        inspirationLabel.font = ApplicationTheme.getFontQuickSandBold(size: 13)
        inspirationLabel.textColor = .appOrange
        outerContainer.addSubview(inspirationLabel)

        // Grille 2 colonnes
        let gridStack = UIStackView()
        gridStack.translatesAutoresizingMaskIntoConstraints = false
        gridStack.axis = .vertical
        gridStack.spacing = 8
        outerContainer.addSubview(gridStack)

        let pairs = stride(from: 0, to: chips.count, by: 2).map { i in
            Array(chips[i..<min(i + 2, chips.count)])
        }
        for (rowIndex, pair) in pairs.enumerated() {
            let rowStack = UIStackView()
            rowStack.axis = .horizontal
            rowStack.spacing = 8
            rowStack.distribution = .fillEqually
            for (colIndex, chip) in pair.enumerated() {
                let button = UIButton(type: .custom)
                button.setTitle(chip.label, for: .normal)
                button.setTitleColor(.appGrisSombre, for: .normal)
                button.titleLabel?.font = ApplicationTheme.getFontNunitoRegular(size: 13)
                button.titleLabel?.numberOfLines = 1
                button.titleLabel?.adjustsFontSizeToFitWidth = true
                button.titleLabel?.minimumScaleFactor = 0.8
                button.backgroundColor = .white
                button.layer.borderWidth = 1.5
                button.layer.borderColor = UIColor.appOrangeLight.cgColor
                button.layer.cornerRadius = 16
                button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 12, bottom: 10, right: 12)
                button.contentHorizontalAlignment = .left
                button.tag = rowIndex * 2 + colIndex
                button.addTarget(self, action: #selector(chipTapped(_:)), for: .touchUpInside)
                rowStack.addArrangedSubview(button)
            }
            gridStack.addArrangedSubview(rowStack)
        }

        let chipHeight: CGFloat = 40
        let chipSpacing: CGFloat = 8
        let labelHeight: CGFloat = 20
        let topMargin: CGFloat = 12
        let numRows = CGFloat((chips.count + 1) / 2)
        let totalChipsHeight = numRows * chipHeight + (numRows - 1) * chipSpacing
        let totalOffset = topMargin + labelHeight + 8 + totalChipsHeight + 12

        NSLayoutConstraint.activate([
            inspirationLabel.topAnchor.constraint(equalTo: messageSection.bottomAnchor, constant: topMargin),
            inspirationLabel.leadingAnchor.constraint(equalTo: ui_lb_message.leadingAnchor),
            inspirationLabel.trailingAnchor.constraint(equalTo: ui_lb_message.trailingAnchor),
            inspirationLabel.heightAnchor.constraint(equalToConstant: labelHeight),

            gridStack.topAnchor.constraint(equalTo: inspirationLabel.bottomAnchor, constant: 8),
            gridStack.leadingAnchor.constraint(equalTo: ui_lb_message.leadingAnchor),
            gridStack.trailingAnchor.constraint(equalTo: ui_lb_message.trailingAnchor),
        ])

        // Décale la section photo pour laisser de la place au label + chips
        if let photoSection = photoSection {
            for constraint in outerContainer.constraints {
                if let firstView = constraint.firstItem as? UIView,
                   firstView == photoSection,
                   constraint.firstAttribute == .top {
                    constraint.constant += totalOffset
                    break
                }
            }
        }
    }

    @objc private func chipTapped(_ sender: UIButton) {
        let isThematic = neighborhood?.zone == nil
        let chips = isThematic ? Self.thematiqueChips : Self.generalisteChips
        guard sender.tag < chips.count else { return }

        if selectedChipButton == sender {
            deselectCurrentChip()
            ui_tv_message.text = ""
            changeButtonShare()
            return
        }

        deselectCurrentChip()

        sender.backgroundColor = UIColor(red: 254/255, green: 234/255, blue: 227/255, alpha: 1)
        sender.layer.borderColor = UIColor.appOrange.cgColor
        sender.setTitleColor(.appOrangeDark, for: .normal)
        selectedChipButton = sender

        ui_tv_message.text = chips[sender.tag].draft
        ui_tv_message.textColor = .black
        _ = ui_tv_message.resignFirstResponder()
        changeButtonShare()
    }

    private func deselectCurrentChip() {
        selectedChipButton?.backgroundColor = .white
        selectedChipButton?.layer.borderColor = UIColor.appOrangeLight.cgColor
        selectedChipButton?.setTitleColor(.appGrisSombre, for: .normal)
        selectedChipButton = nil
    }

    deinit {
        Logger.print("***** deinit VC")
    }
    
    // MARK: - Gestion de l'état du bouton d'envoi
    func showButton(isAdd: Bool) {
        let imgName = isAdd ? "ic_neighb_bt_plus" : "ic_button_close_white_round"
        ui_iv_bt_add_remove.image = UIImage(named: imgName)
    }
    
    func changeButtonShare() {
        if currentImage != nil || !(ui_tv_message.text?.isEmpty ?? true) {
            ui_view_button_validate.backgroundColor = .appOrange
            isValid = true
        } else {
            isValid = false
            ui_view_button_validate.backgroundColor = .appOrangeLight_50
        }
    }
    
    // MARK: - Actions sur l'image (ajout / suppression)
    @IBAction func action_add_or_clear(_ sender: Any) {
        if currentImage != nil {
            currentImage = nil
            self.ui_image.image = nil
            showButton(isAdd: true)
            self.ui_image.backgroundColor = .appBeige
            self.ui_image_placeholder.isHidden = false
            changeButtonShare()
        } else {
            if isNeighborhood {
                AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_NewPost_AddPic)
            }
            if let navvc = storyboard?.instantiateViewController(withIdentifier: "addPhotoNav") as? UINavigationController,
               let vc = navvc.topViewController as? NeighborhoodPostAddPhotoViewController {
                vc.parentDelegate = self
                self.present(navvc, animated: true)
            }
        }
    }
    
    // MARK: - Action d'envoi du post
    @IBAction func action_send(_ sender: Any) {
        if !isValid || isLoading { return }
        hideMentionSuggestions()
        _ = ui_tv_message.resignFirstResponder()
        if currentImage == nil {
            sendMessageOnly()
        } else {
            sendImageText()
        }
        if isNeighborhood {
            AnalyticsLoggerManager.logEvent(name: Action_GroupFeed_NewPost_Validate)
        }
    }
    
    // MARK: - Conversion en HTML pour prendre en compte le texte enrichi (mentions)
    func getHTMLMessage() -> String? {
        guard let attributedText = ui_tv_message.attributedText else { return nil }

        let placeholder = ui_tv_message.placeholderText ?? "neighborhood_add_post_message_placeholder".localized
        let currentText = ui_tv_message.text.trimmingCharacters(in: .whitespacesAndNewlines)
        if currentText.isEmpty || currentText == placeholder {
            return nil
        }

        do {
            let htmlData = try attributedText.data(from: NSRange(location: 0, length: attributedText.length),
                                                   documentAttributes: [.documentType: NSAttributedString.DocumentType.html])
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
    
    // MARK: - Envoi du post (texte seul)
    func sendMessageOnly() {
        isLoading = true
        SVProgressHUD.show()
        guard let htmlMessage = getHTMLMessage(), !htmlMessage.isEmpty else {
            isLoading = false
            SVProgressHUD.dismiss()
            return
        }
        if isNeighborhood {
            NeighborhoodService.createPostMessage(groupId: neighborhoodId, message: htmlMessage) { error in
                self.isLoading = false
                if error != nil {
                    self.ui_view_error.isHidden = false
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
                    self.goBack()
                }
            }
        } else {
            EventService.createPostMessage(eventId: eventId, message: htmlMessage) { error in
                self.isLoading = false
                if error != nil {
                    self.ui_view_error.isHidden = false
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
                    self.goBack()
                }
            }
        }
    }
    
    // MARK: - Envoi du post (texte et image)
    func sendImageText() {
        self.isLoading = true
        SVProgressHUD.show()
        if isNeighborhood {
            NeighborhoodUploadPictureService.prepareUploadWith(neighborhoodId: neighborhoodId, image: currentImage!, message: getHTMLMessage() ?? "") { isOk in
                self.isLoading = false
                if !isOk {
                    self.ui_view_error.isHidden = false
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationNeighborhoodUpdate), object: nil)
                    self.goBack()
                }
            }
        } else {
            EventUploadPictureService.prepareUploadWith(eventId: eventId, image: currentImage!, message: getHTMLMessage() ?? "") { isOk in
                self.isLoading = false
                if !isOk {
                    self.ui_view_error.isHidden = false
                } else {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: kNotificationEventUpdate), object: nil)
                    self.goBack()
                }
            }
        }
    }
    
    // MARK: - Méthodes du système de mention
    
    /// Mise à jour des suggestions via l'API (limitées à 3 résultats)
    func updateMentionSuggestions(query: String) {
        if isNeighborhood {
            NeighborhoodService.getNeighborhoodUsersWithQuery(neighborhoodId: neighborhoodId, query: query) { [weak self] users, error in
                guard let self = self else { return }
                // Filtrer les utilisateurs pour exclure l'utilisateur courant
                let filteredUsers = users?.filter { $0.sid != UserDefaults.currentUser?.sid } ?? []
                
                if !filteredUsers.isEmpty {
                    let limitedUsers = Array(filteredUsers.prefix(1000))
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
        } else {
            EventService.getEventUsersWithQuery(eventId: eventId, query: query) { [weak self] users, error in
                guard let self = self else { return }
                // Filtrer les utilisateurs pour exclure l'utilisateur courant
                let filteredUsers = users?.filter { $0.sid != UserDefaults.currentUser?.sid } ?? []
                
                if !filteredUsers.isEmpty {
                    let limitedUsers = Array(filteredUsers.prefix(3))
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
    }

    
    /// Masquage des suggestions de mention avec animation
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
    
    /// Animation d'apparition du tableau des suggestions
    func animateShowTableViewMentions() {
        ui_tableview_mentions.transform = CGAffineTransform(translationX: 0, y: 20)
        ui_tableview_mentions.alpha = 0
        ui_tableview_mentions.isHidden = false
        
        UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseOut, animations: {
            self.ui_tableview_mentions.transform = .identity
            self.ui_tableview_mentions.alpha = 1
        }, completion: nil)
    }
    
    /// Insertion de la mention sélectionnée dans le UITextView
    func insertMention(user: UserLightNeighborhood) {
        let currentAttributedText: NSMutableAttributedString
        if let attributed = ui_tv_message.attributedText, attributed.length > 0 {
            currentAttributedText = NSMutableAttributedString(attributedString: attributed)
        } else {
            currentAttributedText = NSMutableAttributedString(string: ui_tv_message.text ?? "")
        }
        
        let cursorLocation = ui_tv_message.selectedRange.location
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
            if isNeighborhood {
                linkURLString = baseUrl + "users/\(user.sid)"
            } else {
                linkURLString = baseUrl + "event/users/\(user.sid)"
            }
            guard let linkURL = URL(string: linkURLString) else { return }
            let linkAttributes: [NSAttributedString.Key: Any] = [
                .link: linkURL,
                .foregroundColor: UIColor.blue,
                .underlineStyle: NSUnderlineStyle.single.rawValue
            ]
            let cleanedDisplayName = user.displayName.cleanedForMention()
            let mentionAttributedString = NSAttributedString(string: "@\(cleanedDisplayName)", attributes: linkAttributes)
            currentAttributedText.replaceCharacters(in: replaceRange, with: mentionAttributedString)
            ui_tv_message.attributedText = currentAttributedText
            let newCursorPosition = atRange.location + mentionAttributedString.length
            ui_tv_message.selectedRange = NSRange(location: newCursorPosition, length: 0)
        }
        hideMentionSuggestions()
        // Réinitialisation des attributs de saisie (police et couleur de base)
        let styleFont = ApplicationTheme.getFontNunitoRegular(size: 15)
        ui_tv_message.typingAttributes = [.font: styleFont, .foregroundColor: UIColor.black]
    }
}

// MARK: - UITextViewDelegate
extension NeighborhoodPostAddViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        deselectCurrentChip()
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
        let size = textView.sizeThatFits(CGSize(width: textView.frame.width, height: CGFloat.greatestFiniteMagnitude))
        // Mettre à jour la contrainte de hauteur du UITextView
        self.textViewHeightConstraint.constant = size.height
        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension NeighborhoodPostAddViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mentionSuggestions.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let user = mentionSuggestions[indexPath.row]
        if let cell = tableView.dequeueReusableCell(withIdentifier: MentionCell.identifier) as? MentionCell {
            cell.selectionStyle = .none
            cell.configure(igm: user.avatarURL ?? "placeholder_user", name: user.displayName)
            return cell
        }
        return UITableViewCell()
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

// MARK: - UIGestureRecognizerDelegate
extension NeighborhoodPostAddViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        if let view = touch.view, view.isDescendant(of: ui_tableview_mentions) {
            return false
        }
        return true
    }
}

// MARK: - MJNavBackViewDelegate
extension NeighborhoodPostAddViewController: MJNavBackViewDelegate {
    func goBack() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            SVProgressHUD.dismiss()
            self.dismiss(animated: true)
        }
    }
    func didTapEvent() {
        //Nothing yet
    }
}


// MARK: - TakePhotoDelegate -
extension NeighborhoodPostAddViewController: TakePhotoDelegate {
    func updatePhoto(image: UIImage?) {
        if image == nil {
            self.ui_image.backgroundColor = .appBeige
            self.ui_image_placeholder.isHidden = false
        } else {
            self.ui_image.backgroundColor = .clear
            self.ui_image_placeholder.isHidden = true
        }
        
        self.currentImage = image
        self.ui_image.image = self.currentImage
        self.showButton(isAdd: image == nil)
        changeButtonShare()
    }
}

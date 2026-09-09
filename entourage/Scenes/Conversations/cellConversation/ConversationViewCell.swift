import UIKit
import SDWebImage
import ActiveLabel

// MARK: - Constants

private let unifiedBlue = UIColor(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0)
private let conversationBaseFont: UIFont = UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
private let deletedBackgroundColor = UIColor.appPaleGrey
private let deletedTextColor = UIColor(named: "appGreyTextDeleted") ?? UIColor.darkGray

// MARK: - Base Cell

class ConversationViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var ui_image_avatar: UIImageView!
    @IBOutlet weak var ui_image_comment: UIImageView!
    @IBOutlet weak var ui_constraint_image_height: NSLayoutConstraint!
    @IBOutlet weak var ui_label_comment: ActiveLabel!   // ActiveLabel au lieu de UILabel
    @IBOutlet weak var ui_label_date: UILabel!          // "Nom • HH:mm"
    @IBOutlet weak var ui_view_label: UIView!           // bulle
    @IBOutlet weak var ui_label_min_width: NSLayoutConstraint?

    // MARK: - Properties
    private var deletedImageView: UIImageView?
    weak var delegate: MessageCellSignalDelegate?
    private var currentMessage: PostMessage?
    private var currentPositionForRetry: Int = 0
    private var currentIsMe: Bool = false

    private var fixedLabelWidthConstraint: NSLayoutConstraint?
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageAspectConstraint: NSLayoutConstraint?

    // MARK: - Réactions & options ("•••" toujours du côté opposé à l'avatar)
    private let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "ellipsis"), for: .normal)
        button.tintColor = .appGreyOff
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let reactionPickerBar = ReactionPickerBarView()
    private let reactionBadges = ReactionBadgesView()
    private lazy var reactionsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [reactionPickerBar, reactionBadges])
        stack.axis = .vertical
        stack.spacing = 6
        stack.alignment = .leading
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private var optionsLeadingConstraint: NSLayoutConstraint?
    private var optionsTrailingConstraint: NSLayoutConstraint?
    private var isPickerOpen = false

    /// Map des mentions (sans @, normalisées) -> URL de profil (issue du HTML)
    private var mentionLinkMap: [String: URL] = [:]

    // Détection custom des numéros de tel
    private let phoneType = ActiveType.custom(pattern: "\\+?\\d[\\d .-]{6,}\\d")

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        // Avatar
        ui_image_avatar.layer.masksToBounds = true
        ui_image_avatar.clipsToBounds = true

        // Image de message
        ui_image_comment.contentMode = .scaleAspectFill
        ui_image_comment.clipsToBounds = true
        ui_image_comment.isUserInteractionEnabled = true
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        ui_image_comment.addGestureRecognizer(tapGesture)

        // Date
        ui_label_date.setFontBody(size: 12)

        // ActiveLabel config
        ui_label_comment.numberOfLines = 0
        ui_label_comment.font = conversationBaseFont
        ui_label_comment.textColor = .black
        ui_label_comment.enabledTypes = [.url, .mention, .hashtag, phoneType]
        ui_label_comment.URLColor = unifiedBlue
        ui_label_comment.hashtagColor = unifiedBlue
        ui_label_comment.mentionColor = unifiedBlue
        ui_label_comment.lineBreakMode = .byWordWrapping

        // Liens soulignés
        ui_label_comment.configureLinkAttribute = { (_, attributes, _) in
            var attrs = attributes
            attrs[.underlineStyle] = NSUnderlineStyle.single.rawValue
            return attrs
        }

        // Taps
        ui_label_comment.handleURLTap { [weak self] url in
            self?.delegate?.showWebUrl(url: url)
        }
        ui_label_comment.handleCustomTap(for: phoneType) { _ in
            // Optionnel: ouvrir le dialer, proposer de copier, etc.
        }
        ui_label_comment.handleMentionTap { [weak self] mention in
            guard let self else { return }
            let key = self.normalizeMention(mention)
            if let url = self.mentionLinkMap[key] {
                self.delegate?.showWebUrl(url: url)
            } else {
                // Pas d’URL connue pour cette mention (texte brut)
            }
        }

        // Icône "supprimé"
        if let img = UIImage(named: "ic_deleted_comment") {
            let iv = UIImageView(image: img.withRenderingMode(.alwaysTemplate))
            iv.tintColor = deletedTextColor
            iv.translatesAutoresizingMaskIntoConstraints = false
            deletedImageView = iv
        }

        // Largeur MAX de la bulle ≈ 80% de l’écran (moins un padding pour les marges internes)
        ui_view_label.translatesAutoresizingMaskIntoConstraints = false
        if fixedLabelWidthConstraint == nil {
            let screenWidth = UIScreen.main.bounds.width
            let horizontalPadding: CGFloat = 40   // marge interne (leading/trailing de la bulle)
            let maxWidth = screenWidth * 0.8 - horizontalPadding

            fixedLabelWidthConstraint = ui_view_label.widthAnchor.constraint(lessThanOrEqualToConstant: maxWidth)
            fixedLabelWidthConstraint?.isActive = true

            ui_view_label.setContentHuggingPriority(.required, for: .horizontal)
            ui_view_label.setContentCompressionResistancePriority(.required, for: .horizontal)
        }

        // Long press → réactions (uniquement sur un message reçu, jamais le sien)
        ui_view_label.isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        ui_view_label.addGestureRecognizer(longPressGesture)

        setupOptionsAndReactions()
    }

    private func setupOptionsAndReactions() {
        contentView.addSubview(optionsButton)
        contentView.addSubview(reactionsStack)

        optionsButton.addTarget(self, action: #selector(handleOptionsTap), for: .touchUpInside)
        reactionBadges.onTap = nil

        // Collé à la bulle, du côté opposé à l'avatar (pas à l'extrémité de l'écran).
        let leading = optionsButton.trailingAnchor.constraint(equalTo: ui_view_label.leadingAnchor, constant: -6)
        let trailing = optionsButton.leadingAnchor.constraint(equalTo: ui_view_label.trailingAnchor, constant: 6)
        optionsLeadingConstraint = leading
        optionsTrailingConstraint = trailing

        // Le .xib pin `ui_label_date.top` directement sous la bulle — on détache cette
        // contrainte pour intercaler la barre de réactions AU-DESSUS du nom/heure
        // (bulle → réactions → nom), sans toucher au reste de la mise en page.
        detachTopConstraint(of: ui_label_date, from: ui_view_label)

        NSLayoutConstraint.activate([
            optionsButton.widthAnchor.constraint(equalToConstant: 28),
            optionsButton.heightAnchor.constraint(equalToConstant: 28),
            optionsButton.centerYAnchor.constraint(equalTo: ui_view_label.centerYAnchor),
            // Filet de sécurité pour ne jamais sortir de l'écran sur une bulle très large.
            optionsButton.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 2),
            optionsButton.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -2),

            reactionsStack.topAnchor.constraint(equalTo: ui_view_label.bottomAnchor, constant: 4),
            reactionsStack.leadingAnchor.constraint(equalTo: ui_view_label.leadingAnchor),
            reactionsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10),

            ui_label_date.topAnchor.constraint(equalTo: reactionsStack.bottomAnchor, constant: 4)
        ])
    }

    /// Détache la contrainte `.top` du .xib reliant `label` au bas de `anchorView`, pour
    /// pouvoir la repositionner par code (ex: intercaler une vue entre les deux).
    private func detachTopConstraint(of label: UIView, from anchorView: UIView) {
        guard let container = label.superview else { return }
        let toDeactivate = container.constraints.filter { constraint in
            (constraint.firstItem === label && constraint.firstAttribute == .top) ||
            (constraint.secondItem === label && constraint.secondAttribute == .top)
        }
        NSLayoutConstraint.deactivate(toDeactivate)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ui_image_avatar.layer.cornerRadius = ui_image_avatar.bounds.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset images
        ui_image_avatar.image = UIImage(named: "placeholder_user")
        ui_image_comment.image = nil

        // Reset image sizing
        ui_constraint_image_height.constant = 0
        imageWidthConstraint?.isActive = false
        imageAspectConstraint?.isActive = false
        imageWidthConstraint = nil
        imageAspectConstraint = nil

        // Reset texte
        ui_label_comment.text = nil
        ui_label_comment.attributedText = nil
        ui_label_date.text = nil
        mentionLinkMap.removeAll()

        // Reset styles
        ui_view_label.backgroundColor = .clear
        deletedImageView?.removeFromSuperview()
        ui_label_min_width?.isActive = false

        // Reset divers
        delegate = nil
        currentMessage = nil
        currentPositionForRetry = 0
        isPickerOpen = false
        reactionPickerBar.isHidden = true
    }

    // MARK: - Configuration
    func configure(with message: PostMessage, isMe: Bool, positionForRetry: Int = 0) {
        currentMessage = message
        currentPositionForRetry = positionForRetry
        currentIsMe = isMe
        mentionLinkMap.removeAll()

        optionsLeadingConstraint?.isActive = isMe
        optionsTrailingConstraint?.isActive = !isMe

        isPickerOpen = false
        reactionPickerBar.isHidden = true
        reactionBadges.configure(reactions: message.reactions, types: ReactionType.stored())

        // Avatar
        if let urlStr = message.user?.avatarURL, let url = URL(string: urlStr) {
            ui_image_avatar.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image_avatar.image = UIImage(named: "placeholder_user")
        }

        // Contenu / statut
        if let status = message.status?.lowercased() {
            switch status {
            case "deleted":
                applyDeletedStyle(text: NSLocalizedString("deleted_comment", comment: ""))
            case "offensive", "offensible":
                applyDeletedStyle(text: NSLocalizedString("content_removed", comment: ""))
            default:
                applyNormalContent(message: message, isMe: isMe)
            }
        } else {
            applyNormalContent(message: message, isMe: isMe)
        }

        // Nom + heure (HH:mm uniquement)
        ui_label_date.text = formattedNameAndTime(from: message)

        // ----- Image attachée -----
        if let imgUrl = message.messageImageUrl, let url = URL(string: imgUrl) {
            ui_image_comment.sd_setImage(with: url, placeholderImage: nil)

            let screenWidth = UIScreen.main.bounds.width
            let horizontalPadding: CGFloat = 40
            // Image carrée ≈ 80% de la largeur écran
            let maxImageSize = screenWidth * 0.8 - horizontalPadding

            ui_constraint_image_height.constant = maxImageSize

            imageWidthConstraint?.isActive = false
            imageAspectConstraint?.isActive = false
            imageWidthConstraint = ui_image_comment.widthAnchor.constraint(equalToConstant: maxImageSize)
            imageAspectConstraint = ui_image_comment.heightAnchor.constraint(equalTo: ui_image_comment.widthAnchor)
            imageWidthConstraint?.isActive = true
            imageAspectConstraint?.isActive = true

            // aligne la bulle avec la largeur image
            ui_label_min_width?.constant = maxImageSize
            ui_label_min_width?.isActive = true
        } else {
            // Pas d’image
            ui_image_comment.image = nil
            ui_constraint_image_height.constant = 0

            imageWidthConstraint?.isActive = false
            imageAspectConstraint?.isActive = false
            imageWidthConstraint = nil
            imageAspectConstraint = nil

            ui_label_min_width?.isActive = false
        }

        layoutIfNeeded()
    }

    // MARK: - Gestures
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        // Réactions : uniquement sur un message reçu, jamais sur son propre message.
        guard gesture.state == .began, !currentIsMe, currentMessage != nil else { return }
        toggleReactionPicker()
    }

    @objc private func handleOptionsTap() {
        guard let msg = currentMessage else { return }
        delegate?.signalMessage(
            messageId: msg.uid,
            userId: msg.user?.sid ?? 0,
            textString: (msg.contentHtml?.isEmpty == false ? msg.contentHtml : msg.content) ?? "",
            status: msg.status
        )
    }

    private func toggleReactionPicker() {
        guard let msg = currentMessage, let types = ReactionType.stored(), !types.isEmpty else { return }
        isPickerOpen.toggle()
        reactionPickerBar.configure(types: types, selectedId: msg.reactionId) { [weak self] type in
            guard let self, let currentMsg = self.currentMessage else { return }
            self.isPickerOpen = false
            UIView.animate(withDuration: 0.2) { self.reactionPickerBar.isHidden = true }
            self.delegate?.didTapReaction(messageId: currentMsg.uid, reactionType: type)
        }
        UIView.animate(withDuration: 0.2) {
            self.reactionPickerBar.isHidden = !self.isPickerOpen
        }
    }

    @objc private func handleImageTap(_ gesture: UITapGestureRecognizer) {
        guard let imageURL = currentMessage?.messageImageUrl,
              let url = URL(string: imageURL) else { return }
        SDWebImageManager.shared.loadImage(
            with: url,
            options: .continueInBackground,
            progress: nil
        ) { [weak self] (image, _, _, _, _, _) in
            guard let self = self, let image = image else { return }
            self.delegate?.showFullScreenImage(image)
        }
    }

    // MARK: - Styles
    private func applyDeletedStyle(text: String) {
        ui_view_label.backgroundColor = deletedBackgroundColor
        ui_label_comment.textColor = deletedTextColor
        ui_label_comment.enabledTypes = [] // pas de liens cliquables

        // ----- Icône supprimé avec taille FIXE (plus grande qu’avant) -----
        let font = conversationBaseFont
        let attachment = NSTextAttachment()

        if let baseImage = UIImage(named: "ic_deleted_comment")?.withRenderingMode(.alwaysTemplate) {
            let tinted = baseImage.withTintColor(deletedTextColor)
            attachment.image = tinted

            // 👉 Taille du picto (ADAPTE ici si tu veux plus grand)
            let iconSize: CGFloat = 18 

            let ratio = tinted.size.width / max(tinted.size.height, 1)
            attachment.bounds = CGRect(
                x: 0,
                y: (font.descender / 2), // alignement vertical propre
                width: iconSize * ratio,
                height: iconSize
            )
        }

        // Petit espace entre le picto et le texte
        let spacer = NSAttributedString(string: "  ")

        // Attribut texte supprimé
        let textAttr = NSAttributedString(
            string: text,
            attributes: [
                .font: font,
                .foregroundColor: deletedTextColor
            ]
        )

        // Final : icône + espace + texte
        let final = NSMutableAttributedString()
        final.append(NSAttributedString(attachment: attachment))
        final.append(spacer)
        final.append(textAttr)

        ui_label_comment.attributedText = final

        // Pas besoin de min width dans ce mode
        ui_label_min_width?.isActive = false
    }


    private func applyNormalContent(message: PostMessage, isMe: Bool) {
        ui_view_label.backgroundColor = isMe ? UIColor.appBeige : UIColor.orangeMedium
        if message.messageType == "auto" {
            ui_view_label.backgroundColor = UIColor.appBleuAuto
        }

        ui_label_comment.textColor = .black
        ui_label_comment.enabledTypes = [.url, .mention, .hashtag, phoneType]

        if let html = message.contentHtml, !html.isEmpty {
            ui_label_comment.text = htmlToPlainWithLinksAndMentionMap(html)
        } else if let content = message.content, !content.isEmpty {
            ui_label_comment.text = content.trimmingCharacters(in: .whitespacesAndNewlines)
        } else {
            ui_label_comment.text = ""
        }
    }

    // MARK: - Name + Time (HH:mm)
    private func formattedNameAndTime(from message: PostMessage) -> String {
        let nameOpt: String? = message.user?.displayName
        let trimmedName = nameOpt?.trimmingCharacters(in: .whitespacesAndNewlines)

        if let d = message.createdDate {
            let time = hourFormatter.string(from: d)
            if let n = trimmedName, !n.isEmpty { return "\(n) • \(time)" }
            return time
        }
        let fallbackTime = message.createdTimeFormatted.trimmingCharacters(in: .whitespacesAndNewlines)
        if !fallbackTime.isEmpty {
            if let n = trimmedName, !n.isEmpty { return "\(n) • \(fallbackTime)" }
            return fallbackTime
        }
        let raw = message.createdDateString
        if !raw.isEmpty {
            if let n = trimmedName, !n.isEmpty { return "\(n) • \(raw)" }
            return raw
        }
        return trimmedName ?? ""
    }

    // MARK: - Helpers (HTML ➜ texte + map des mentions)
    private func htmlToPlainWithLinksAndMentionMap(_ html: String) -> String {
        var s = html
        let pattern = #"<a\s+[^>]*href="([^"]+)"[^>]*>(.*?)</a>"#
        if let re = try? NSRegularExpression(pattern: pattern, options: [.caseInsensitive, .dotMatchesLineSeparators]) {
            let ns = s as NSString
            let matches = re.matches(in: s, options: [], range: NSRange(location: 0, length: ns.length))

            for match in matches.reversed() {
                guard match.numberOfRanges >= 3 else { continue }
                let href = (s as NSString).substring(with: match.range(at: 1))
                let rawText = (s as NSString).substring(with: match.range(at: 2))

                let cleanText = rawText
                    .replacingOccurrences(of: "<br ?/?>", with: "\n", options: .regularExpression)
                    .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
                    .trimmingCharacters(in: .whitespacesAndNewlines)

                if cleanText.hasPrefix("@"), let url = URL(string: href) {
                    let key = normalizeMention(cleanText)
                    mentionLinkMap[key] = url
                    s = (s as NSString).replacingCharacters(in: match.range, with: cleanText)
                } else {
                    if looksLikeURL(cleanText) {
                        s = (s as NSString).replacingCharacters(in: match.range, with: cleanText)
                    } else {
                        let replacement = cleanText.isEmpty ? href : "\(cleanText) (\(href))"
                        s = (s as NSString).replacingCharacters(in: match.range, with: replacement)
                    }
                }
            }
        }

        s = s.replacingOccurrences(of: "<br ?/?>", with: "\n", options: .regularExpression)
             .replacingOccurrences(of: "<[^>]+>", with: "", options: .regularExpression)
             .replacingOccurrences(of: "&nbsp;", with: " ")
             .trimmingCharacters(in: .whitespacesAndNewlines)
        return s
    }

    private func normalizeMention(_ mention: String) -> String {
        var m = mention
        if m.hasPrefix("@") { m.removeFirst() }
        m = m.trimmingCharacters(in: CharacterSet(charactersIn: " .,:;!?)»»”’\""))
        return m.lowercased()
    }

    private func looksLikeURL(_ text: String) -> Bool {
        let pattern = #"(?i)\bhttps?://[^\s]+"#
        return text.range(of: pattern, options: .regularExpression) != nil
    }

    // MARK: - Formatter
    private lazy var hourFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale.current
        f.timeZone = .current
        return f
    }()
}

// MARK: - Subclasses

class ConversationMeCell: ConversationViewCell {
    static let identifier = "cellMeWithImage"
}

class ConversationOtherCell: ConversationViewCell {
    static let identifier = "cellOtherWithImage"
}

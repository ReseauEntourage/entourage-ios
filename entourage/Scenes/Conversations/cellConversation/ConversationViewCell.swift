import UIKit
import SDWebImage
import ActiveLabel

// MARK: - Constants

private let unifiedBlue = UIColor(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0)
private let conversationBaseFont: UIFont = UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
private let deletedBackgroundColor = UIColor.appPaleGrey
private let deletedTextColor = UIColor(named: "appGreyTextDeleted") ?? UIColor.darkGray

// Regroupement des messages (EN-9558) : bulles d'un même groupe collées, coins resserrés côté
// expéditeur à l'intérieur du groupe, espace normal entre deux groupes.
private let groupOuterSpacing: CGFloat = 7
private let groupInnerSpacing: CGFloat = 1.5
private let bubbleOuterRadius: CGFloat = 18
private let bubbleInnerRadius: CGFloat = 6
/// Marge droite des messages envoyés, alignée sur l'icône du header.
private let outgoingBubbleTrailingMargin: CGFloat = 20

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

    // MARK: - Regroupement (EN-9558)
    /// Mise en page « message envoyé » (bulle calée à droite). Surchargé par ConversationMeCell.
    class var isOutgoingLayout: Bool { return false }
    private var isFirstInGroup = true
    private var isLastInGroup = true
    private var bubbleTopConstraint: NSLayoutConstraint?
    private var reactionsTopConstraint: NSLayoutConstraint?
    private var dateTopConstraint: NSLayoutConstraint?
    private var bottomConstraint: NSLayoutConstraint?
    private let bubbleMaskLayer = CAShapeLayer()

    // MARK: - Réactions & options (pastille "Réagir" sous la bulle, ouvre l'overlay unifié
    // réactions + options — cf. MessageActionOverlay. Masquée sur son propre message : seul
    // l'appui long y donne alors accès, cf. handleLongPress/presentOverlay.)
    private let optionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.backgroundColor = .white
        button.layer.cornerRadius = 16
        button.layer.masksToBounds = true
        button.layer.borderWidth = 1
        button.layer.borderColor = UIColor.appMessagingBorder.cgColor
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    private let optionsIcon: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "face.smiling"))
        iv.tintColor = .appOrange
        iv.contentMode = .scaleAspectFit
        iv.isUserInteractionEnabled = false
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    private let optionsLabel: UILabel = {
        let label = UILabel()
        label.text = "react_action_button".localized
        label.font = UIFont(name: "NunitoSans-SemiBold", size: 13) ?? UIFont.systemFont(ofSize: 13)
        // Contraste WCAG AA (EN-9558) : texte standard foncé, l'icône orange garde le repère couleur.
        label.textColor = .appAnthracite
        label.isUserInteractionEnabled = false
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    private lazy var optionsContentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [optionsIcon, optionsLabel])
        stack.axis = .horizontal
        stack.spacing = 6
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    private let reactionBadges = ReactionBadgesView()
    private lazy var reactionsStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [reactionBadges, optionsButton])
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()

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
        ui_label_date.setFontBody(size: 13)
        ui_label_date.textColor = .appTextDisabled

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

        // Long press → overlay unifié réactions + options, sur son propre message comme sur celui d'un autre
        ui_view_label.isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        ui_view_label.addGestureRecognizer(longPressGesture)

        // Coins de bulle "groupés" (rayons différents par coin) : le cornerRadius uniforme du .xib
        // est remplacé par un masque, recalculé à chaque layout (cf. updateBubbleMask).
        ui_view_label.layer.cornerRadius = 0
        ui_view_label.layer.mask = bubbleMaskLayer

        setupOptionsAndReactions()
        setupGroupingLayout()
    }

    /// Ajuste la mise en page du .xib pour le regroupement des messages (EN-9558).
    private func setupGroupingLayout() {
        bubbleTopConstraint = contentView.constraints.first {
            $0.firstItem === ui_view_label && $0.firstAttribute == .top && $0.secondItem === contentView
        }
        bottomConstraint = contentView.constraints.first {
            $0.firstItem === contentView && $0.firstAttribute == .bottom && $0.secondItem === ui_label_date
        }

        // Avatar de l'interlocuteur(trice) aligné sur le bas de la bulle : affiché une seule fois,
        // à côté du dernier message du groupe.
        NSLayoutConstraint.deactivate(contentView.constraints.filter {
            $0.firstItem === ui_image_avatar && $0.firstAttribute == .top
        })
        ui_image_avatar.bottomAnchor.constraint(equalTo: ui_view_label.bottomAnchor).isActive = true

        guard type(of: self).isOutgoingLayout else { return }

        // Plus d'avatar sur ses propres messages : on supprime l'espace qui lui était réservé et
        // la bulle est calée à droite de l'écran, au niveau de l'icône du header.
        NSLayoutConstraint.deactivate(contentView.constraints.filter {
            ($0.firstItem === ui_image_avatar && $0.secondItem === ui_view_label) ||
            ($0.firstItem === ui_view_label && $0.secondItem === ui_image_avatar)
        })
        // L'heure passe à droite, sous la bulle.
        NSLayoutConstraint.deactivate(contentView.constraints.filter {
            $0.firstItem === ui_label_date && $0.firstAttribute == .leading
        })
        NSLayoutConstraint.activate([
            ui_view_label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -outgoingBubbleTrailingMargin),
            ui_label_date.trailingAnchor.constraint(equalTo: ui_view_label.trailingAnchor, constant: -4),
            ui_label_date.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20)
        ])
    }

    private func setupOptionsAndReactions() {
        contentView.addSubview(reactionsStack)

        optionsButton.addTarget(self, action: #selector(handleOptionsTap), for: .touchUpInside)
        optionsButton.addSubview(optionsContentStack)
        reactionBadges.onTap = { [weak self] in
            guard let self, let messageId = self.currentMessage?.uid else { return }
            self.delegate?.showReactionUsers(messageId: messageId)
        }

        // Le .xib pin `ui_label_date.top` directement sous la bulle — on détache cette
        // contrainte pour intercaler la barre de réactions AU-DESSUS du nom/heure
        // (bulle → réactions → nom), sans toucher au reste de la mise en page.
        detachTopConstraint(of: ui_label_date, from: ui_view_label)

        let reactionsTop = reactionsStack.topAnchor.constraint(equalTo: ui_view_label.bottomAnchor, constant: 4)
        let dateTop = ui_label_date.topAnchor.constraint(equalTo: reactionsStack.bottomAnchor, constant: 4)
        reactionsTopConstraint = reactionsTop
        dateTopConstraint = dateTop

        // Réactions alignées sur le bord de la bulle côté expéditeur(trice).
        let reactionsHorizontal: [NSLayoutConstraint] = type(of: self).isOutgoingLayout
            ? [reactionsStack.trailingAnchor.constraint(equalTo: ui_view_label.trailingAnchor),
               reactionsStack.leadingAnchor.constraint(greaterThanOrEqualTo: contentView.leadingAnchor, constant: 20)]
            : [reactionsStack.leadingAnchor.constraint(equalTo: ui_view_label.leadingAnchor),
               reactionsStack.trailingAnchor.constraint(lessThanOrEqualTo: contentView.trailingAnchor, constant: -10)]

        NSLayoutConstraint.activate([
            optionsIcon.widthAnchor.constraint(equalToConstant: 18),
            optionsIcon.heightAnchor.constraint(equalToConstant: 18),
            optionsContentStack.topAnchor.constraint(equalTo: optionsButton.topAnchor, constant: 7),
            optionsContentStack.bottomAnchor.constraint(equalTo: optionsButton.bottomAnchor, constant: -7),
            optionsContentStack.leadingAnchor.constraint(equalTo: optionsButton.leadingAnchor, constant: 14),
            optionsContentStack.trailingAnchor.constraint(equalTo: optionsButton.trailingAnchor, constant: -14),

            reactionsTop,
            dateTop
        ] + reactionsHorizontal)
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
        // La bulle doit avoir sa taille finale pour calculer son masque.
        contentView.layoutIfNeeded()
        ui_image_avatar.layer.cornerRadius = ui_image_avatar.bounds.height / 2
        updateBubbleMask()
    }

    /// Coins de la bulle selon sa position dans le groupe : côté expéditeur(trice), seuls le haut
    /// du premier message et le bas du dernier restent bien arrondis (EN-9558).
    private func updateBubbleMask() {
        let bounds = ui_view_label.bounds
        let senderTop = isFirstInGroup ? bubbleOuterRadius : bubbleInnerRadius
        let senderBottom = isLastInGroup ? bubbleOuterRadius : bubbleInnerRadius
        let outgoing = type(of: self).isOutgoingLayout

        CATransaction.begin()
        CATransaction.setDisableActions(true)
        bubbleMaskLayer.frame = bounds
        bubbleMaskLayer.path = roundedBubblePath(
            in: bounds,
            topLeft: outgoing ? bubbleOuterRadius : senderTop,
            topRight: outgoing ? senderTop : bubbleOuterRadius,
            bottomLeft: outgoing ? bubbleOuterRadius : senderBottom,
            bottomRight: outgoing ? senderBottom : bubbleOuterRadius
        ).cgPath
        CATransaction.commit()
    }

    private func roundedBubblePath(in rect: CGRect, topLeft: CGFloat, topRight: CGFloat, bottomLeft: CGFloat, bottomRight: CGFloat) -> UIBezierPath {
        let maxRadius = min(rect.width, rect.height) / 2
        let tl = min(topLeft, maxRadius), tr = min(topRight, maxRadius)
        let bl = min(bottomLeft, maxRadius), br = min(bottomRight, maxRadius)

        let path = UIBezierPath()
        path.move(to: CGPoint(x: rect.minX + tl, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.maxX - tr, y: rect.minY))
        path.addArc(withCenter: CGPoint(x: rect.maxX - tr, y: rect.minY + tr), radius: tr, startAngle: -.pi / 2, endAngle: 0, clockwise: true)
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY - br))
        path.addArc(withCenter: CGPoint(x: rect.maxX - br, y: rect.maxY - br), radius: br, startAngle: 0, endAngle: .pi / 2, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX + bl, y: rect.maxY))
        path.addArc(withCenter: CGPoint(x: rect.minX + bl, y: rect.maxY - bl), radius: bl, startAngle: .pi / 2, endAngle: .pi, clockwise: true)
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + tl))
        path.addArc(withCenter: CGPoint(x: rect.minX + tl, y: rect.minY + tl), radius: tl, startAngle: .pi, endAngle: 3 * .pi / 2, clockwise: true)
        path.close()
        return path
    }

    /// Espacements selon la position dans le groupe : bulles collées à l'intérieur d'un groupe,
    /// et les lignes réactions / heure ne prennent de place que lorsqu'elles sont affichées.
    private func applyGroupSpacing() {
        let hasReactionsRow = !reactionBadges.isHidden || !optionsButton.isHidden
        bubbleTopConstraint?.constant = isFirstInGroup ? groupOuterSpacing : groupInnerSpacing
        reactionsTopConstraint?.constant = hasReactionsRow ? 4 : 0
        dateTopConstraint?.constant = isLastInGroup ? 4 : 0
        bottomConstraint?.constant = isLastInGroup ? groupOuterSpacing : groupInnerSpacing
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        // Reset images
        ui_image_avatar.image = UIImage(named: "placeholder_user")
        ui_image_avatar.isHidden = false
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
        isFirstInGroup = true
        isLastInGroup = true
    }

    // MARK: - Configuration
    /// - Parameters:
    ///   - isFirstInGroup / isLastInGroup: position du message dans son groupe (même expéditeur(trice),
    ///     moins de 5 min d'écart) — EN-9558.
    ///   - showSenderName: `false` en tête-à-tête (le nom figure déjà dans le header).
    func configure(with message: PostMessage, isMe: Bool, isFirstInGroup: Bool = true, isLastInGroup: Bool = true, showSenderName: Bool = true, positionForRetry: Int = 0) {
        currentMessage = message
        currentPositionForRetry = positionForRetry
        currentIsMe = isMe
        self.isFirstInGroup = isFirstInGroup
        self.isLastInGroup = isLastInGroup
        mentionLinkMap.removeAll()

        // Pas de réaction possible sur son propre message : seul l'appui long reste disponible
        // pour accéder aux options (Copier/Modifier/Supprimer), le bouton "Réagir" est masqué.
        // Sur les messages reçus, "Réagir" reste affiché sous chaque message, même groupé.
        optionsButton.isHidden = isMe

        reactionBadges.configure(reactions: message.reactions, types: ReactionType.stored())
        // Aligné avec Android : dès qu'une réaction existe déjà (reactionBadges visible), le
        // bouton ne garde que l'icône, le texte "Réagir" n'a plus lieu d'être.
        optionsLabel.isHidden = !reactionBadges.isHidden

        // Avatar : jamais affiché pour ses propres messages, et une seule fois par groupe pour
        // l'interlocuteur(trice), à côté du dernier message (EN-9558). Masqué ≠ retiré : la place
        // reste réservée pour garder les bulles du groupe alignées.
        if isMe || !isLastInGroup {
            ui_image_avatar.isHidden = true
        } else {
            ui_image_avatar.isHidden = false
            if let urlStr = message.user?.avatarURL, let url = URL(string: urlStr) {
                ui_image_avatar.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
            } else {
                ui_image_avatar.image = UIImage(named: "placeholder_user")
            }
        }

        // Contenu / statut
        if let status = message.status?.lowercased() {
            switch status {
            case "deleted":
                applyDeletedStyle(text: NSLocalizedString("deleted_message", comment: ""))
            case "offensive", "offensible":
                applyDeletedStyle(text: NSLocalizedString("content_removed", comment: ""))
            default:
                applyNormalContent(message: message, isMe: isMe)
            }
        } else {
            applyNormalContent(message: message, isMe: isMe)
        }

        // Heure une seule fois par groupe, sous le dernier message. Le nom n'y est ajouté qu'en
        // discussion de groupe / événement / bonnes ondes, et jamais sur ses propres messages — EN-9558
        ui_label_date.text = isLastInGroup
            ? formattedNameAndTime(from: message, showName: showSenderName && !isMe)
            : nil
        applyGroupSpacing()

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

        // Force un passage de layout complet (pas seulement celui d'une éventuelle vue déjà
        // marquée dirty) : une cellule réutilisée dont le contenu des réactions change après
        // un premier affichage (ex : réaction reçue en direct) a sinon pu garder une hauteur
        // de ligne obsolète.
        setNeedsLayout()
        layoutIfNeeded()
    }

    // MARK: - Gestures
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began else { return }
        presentOverlay()
    }

    @objc private func handleOptionsTap() {
        presentOverlay()
    }

    private func presentOverlay() {
        guard let msg = currentMessage else { return }
        let textString = (msg.contentHtml?.isEmpty == false ? msg.contentHtml : msg.content) ?? ""
        delegate?.presentMessageOptions(anchorView: ui_view_label, message: msg, textString: textString, isMe: currentIsMe)
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
        // Reçu : pêche clair / texte anthracite ; envoyé : orange / texte blanc (EN-9558).
        let isAuto = message.messageType == "auto"
        let isOutgoingBubble = isMe && !isAuto
        if isAuto {
            ui_view_label.backgroundColor = UIColor.appBleuAuto
        } else {
            ui_view_label.backgroundColor = isMe ? UIColor.appMessageSentBubble : UIColor.appMessageReceivedBubble
        }

        let linkColor: UIColor = isOutgoingBubble ? .white : unifiedBlue
        ui_label_comment.textColor = isOutgoingBubble ? .white : .appAnthracite
        ui_label_comment.URLColor = linkColor
        ui_label_comment.hashtagColor = linkColor
        ui_label_comment.mentionColor = linkColor
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
    private func formattedNameAndTime(from message: PostMessage, showName: Bool) -> String {
        let nameOpt: String? = showName ? message.user?.displayName : nil
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
    override class var isOutgoingLayout: Bool { return true }
}

class ConversationOtherCell: ConversationViewCell {
    static let identifier = "cellOtherWithImage"
}

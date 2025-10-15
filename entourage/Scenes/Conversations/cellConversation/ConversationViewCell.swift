import UIKit
import SDWebImage

private let unifiedBlue = UIColor(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0)
private let conversationBaseFont: UIFont = UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
private let deletedBackgroundColor = UIColor.appPaleGrey
private let deletedTextColor = UIColor(named: "appGreyTextDeleted") ?? UIColor.darkGray


class ConversationViewCell: UITableViewCell, UITextViewDelegate {

    // MARK: - IBOutlets
    @IBOutlet weak var ui_image_avatar: UIImageView!
    @IBOutlet weak var ui_image_comment: UIImageView!
    @IBOutlet weak var ui_constraint_image_height: NSLayoutConstraint!   // contrainte IB déjà en place
    @IBOutlet weak var ui_label_comment: UILabel!                        // conservé, masqué
    @IBOutlet weak var ui_label_date: UILabel!
    @IBOutlet weak var ui_view_label: UIView!                            // bulle texte
    @IBOutlet weak var ui_label_min_width: NSLayoutConstraint?

    /// 🔴 Branche cette contrainte IB: Top de la bulle vers contentView (celle qui te “bloquait”)
    @IBOutlet weak var ui_label_top_to_content: NSLayoutConstraint!

    // MARK: - Properties
    private var deletedImageView: UIImageView?
    weak var delegate: MessageCellSignalDelegate?
    private var currentMessage: PostMessage?
    private var currentPositionForRetry: Int = 0

    private var fixedLabelWidthConstraint: NSLayoutConstraint?
    private var imageWidthConstraint: NSLayoutConstraint?        // on garde largeur fixe (demi écran)

    // Contraintes ajoutées en code
    private var imageTopToContent: NSLayoutConstraint?           // image.top = content.top
    private var labelTopToImage: NSLayoutConstraint?             // label.top = image.bottom
    private var cellBottomToLabel: NSLayoutConstraint?           // content.bottom = label.bottom
    private var cellBottomToImage: NSLayoutConstraint?           // content.bottom = image.bottom (rarement utile)

    // TextView pour contenu avec liens
    private let linkTextView: UITextView = {
        let tv = UITextView()
        tv.translatesAutoresizingMaskIntoConstraints = false
        tv.isEditable = false
        tv.isScrollEnabled = false
        tv.isSelectable = true
        tv.backgroundColor = .clear
        tv.textContainerInset = .zero
        tv.textContainer.lineFragmentPadding = 0
        tv.dataDetectorTypes = [.link, .phoneNumber]
        return tv
    }()

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        // Avatar
        ui_image_avatar.layer.masksToBounds = true
        ui_image_avatar.clipsToBounds = true

        // Image
        ui_image_comment.contentMode = .scaleAspectFill
        ui_image_comment.clipsToBounds = true
        ui_image_comment.isUserInteractionEnabled = true

        // Fonts
        ui_label_date.setFontBody(size: 12)
        ui_label_comment.setFontBody(size: 15)
        ui_label_comment.isHidden = true

        // Icône "supprimé"
        if let img = UIImage(named: "ic_deleted_comment") {
            let iv = UIImageView(image: img.withRenderingMode(.alwaysTemplate))
            iv.tintColor = deletedTextColor
            iv.translatesAutoresizingMaskIntoConstraints = false
            deletedImageView = iv
        }

        // Largeur fixe de la bulle ≈ moitié d’écran
        ui_view_label.translatesAutoresizingMaskIntoConstraints = false
        if fixedLabelWidthConstraint == nil {
            let screenWidth = UIScreen.main.bounds.width
            let halfWidth = (screenWidth / 2) - 30
            fixedLabelWidthConstraint = ui_view_label.widthAnchor.constraint(equalToConstant: halfWidth)
            fixedLabelWidthConstraint?.isActive = true
        }

        // Long press sur la bulle
        ui_view_label.isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        ui_view_label.addGestureRecognizer(longPressGesture)

        // Tap sur l'image
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        ui_image_comment.addGestureRecognizer(tapGesture)

        // TextView dans la bulle
        ui_view_label.addSubview(linkTextView)
        NSLayoutConstraint.activate([
            linkTextView.topAnchor.constraint(equalTo: ui_view_label.topAnchor, constant: 8),
            linkTextView.leadingAnchor.constraint(equalTo: ui_view_label.leadingAnchor, constant: 12),
            linkTextView.trailingAnchor.constraint(equalTo: ui_view_label.trailingAnchor, constant: -12),
            linkTextView.bottomAnchor.constraint(equalTo: ui_view_label.bottomAnchor, constant: -8)
        ])
        linkTextView.delegate = self
        linkTextView.linkTextAttributes = [
            .foregroundColor: unifiedBlue,
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]

        // Contraintes “scénario image”
        imageTopToContent = ui_image_comment.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8)
        labelTopToImage    = ui_view_label.topAnchor.constraint(equalTo: ui_image_comment.bottomAnchor, constant: 8)
        cellBottomToLabel  = contentView.bottomAnchor.constraint(equalTo: ui_view_label.bottomAnchor, constant: 8)
        cellBottomToImage  = contentView.bottomAnchor.constraint(equalTo: ui_image_comment.bottomAnchor, constant: 8)

        // État par défaut = SANS image
        imageTopToContent?.isActive = false
        labelTopToImage?.isActive   = false
        ui_label_top_to_content?.isActive = true
        cellBottomToImage?.isActive = false
        cellBottomToLabel?.isActive = true
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ui_image_avatar.layer.cornerRadius = ui_image_avatar.bounds.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()

        ui_image_avatar.image = UIImage(named: "placeholder_user")
        ui_image_comment.image = nil

        // reset image sizing
        ui_constraint_image_height.constant = 0
        imageWidthConstraint?.isActive = false
        imageWidthConstraint = nil

        // reset texte
        ui_label_comment.text = nil
        ui_label_comment.attributedText = nil
        ui_label_comment.textColor = .black
        ui_label_comment.font = conversationBaseFont
        linkTextView.attributedText = nil
        linkTextView.text = nil
        linkTextView.isSelectable = true

        // reset divers
        ui_label_date.text = nil
        ui_view_label.backgroundColor = .clear
        deletedImageView?.removeFromSuperview()
        ui_label_min_width?.isActive = false
        delegate = nil
        currentMessage = nil
        currentPositionForRetry = 0

        // 🔁 Revenir au scénario “sans image”
        imageTopToContent?.isActive = false
        labelTopToImage?.isActive   = false
        ui_label_top_to_content?.isActive = true
        cellBottomToImage?.isActive = false
        cellBottomToLabel?.isActive = true
    }

    // MARK: - Configuration
    func configure(with message: PostMessage, isMe: Bool, positionForRetry: Int = 0) {
        currentMessage = message
        currentPositionForRetry = positionForRetry

        // Avatar
        if let urlStr = message.user?.avatarURL, let url = URL(string: urlStr) {
            ui_image_avatar.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image_avatar.image = UIImage(named: "placeholder_user")
        }

        // Contenu
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

        // Nom + heure
        ui_label_date.text = formattedNameAndTime(from: message)

        // ----- Image attachée -----
        if let imgUrl = message.messageImageUrl, let url = URL(string: imgUrl) {
            ui_image_comment.sd_setImage(with: url, placeholderImage: nil)

            // Taille (carré ~ moitié d’écran)
            let maxImageSize = (UIScreen.main.bounds.width / 2) - 40
            ui_constraint_image_height.constant = maxImageSize

            imageWidthConstraint = ui_image_comment.widthAnchor.constraint(equalToConstant: maxImageSize)
            imageWidthConstraint?.isActive = true

            ui_label_min_width?.constant = maxImageSize
            ui_label_min_width?.isActive = true

            // 🔁 Bascule contraintes : image au top, bulle sous l’image
            ui_label_top_to_content?.isActive = false
            imageTopToContent?.isActive = true
            labelTopToImage?.isActive = true

            cellBottomToImage?.isActive = false
            cellBottomToLabel?.isActive = true
        } else {
            // Pas d’image → bulle en haut
            ui_image_comment.image = nil
            ui_constraint_image_height.constant = 0

            imageWidthConstraint?.isActive = false
            imageWidthConstraint = nil

            ui_label_min_width?.isActive = false

            // 🔁 Contraintes “sans image”
            imageTopToContent?.isActive = false
            labelTopToImage?.isActive   = false
            ui_label_top_to_content?.isActive = true

            cellBottomToImage?.isActive = false
            cellBottomToLabel?.isActive = true
        }

        layoutIfNeeded()
    }

    // MARK: - Gestures
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let msg = currentMessage else { return }
        delegate?.signalMessage(
            messageId: msg.uid,
            userId: msg.user?.sid ?? 0,
            textString: (msg.contentHtml?.isEmpty == false ? msg.contentHtml : msg.content) ?? ""
        )
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
        linkTextView.isSelectable = false
        linkTextView.attributedText = NSAttributedString(
            string: "  " + text,
            attributes: [
                .font: conversationBaseFont,
                .foregroundColor: deletedTextColor
            ])
        if let icon = deletedImageView {
            ui_view_label.addSubview(icon)
            NSLayoutConstraint.activate([
                icon.leadingAnchor.constraint(equalTo: ui_view_label.leadingAnchor, constant: 8),
                icon.centerYAnchor.constraint(equalTo: ui_view_label.centerYAnchor),
                icon.widthAnchor.constraint(equalToConstant: 16),
                icon.heightAnchor.constraint(equalToConstant: 16)
            ])
        }
    }

    private func applyNormalContent(message: PostMessage, isMe: Bool) {
        ui_view_label.backgroundColor = isMe ? UIColor.appBeige : UIColor.orangeMedium
        if message.messageType == "auto" {
            ui_view_label.backgroundColor = UIColor.appBleuAuto
        }
        linkTextView.isSelectable = true

        if let html = message.contentHtml, !html.isEmpty {
            linkTextView.attributedText = attributedString(fromHTML: html)
        } else if let content = message.content, !content.isEmpty {
            linkTextView.attributedText = detectLinks(in: content.trimmingCharacters(in: .whitespacesAndNewlines))
        } else {
            linkTextView.text = ""
        }
    }

    // MARK: - Name + Time
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

    // MARK: - HTML ➜ Attributed
    private func attributedString(fromHTML html: String) -> NSAttributedString {
        let replaced = html.replacingOccurrences(of: "\n", with: "<br>")
        guard let data = replaced.data(using: .utf8) else {
            return NSAttributedString(string: html, attributes: [
                .font: conversationBaseFont,
                .foregroundColor: UIColor.black
            ])
        }
        let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
            .documentType: NSAttributedString.DocumentType.html,
            .characterEncoding: String.Encoding.utf8.rawValue
        ]
        do {
            let attr = try NSMutableAttributedString(data: data, options: options, documentAttributes: nil)
            let full = NSRange(location: 0, length: attr.length)
            attr.removeAttribute(.foregroundColor, range: full)
            attr.removeAttribute(.underlineStyle, range: full)
            attr.addAttributes([
                .font: conversationBaseFont,
                .foregroundColor: UIColor.black
            ], range: full)
            attr.enumerateAttribute(.link, in: full, options: []) { value, range, _ in
                if value != nil {
                    attr.addAttributes([
                        .foregroundColor: unifiedBlue,
                        .underlineStyle: NSUnderlineStyle.single.rawValue
                    ], range: range)
                }
            }
            while attr.string.hasSuffix("\n") || attr.string.hasSuffix(" ") {
                attr.deleteCharacters(in: NSRange(location: attr.length - 1, length: 1))
            }
            return attr
        } catch {
            return NSAttributedString(string: html, attributes: [
                .font: conversationBaseFont,
                .foregroundColor: UIColor.black
            ])
        }
    }

    // MARK: - Détection d’URL
    private func detectLinks(in text: String) -> NSAttributedString {
        let attr = NSMutableAttributedString(string: text, attributes: [
            .font: conversationBaseFont,
            .foregroundColor: UIColor.black
        ])
        if let detector = try? NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue) {
            let range = NSRange(location: 0, length: (text as NSString).length)
            detector.matches(in: text, options: [], range: range).forEach { match in
                guard let url = match.url else { return }
                attr.addAttributes([
                    .link: url,
                    .foregroundColor: unifiedBlue,
                    .underlineStyle: NSUnderlineStyle.single.rawValue
                ], range: match.range)
            }
        }
        return attr
    }

    // MARK: - UITextViewDelegate
    func textView(_ textView: UITextView,
                  shouldInteractWith url: URL,
                  in characterRange: NSRange,
                  interaction: UITextItemInteraction) -> Bool {
        delegate?.showWebUrl(url: url)
        return false
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

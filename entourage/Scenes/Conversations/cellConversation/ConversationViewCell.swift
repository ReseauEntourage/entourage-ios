import UIKit
import SDWebImage

private let unifiedBlue = UIColor(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0)
private let conversationBaseFont: UIFont = UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)
private let deletedBackgroundColor = UIColor.appPaleGrey
private let deletedTextColor = UIColor(named: "appGreyTextDeleted") ?? UIColor.darkGray

class ConversationViewCell: UITableViewCell {

    // MARK: - IBOutlets
    @IBOutlet weak var ui_image_avatar: UIImageView!
    @IBOutlet weak var ui_image_comment: UIImageView!
    @IBOutlet weak var ui_constraint_image_height: NSLayoutConstraint!
    @IBOutlet weak var ui_label_comment: UILabel!
    @IBOutlet weak var ui_label_date: UILabel!     // -> contiendra "Nom • HH:mm"
    @IBOutlet weak var ui_view_label: UIView!
    @IBOutlet weak var ui_label_min_width: NSLayoutConstraint?

    // MARK: - Properties
    private var deletedImageView: UIImageView?
    weak var delegate: MessageCellSignalDelegate?
    private var currentMessage: PostMessage?
    private var currentPositionForRetry: Int = 0

    private var fixedLabelWidthConstraint: NSLayoutConstraint?
    private var imageWidthConstraint: NSLayoutConstraint?
    private var imageAspectConstraint: NSLayoutConstraint?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        // Avatar styling
        ui_image_avatar.layer.masksToBounds = true
        ui_image_avatar.clipsToBounds = true

        // Message image
        ui_image_comment.contentMode = .scaleAspectFill
        ui_image_comment.clipsToBounds = true
        ui_image_comment.translatesAutoresizingMaskIntoConstraints = false
        ui_image_comment.isUserInteractionEnabled = true

        // Fonts
        ui_label_date.setFontBody(size: 12)
        ui_label_comment.setFontBody(size: 15)

        // Deleted icon template
        if let img = UIImage(named: "ic_deleted_comment") {
            let iv = UIImageView(image: img.withRenderingMode(.alwaysTemplate))
            iv.tintColor = deletedTextColor
            iv.translatesAutoresizingMaskIntoConstraints = false
            deletedImageView = iv
        }

        // No min width by default
        ui_label_min_width?.isActive = false

        // Fixe la largeur de la vue de texte à ~ la moitié de l’écran
        ui_view_label.translatesAutoresizingMaskIntoConstraints = false
        if fixedLabelWidthConstraint == nil {
            let screenWidth = UIScreen.main.bounds.width
            let halfWidth = (screenWidth / 2) - 30 // marges latérales
            fixedLabelWidthConstraint = ui_view_label.widthAnchor.constraint(equalToConstant: halfWidth)
            fixedLabelWidthConstraint?.isActive = true
        }

        // Gestures
        ui_view_label.isUserInteractionEnabled = true
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        longPressGesture.minimumPressDuration = 0.5
        ui_view_label.addGestureRecognizer(longPressGesture)

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageTap(_:)))
        ui_image_comment.addGestureRecognizer(tapGesture)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ui_image_avatar.layer.cornerRadius = ui_image_avatar.bounds.height / 2
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ui_image_avatar.image = UIImage(named: "placeholder_user")
        ui_image_comment.image = nil
        ui_constraint_image_height.constant = 0
        ui_label_comment.text = nil
        ui_label_comment.attributedText = nil
        ui_label_comment.textColor = .black
        ui_label_comment.font = conversationBaseFont
        ui_label_date.text = nil
        ui_view_label.backgroundColor = .clear
        deletedImageView?.removeFromSuperview()
        ui_label_min_width?.isActive = false
        delegate = nil
        currentMessage = nil
        currentPositionForRetry = 0

        imageWidthConstraint?.isActive = false
        imageAspectConstraint?.isActive = false
        imageWidthConstraint = nil
        imageAspectConstraint = nil
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

        // Nom + heure (ex: "Marine • 14:21")
        ui_label_date.text = formattedNameAndTime(from: message)

        // Image attachée
        if let imgUrl = message.messageImageUrl, let url = URL(string: imgUrl) {
            ui_image_comment.sd_setImage(with: url, placeholderImage: nil)

            let maxImageSize = (UIScreen.main.bounds.width / 2) - 40 // marges + padding

            ui_constraint_image_height.constant = maxImageSize

            imageWidthConstraint = ui_image_comment.widthAnchor.constraint(equalToConstant: maxImageSize)
            imageAspectConstraint = ui_image_comment.heightAnchor.constraint(equalTo: ui_image_comment.widthAnchor)

            imageWidthConstraint?.isActive = true
            imageAspectConstraint?.isActive = true

            ui_label_min_width?.constant = maxImageSize
            ui_label_min_width?.isActive = true
        } else {
            ui_image_comment.image = nil
            ui_constraint_image_height.constant = 0
            ui_label_min_width?.isActive = false

            imageWidthConstraint?.isActive = false
            imageAspectConstraint?.isActive = false
            imageWidthConstraint = nil
            imageAspectConstraint = nil
        }

        layoutIfNeeded()
    }

    // MARK: - Gesture Handlers
    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began, let msg = currentMessage else { return }
        delegate?.signalMessage(
            messageId: msg.uid,
            userId: msg.user?.sid ?? 0,
            textString: msg.content ?? ""
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
        ui_label_comment.text = "  " + text
        ui_label_comment.font = conversationBaseFont
        ui_label_comment.textColor = deletedTextColor
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

        if let html = message.contentHtml, !html.isEmpty {
            ui_label_comment.attributedText = attributedString(fromHTML: html)
        } else if let content = message.content, !content.isEmpty {
            ui_label_comment.text = content.trimmingCharacters(in: .whitespacesAndNewlines)
            ui_label_comment.font = conversationBaseFont
            ui_label_comment.textColor = .black
        } else {
            ui_label_comment.text = ""
        }
    }

    // MARK: - Name + Time (sans createdAt/createdAtDate)
    private func formattedNameAndTime(from message: PostMessage) -> String {
        // user?.displayName est possiblement non-optionnel dans le type -> ne mets PAS "?."
        let nameOpt: String? = message.user?.displayName
        let trimmedName = nameOpt?.trimmingCharacters(in: .whitespacesAndNewlines)

        // 1) On tente le Date directement
        if let d = message.createdDate {
            let time = hourFormatter.string(from: d)
            switch (trimmedName?.isEmpty == false) {
            case true:  return "\(trimmedName!) • \(time)"
            case false: return time
            }
        }

        // 2) Fallback: formatage déjà fourni par le modèle
        let fallbackTime = message.createdTimeFormatted.trimmingCharacters(in: .whitespacesAndNewlines)
        if !fallbackTime.isEmpty {
            if let n = trimmedName, !n.isEmpty {
                return "\(n) • \(fallbackTime)"
            } else {
                return fallbackTime
            }
        }

        // 3) Dernier recours : createdDateString (texte brut du backend)
        let raw = message.createdDateString
        if !raw.isEmpty {
            if let n = trimmedName, !n.isEmpty {
                return "\(n) • \(raw)"
            } else {
                return raw
            }
        }

        // Rien
        return trimmedName ?? ""
    }

    // MARK: - HTML to AttributedString
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

    // MARK: - Formatters
    private lazy var hourFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm"
        f.locale = Locale.current
        f.timeZone = .current // Europe/Paris
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

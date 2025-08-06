import UIKit
import SDWebImage

// Couleur bleue pour les liens
private let unifiedBlue = UIColor(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0)

// Police de base pour les messages
private let conversationBaseFont: UIFont = UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)

// Couleurs pour statut supprimé/offensif
private let deletedBackgroundColor = UIColor.appPaleGrey
private let deletedTextColor = UIColor(named: "appGreyTextDeleted") ?? UIColor.darkGray


class ConversationViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var ui_image_avatar: UIImageView!
    @IBOutlet weak var ui_image_comment: UIImageView!
    @IBOutlet weak var ui_constraint_image_height: NSLayoutConstraint!
    @IBOutlet weak var ui_label_comment: UILabel!
    @IBOutlet weak var ui_label_date: UILabel!
    @IBOutlet weak var ui_view_label: UIView!
    @IBOutlet weak var ui_label_min_width: NSLayoutConstraint?

    // Status icon
    private var deletedImageView: UIImageView?

    // For reporting via long press
    weak var delegate: MessageCellSignalDelegate?
    private var currentMessage: PostMessage?
    private var currentPositionForRetry: Int = 0

    override func awakeFromNib() {
        super.awakeFromNib()
        // Avatar styling
        ui_image_avatar.layer.cornerRadius = ui_image_avatar.frame.height / 2
        ui_image_avatar.clipsToBounds = true

        // Image content mode
        ui_image_comment.contentMode = .scaleAspectFill
        ui_image_comment.clipsToBounds = true

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

        // By default, no min-width
        ui_label_min_width?.isActive = false

        // Add long-press for reporting on the message container
        ui_view_label.isUserInteractionEnabled = true
        let lp = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress(_:)))
        lp.minimumPressDuration = 0.5
        ui_view_label.addGestureRecognizer(lp)
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
    }

    /// Configure cell with message, and inform delegate on long press
    func configure(with message: PostMessage, isMe: Bool, positionForRetry: Int = 0) {
        currentMessage = message
        currentPositionForRetry = positionForRetry

        // Avatar
        if let urlStr = message.user?.avatarURL, let url = URL(string: urlStr) {
            ui_image_avatar.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image_avatar.image = UIImage(named: "placeholder_user")
        }

        // Content or status
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

        // Date
        ui_label_date.text = message.createdDateTimeFormatted

        // Attached image
        if let imgUrl = message.messageImageUrl, let url = URL(string: imgUrl) {
            ui_image_comment.sd_setImage(with: url, placeholderImage: nil)
            ui_constraint_image_height.constant = 120
            ui_label_min_width?.constant = UIScreen.main.bounds.width / 2
            ui_label_min_width?.isActive = true
        } else {
            ui_image_comment.image = nil
            ui_constraint_image_height.constant = 0
            ui_label_min_width?.isActive = false
        }

        layoutIfNeeded()
    }

    // MARK: - Long Press Handler

    @objc private func handleLongPress(_ gesture: UILongPressGestureRecognizer) {
        guard gesture.state == .began,
              let msg = currentMessage else { return }

        // Delegate the signal action
        delegate?.signalMessage(
            messageId: msg.uid,
            userId: msg.user?.sid ?? 0,
            textString: msg.content ?? ""
        )
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
        ui_view_label.backgroundColor = isMe ? UIColor.appBeige : UIColor.appBeigeClair
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
}

class ConversationMeCell: ConversationViewCell {
    static let identifier = "cellMeWithImage"
}

class ConversationOtherCell: ConversationViewCell {
    static let identifier = "cellOtherWithImage"
}

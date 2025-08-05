import UIKit
import SDWebImage

// Couleur bleue pour les liens
private let unifiedBlue = UIColor(red: 0.0, green: 122/255.0, blue: 1.0, alpha: 1.0)

// Police de base pour les messages
private let conversationBaseFont: UIFont = UIFont(name: "NunitoSans-Regular", size: 15) ?? UIFont.systemFont(ofSize: 15)

// Couleurs pour statut supprimé/offensif
private let deletedBackgroundColor = UIColor(named: "appGreyCellDeleted") ?? UIColor.lightGray
private let deletedTextColor = UIColor(named: "appGreyTextDeleted") ?? UIColor.darkGray

class ConversationViewCell: UITableViewCell {

    // MARK: - Outlets
    @IBOutlet weak var ui_image_avatar: UIImageView!
    @IBOutlet weak var ui_image_comment: UIImageView!
    @IBOutlet weak var ui_constraint_image_height: NSLayoutConstraint!
    @IBOutlet weak var ui_label_comment: UILabel!
    @IBOutlet weak var ui_label_date: UILabel!
    @IBOutlet weak var ui_view_label: UIView!
    @IBOutlet weak var ui_label_min_width: NSLayoutConstraint!

    // Image de statut pour deleted/offensive
    private var deletedImageView: UIImageView?

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_image_avatar.layer.cornerRadius = ui_image_avatar.frame.height / 2
        ui_image_avatar.clipsToBounds = true
        ui_image_comment.contentMode = .scaleAspectFill
        ui_image_comment.clipsToBounds = true
        self.ui_label_date.setFontBody(size: 12)

        self.ui_label_comment.setFontBody(size: 15)
        if let img = UIImage(named: "ic_deleted_comment") {
            let imageView = UIImageView(image: img.withRenderingMode(.alwaysTemplate))
            imageView.tintColor = deletedTextColor
            imageView.translatesAutoresizingMaskIntoConstraints = false
            deletedImageView = imageView
        }
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
    }

    func configure(with message: PostMessage, isMe: Bool) {
        // Avatar
        if let urlStr = message.user?.avatarURL, let url = URL(string: urlStr) {
            ui_image_avatar.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image_avatar.image = UIImage(named: "placeholder_user")
        }

        // Contenu
        if let status = message.status {
            switch status.lowercased() {
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

        // Image jointe
        if let imgUrl = message.messageImageUrl, let url = URL(string: imgUrl) {
            ui_image_comment.sd_setImage(with: url, placeholderImage: nil)
            ui_constraint_image_height.constant = 120
            // Ajoutez la contrainte de largeur minimale du label égale à la moitié de l'écran
            ui_label_min_width.constant = UIScreen.main.bounds.width / 2
        } else {
            ui_image_comment.image = nil
            ui_constraint_image_height.constant = 0
            // Désactivez la contrainte de largeur minimale du label
            ui_label_min_width.constant = 0
        }

        layoutIfNeeded()
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
            return NSAttributedString(string: html, attributes: [.font: conversationBaseFont, .foregroundColor: UIColor.black])
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
            attr.addAttributes([.font: conversationBaseFont, .foregroundColor: UIColor.black], range: full)
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
            return NSAttributedString(string: html, attributes: [.font: conversationBaseFont, .foregroundColor: UIColor.black])
        }
    }
}

class ConversationMeCell: ConversationViewCell {
    static let identifier = "cellMeWithImage"
}

class ConversationOtherCell: ConversationViewCell {
    static let identifier = "cellOtherWithImage"
}

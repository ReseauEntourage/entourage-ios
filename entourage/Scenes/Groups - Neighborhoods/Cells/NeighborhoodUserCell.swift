import UIKit
import SDWebImage

protocol NeighborhoodUserCellDelegate: AnyObject {
    func showSendMessageToUserForPosition(_ position: Int)
    func neighborhoodUserCell(_ cell: NeighborhoodUserCell, didToggleAt position: Int, isChecked: Bool, completion: @escaping (Bool) -> Void)
}

class NeighborhoodUserCell: UITableViewCell {

    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_username: UILabel!
    @IBOutlet weak var ui_role: UILabel!
    @IBOutlet weak var ui_view_separator: UIView!
    @IBOutlet weak var ui_view_background: UIView!
    @IBOutlet weak var checkbox: Checkbox!
    @IBOutlet weak var ui_sending_button_width: NSLayoutConstraint!
    @IBOutlet weak var ic_image_reaction: UIImageView!
    @IBOutlet weak var ui_bt_message: UIButton!
    @IBOutlet weak var ui_picto_message: UIImageView!
    @IBOutlet weak var ui_view: UIView!

    var position: Int = 0
    weak var delegate: NeighborhoodUserCellDelegate?

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_image.layer.masksToBounds = true
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
        ui_username.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_role.font = ApplicationTheme.getFontNunitoRegular(size: 11)
        ui_role.textColor = .appOrangeLight

        if let ui_view = ui_view {
            ui_view.layer.cornerRadius = ui_view.frame.height / 2
            ui_view.clipsToBounds = true
            ui_view.layer.borderWidth = 1
            ui_view.layer.borderColor = UIColor(named: "grey_reaction")?.cgColor
        }

        // Écoute le changement d'état de la checkbox
        checkbox.addTarget(self, action: #selector(onCheckboxTapped), for: .valueChanged)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
        if let ui_view = ui_view {
            ui_view.layer.cornerRadius = ui_view.frame.height / 2
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        ui_username.text = nil
        ui_username.attributedText = nil
        ui_role.text = nil
        ui_role.isHidden = false
        ui_view_background?.backgroundColor = .clear
        ic_image_reaction?.isHidden = true
        ui_view?.isHidden = true
        checkbox.isHidden = true
        checkbox.isChecked = false
        ui_bt_message.isHidden = true
        ui_picto_message.isHidden = true
        ui_sending_button_width?.constant = 0
        ui_image.image = UIImage(named: "placeholder_user")
    }

    func hideSeparatorBarIfIsVote(isVote: Bool) {
        ui_view_separator?.isHidden = isVote
    }

    func populateCell(isMe: Bool, username: String, role: String?, imageUrl: String?, showBtMessage: Bool, delegate: NeighborhoodUserCellDelegate, position: Int, reactionType: ReactionType?, isConfirmed: Bool?, isOrganizer: Bool?, isCreator: Bool?) {
        self.delegate = delegate
        self.position = position

        ui_username.text = username
        ui_view_background?.backgroundColor = .clear

        if let r = role, !r.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ui_role.text = r
            ui_role.isHidden = false
        } else {
            ui_role.text = nil
            ui_role.isHidden = true
        }

        if isConfirmed ?? false {
            ui_username.text = "\(username) - Participation confirmée"
        }

        if let imageUrl = imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image.image = UIImage(named: "placeholder_user")
        }

        if let ic = ic_image_reaction {
            if let reactionId = reactionType?.id,
               let completeReactionType = getStoredReactionTypes()?.first(where: { $0.id == reactionId }),
               let urlStr = completeReactionType.imageUrl,
               let url = URL(string: urlStr) {
                ic.isHidden = false
                ui_view?.isHidden = false
                ic.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_i_like"))
            } else {
                ic.isHidden = true
                ui_view?.isHidden = true
            }
        }

        let viewerCanShowCheckboxes = AppSignableManager.shared.signableEvent && AppSignableManager.shared.signablePermission
        let checkboxVisible = viewerCanShowCheckboxes && !isMe
        let messageVisible = !checkboxVisible && showBtMessage && !isMe

        checkbox.isHidden = !checkboxVisible
        checkbox.isChecked = isConfirmed ?? false
        ui_bt_message.isHidden = !messageVisible
        ui_picto_message.isHidden = !messageVisible
        ui_sending_button_width?.constant = messageVisible ? 40 : 0
        contentView.layoutIfNeeded()
    }

    @objc private func onCheckboxTapped(_ sender: Checkbox) {
        let newState = !sender.isChecked
        delegate?.neighborhoodUserCell(self, didToggleAt: position, isChecked: newState, completion: { [weak sender] keep in
            sender?.isChecked = keep ? newState : !newState
        })
    }

    @IBAction func action_send_message(_ sender: Any) {
        delegate?.showSendMessageToUserForPosition(position)
    }

    private func getStoredReactionTypes() -> [ReactionType]? {
        guard let reactionsData = UserDefaults.standard.data(forKey: "StoredReactions") else { return nil }
        do {
            return try JSONDecoder().decode([ReactionType].self, from: reactionsData)
        } catch {
            print("Erreur de décodage des réactions : \(error)")
            return nil
        }
    }
}

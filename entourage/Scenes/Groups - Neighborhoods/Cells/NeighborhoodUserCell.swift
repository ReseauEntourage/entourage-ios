import UIKit
import SDWebImage

protocol NeighborhoodUserCellDelegate: AnyObject {
    func neighborhoodUserCell(_ cell: NeighborhoodUserCell,
                              didRequestToggleAt tablePosition: Int,
                              intendedChecked: Bool,
                              completion: @escaping (_ finalChecked: Bool) -> Void)

    func showSendMessageToUserForPosition(_ tablePosition: Int)
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

    private(set) var tablePosition: Int = 0
    weak var delegate: NeighborhoodUserCellDelegate?

    // empêche les .valueChanged lors des set programmatiques
    private var suppressChange = false

    override func awakeFromNib() {
        super.awakeFromNib()
        ui_image.layer.masksToBounds = true
        ui_username.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_role.font = ApplicationTheme.getFontNunitoRegular(size: 11)
        ui_role.textColor = .appOrangeLight

        // ⚠️ Tolérance au nil : certaines variantes de prototype peuvent ne pas câbler ui_view / checkbox
        ui_view?.clipsToBounds = true
        ui_view?.layer.borderWidth = 1
        ui_view?.layer.borderColor = UIColor(named: "grey_reaction")?.cgColor

        // Lire l'état réel (après bascule)
        checkbox?.addTarget(self, action: #selector(onCheckboxChanged), for: .valueChanged)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
        if let v = ui_view {
            v.layer.cornerRadius = v.frame.height / 2
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

        suppressChange = true
        checkbox?.isHidden = true
        checkbox?.isChecked = false
        suppressChange = false

        ui_bt_message.isHidden = true
        ui_picto_message.isHidden = true
        ui_sending_button_width?.constant = 0
        ui_image.image = UIImage(named: "placeholder_user")
        isUserInteractionEnabled = true
    }

    func hideSeparatorBarIfIsVote(isVote: Bool) {
        ui_view_separator?.isHidden = isVote
    }

    func populateCell(isMe: Bool,
                      username: String,
                      role: String?,
                      imageUrl: String?,
                      showBtMessage: Bool,
                      delegate: NeighborhoodUserCellDelegate,
                      position: Int,
                      reactionType: ReactionType?,
                      isConfirmed: Bool?,
                      isOrganizer: Bool?,
                      isCreator: Bool?) {

        self.delegate = delegate
        self.tablePosition = position

        ui_username.text = (isConfirmed ?? false) ? "\(username) - Participation confirmée" : username

        if let r = role, !r.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ui_role.text = r
            ui_role.isHidden = false
        } else {
            ui_role.text = nil
            ui_role.isHidden = true
        }

        if let urlStr = imageUrl, let url = URL(string: urlStr) {
            ui_image.sd_setImage(with: url, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image.image = UIImage(named: "placeholder_user")
        }

        if let reactionId = reactionType?.id,
           let completeReaction = getStoredReactionTypes()?.first(where: { $0.id == reactionId }),
           let imgUrl = completeReaction.imageUrl,
           let url = URL(string: imgUrl) {
            ic_image_reaction?.isHidden = false
            ui_view?.isHidden = false
            ic_image_reaction?.sd_setImage(with: url, placeholderImage: UIImage(named: "ic_i_like"))
        } else {
            ic_image_reaction?.isHidden = true
            ui_view?.isHidden = true
        }

        let canShowCheckbox = ((isOrganizer ?? false) && !isMe)
            && AppSignableManager.shared.signableEvent
            && AppSignableManager.shared.signablePermission
        let messageVisible = !canShowCheckbox && showBtMessage && !isMe

        checkbox?.isHidden = !canShowCheckbox

        // désactive l’événement pendant la mise à jour UI
        suppressChange = true
        checkbox?.isChecked = isConfirmed ?? false
        suppressChange = false

        ui_bt_message.isHidden = !messageVisible
        ui_picto_message.isHidden = !messageVisible
        ui_sending_button_width?.constant = messageVisible ? 40 : 0

        contentView.layoutIfNeeded()
    }

    @objc private func onCheckboxChanged(_ sender: Checkbox) {
        if suppressChange { return }
        // état réel après le tap :
        let intended = sender.isChecked

        // bloque l’UI ; le VC réactivera via completion
        isUserInteractionEnabled = false

        delegate?.neighborhoodUserCell(self,
                                       didRequestToggleAt: tablePosition,
                                       intendedChecked: intended,
                                       completion: { [weak self] finalChecked in
            guard let self = self else { return }
            self.suppressChange = true
            self.checkbox?.isChecked = finalChecked
            self.suppressChange = false
            self.isUserInteractionEnabled = true
        })
    }

    @IBAction func action_send_message(_ sender: Any) {
        delegate?.showSendMessageToUserForPosition(tablePosition)
    }

    private func getStoredReactionTypes() -> [ReactionType]? {
        guard let reactionsData = UserDefaults.standard.data(forKey: "StoredReactions") else { return nil }
        return try? JSONDecoder().decode([ReactionType].self, from: reactionsData)
    }
}

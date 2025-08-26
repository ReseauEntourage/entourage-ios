//
//  NeighborhoodUserCell.swift
//  entourage
//
//  Created by Jerome on 04/05/2022.
//

import UIKit
import SDWebImage

// MARK: - Protocol
protocol NeighborhoodUserCellDelegate: AnyObject {
    func showSendMessageToUserForPosition(_ position: Int)

    /// Appelé à CHAQUE toggle de la checkbox, avec le NOUVEL état.
    /// - Parameters:
    ///   - position: index logique de la ligne (géré par le VC)
    ///   - isChecked: nouvel état (true si cochée)
    ///   - completion: renvoyer true pour garder l’état, false pour le rétablir
    func neighborhoodUserCell(_ cell: NeighborhoodUserCell,
                              didToggleAt position: Int,
                              isChecked: Bool,
                              completion: @escaping (Bool) -> Void)
}

class NeighborhoodUserCell: UITableViewCell {

    // MARK: - IBOutlets
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

    // MARK: - State
    var position = 0
    weak var delegate: NeighborhoodUserCellDelegate?

    // MARK: - Lifecycle
    override func awakeFromNib() {
        super.awakeFromNib()

        ui_image.layer.masksToBounds = true
        ui_image.layer.cornerRadius = ui_image.frame.height / 2

        ui_username.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_role.font = ApplicationTheme.getFontNunitoRegular(size: 11)
        ui_role.textColor = .appOrangeLight

        if ui_view != nil {
            ui_view.layer.cornerRadius = ui_view.frame.height / 2
            ui_view.clipsToBounds = true
            ui_view.layer.borderWidth = 1
            ui_view.layer.borderColor = UIColor(named: "grey_reaction")?.cgColor
        }

        // Écoute le tap sur la checkbox (toggle à chaque appui)
        checkbox?.addTarget(self, action: #selector(onCheckboxTapped(_:)), for: .touchUpInside)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
        if ui_view != nil {
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

        checkbox?.isHidden = true
        checkbox?.isChecked = false // éviter les artefacts de recyclage

        // Par défaut, on masque le bouton et on met la width à 0
        ui_bt_message.isHidden = true
        ui_picto_message.isHidden = true
        ui_sending_button_width?.constant = 0

        ui_image.image = UIImage(named: "placeholder_user")
    }

    // MARK: - Public
    func hideSeparatorBarIfIsVote(isVote: Bool) {
        if isVote {
            ui_view_separator?.isHidden = true
        }
    }

    /// - `isOrganizer` = le VIEWER peut voir/utiliser les checkboxes (rôle non nul côté user courant).
    func populateCell(isMe: Bool,
                      username: String,
                      role: String?,
                      imageUrl: String?,
                      showBtMessage: Bool,
                      delegate: NeighborhoodUserCellDelegate,
                      position: Int,
                      reactionType: ReactionType?,
                      isConfirmed: Bool?,
                      isOrganizer: Bool?,   // viewerCanUseCheckboxes
                      isCreator: Bool?) {
        self.delegate = delegate
        self.position = position

        // === Nom
        ui_username.text = username
        ui_view_background?.backgroundColor = .clear

        // === Rôle (sous-titre)
        if let r = role, !r.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            ui_role.text = r
            ui_role.isHidden = false
        } else {
            ui_role.text = nil
            ui_role.isHidden = true
        }

        // === Suffixe "Participation confirmée" (optionnel)
        if isConfirmed ?? false {
            ui_username.text = "\(username) - Participation confirmée"
        }

        // === Avatar
        if let imageUrl = imageUrl,
           !imageUrl.isEmpty,
           let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image.image = UIImage(named: "placeholder_user")
        }

        // === Réaction
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

        // === Checkbox & boutons message
        // - checkbox visible si le viewer a des rôles ET que la ligne n’est pas "moi"
        // - si checkbox visible => bouton message masqué
        let viewerCanShowCheckboxes = (isOrganizer ?? false)
        let checkboxVisible = viewerCanShowCheckboxes && !isMe
        let messageVisible = !checkboxVisible && showBtMessage && !isMe

        checkbox?.isHidden = !checkboxVisible

        // ✅ état initial : coché si participation confirmée (parité Android)
        if checkboxVisible {
            checkbox?.isChecked = (isConfirmed ?? false)
        } else {
            checkbox?.isChecked = false
        }

        ui_bt_message.isHidden = !messageVisible
        ui_picto_message.isHidden = !messageVisible
        ui_sending_button_width?.constant = messageVisible ? 40 : 0
        contentView.layoutIfNeeded()
    }

    // MARK: - Actions
    @objc private func onCheckboxTapped(_ sender: Checkbox) {
        // Selon l'implémentation de Checkbox, l'état peut basculer avant/après l'action.
        // On repousse à la prochaine boucle main pour lire l'état final garanti.
        DispatchQueue.main.async { [weak self, weak sender] in
            guard let self = self, let sender = sender else { return }
            let newState = sender.isChecked

            self.delegate?.neighborhoodUserCell(self,
                                                didToggleAt: self.position,
                                                isChecked: newState,
                                                completion: { keep in
                if !keep {
                    // Le VC refuse → rétablir visuellement l'état précédent
                    sender.isChecked = !newState
                }
            })
        }
    }

    @IBAction func action_send_message(_ sender: Any) {
        delegate?.showSendMessageToUserForPosition(position)
    }

    // MARK: - Helpers
    func getStoredReactionTypes() -> [ReactionType]? {
        guard let reactionsData = UserDefaults.standard.data(forKey: "StoredReactions") else { return nil }
        do {
            let reactions = try JSONDecoder().decode([ReactionType].self, from: reactionsData)
            return reactions
        } catch {
            print("Erreur de décodage des réactions : \(error)")
            return nil
        }
    }
}

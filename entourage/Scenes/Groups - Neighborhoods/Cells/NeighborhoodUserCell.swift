//
//  NeighborhoodUserCell.swift
//  entourage
//
//  Created by Jerome on 04/05/2022.
//

import UIKit

class NeighborhoodUserCell: UITableViewCell {
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_username: UILabel!
    @IBOutlet weak var ui_role: UILabel!
    @IBOutlet weak var ui_view_separator: UIView!
    @IBOutlet weak var ui_view_background: UIView!
    
    @IBOutlet weak var ic_image_reaction: UIImageView!
    @IBOutlet weak var ui_bt_message: UIButton!
    @IBOutlet weak var ui_picto_message: UIImageView!
    @IBOutlet weak var ui_view: UIView!
    
    var position = 0
    weak var delegate: NeighborhoodUserCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
        
        ui_username.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_role.font = ApplicationTheme.getFontNunitoRegular(size: 11)
        ui_role.textColor = .appOrangeLight
        // Configuration de l'arrondi pour ui_view
        
        if ui_view != nil {
            ui_view.layer.cornerRadius = ui_view.frame.height / 2
            ui_view.clipsToBounds = true // Ceci est nécessaire pour appliquer l'arrondi
            // Configuration du bord
            ui_view.layer.borderWidth = 1 // Définit la largeur du bord
            ui_view.layer.borderColor = UIColor(named: "grey_reaction")?.cgColor
            
        }

        
    }
    
    func hideSeparatorBarIfIsVote(isVote:Bool){
        if isVote {
            if ui_view_separator != nil {
                ui_view_separator.isHidden = true
            }
        }
    }
    
    func populateCell(isMe: Bool, username: String, role: String?, imageUrl: String?, showBtMessage: Bool, delegate: NeighborhoodUserCellDelegate, position: Int, reactionType: ReactionType?, isConfirmed: Bool?, isOrganizer: Bool?, isCreator:Bool?) {
        self.delegate = delegate
        self.position = position
        
        // Configure le nom de l'utilisateur
        if isOrganizer == true && isCreator == true {
            // Ajouter "- organisateur" en orange
            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            let organizerText = " - \(NSLocalizedString("neighborhood_user_role_animator", comment: ""))"
            let organizerAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(named: "appOrange") ?? UIColor.orange
            ]
            attributedText.append(NSAttributedString(string: organizerText, attributes: organizerAttributes))
            
            ui_username.attributedText = attributedText
            
            // Change le fond de la cellule en orange clair
            if self.ui_view_background != nil {
                self.ui_view_background.backgroundColor = UIColor(named: "lightOrangeBackground") ?? UIColor(red: 254/255, green: 245/255, blue: 235/255, alpha: 1.0)
            }
        }else if isOrganizer == true && isCreator == false {
            let attributedText = NSMutableAttributedString(string: username, attributes: [NSAttributedString.Key.foregroundColor: UIColor.black])
            let organizerText = " - \(NSLocalizedString("neighborhood_user_role_organizer", comment: ""))"
            let organizerAttributes: [NSAttributedString.Key: Any] = [
                .foregroundColor: UIColor(named: "appOrange") ?? UIColor.orange
            ]
            attributedText.append(NSAttributedString(string: organizerText, attributes: organizerAttributes))
            
            ui_username.attributedText = attributedText
            
            // Change le fond de la cellule en orange clair
            if self.ui_view_background != nil {
                self.ui_view_background.backgroundColor = UIColor(named: "lightOrangeBackground") ?? UIColor(red: 254/255, green: 245/255, blue: 235/255, alpha: 1.0)
            }
        } else {
            // Si ce n'est pas un organisateur, réinitialise le texte et la couleur de fond par défaut
            ui_username.text = username
            if self.ui_view_background != nil {
                self.ui_view_background.backgroundColor = .clear
            }
        }
        
        // Configurer le rôle de l'utilisateur
        ui_role.text = role
        
        if isConfirmed ?? false {
            ui_username.text = "\(username) - Participation confirmée"
        }
        
        print("position ", position)
        ui_bt_message.isHidden = !showBtMessage
        ui_picto_message.isHidden = !showBtMessage
        
        // Configurer l'image de l'utilisateur
        if let imageUrl = imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage(named: "placeholder_user"))
        } else {
            ui_image.image = UIImage(named: "placeholder_user")
        }
        
        // Masquer les boutons si c'est l'utilisateur lui-même
        ui_bt_message.isHidden = isMe
        ui_picto_message.isHidden = isMe
        
        // Configurer l'image de réaction
        if ic_image_reaction != nil {
            if let reactionId = reactionType?.id,
               let completeReactionType = getStoredReactionTypes()?.first(where: { $0.id == reactionId }),
               let imageUrl = URL(string: completeReactionType.imageUrl ?? "") {
                ic_image_reaction.isHidden = false
                ui_view.isHidden = false
                ic_image_reaction.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_i_like"))
            } else {
                // Gérer le cas où l'URL de l'image n'est pas disponible
                ic_image_reaction.isHidden = true
                ui_view.isHidden = true
            }
        }
    }

    
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
    
    @IBAction func action_send_message(_ sender: Any) {
        delegate?.showSendMessageToUserForPosition(position)
    }
}

//MARK: - Protocol  -
protocol NeighborhoodUserCellDelegate:AnyObject {
    func showSendMessageToUserForPosition(_ position:Int)
}

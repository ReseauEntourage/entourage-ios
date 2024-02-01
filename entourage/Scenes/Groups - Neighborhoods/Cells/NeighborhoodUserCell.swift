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
    
    @IBOutlet weak var ic_image_reaction: UIImageView!
    @IBOutlet weak var ui_bt_message: UIButton!
    @IBOutlet weak var ui_picto_message: UIImageView!
    
    var position = 0
    weak var delegate: NeighborhoodUserCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
        
        ui_username.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_role.font = ApplicationTheme.getFontNunitoRegular(size: 11)
        ui_role.textColor = .appOrangeLight
        
    }
    
    func populateCell(isMe:Bool, username:String, role:String?, imageUrl:String?, showBtMessage:Bool,delegate:NeighborhoodUserCellDelegate, position:Int, reactionType:ReactionType?) {
        ui_username.text = username
        ui_role.text = role
        
        self.delegate = delegate
        self.position = position
        
        ui_bt_message.isHidden = !showBtMessage
        ui_picto_message.isHidden = !showBtMessage
        
        if let imageUrl = imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_image.image = UIImage.init(named: "placeholder_user")
        }
        
        ui_bt_message.isHidden = isMe
        ui_picto_message.isHidden = isMe
        if let imageUrl = URL(string: reactionType?.imageUrl ?? ""){
            ui_image.sd_setImage(with: imageUrl, placeholderImage: UIImage(named: "ic_i_like"))
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

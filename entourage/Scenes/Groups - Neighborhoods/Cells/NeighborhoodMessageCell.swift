//
//  NeighborhoodMessageCell.swift
//  entourage
//
//  Created by Jerome on 16/05/2022.
//

import UIKit

class NeighborhoodMessageCell: UITableViewCell {

    @IBOutlet weak var ui_image_user: UIImageView!
   
    @IBOutlet weak var ui_view_message: UIView!
    @IBOutlet weak var ui_message: UILabel!
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_username: UILabel!
    
    @IBOutlet weak var ui_bt_signal_me: UIButton!
    
    let radius:CGFloat = 24
    var messageId:Int = 0
    
    weak var delegate:NeighborhoodMessageCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_image_user.layer.cornerRadius = ui_image_user.frame.height / 2
        ui_view_message.layer.cornerRadius = radius
        ui_message.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_date.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 11), color: .black))
        ui_username.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 11), color: .black))
    }
    
    func populateCell(isMe:Bool,message:PostMessage, delegate:NeighborhoodMessageCellDelegate) {
        messageId = message.uid
        self.delegate = delegate
        
        if isMe {
            ui_bt_signal_me?.isHidden = true
            ui_view_message.backgroundColor = .appOrangeLight_50
            ui_date.textColor = .appOrangeLight
            ui_username.textColor = .appOrangeLight
        }
        else {
            ui_view_message.backgroundColor = .appBeige
            ui_date.textColor = .black
            ui_username.textColor = .black
        }
        
        if let _url = message.user?.avatarURL, let url = URL(string: _url) {
            ui_image_user.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_image_user.image = UIImage.init(named: "placeholder_user")
        }
        
        ui_message.text = message.content
        ui_date.text = " - le \(message.createdDateTimeFormatted)"
        if let username = message.user?.displayName {
            ui_username.text = "\(username)"
        }
        else {
            ui_username.text = "- !"
        }
        
    }

    @IBAction func action_signal_message(_ sender: Any) {
        //TODO: à faire
        delegate?.signalMessage(messageId: messageId)
    }
}

protocol NeighborhoodMessageCellDelegate:AnyObject {
    func signalMessage(messageId:Int)
}

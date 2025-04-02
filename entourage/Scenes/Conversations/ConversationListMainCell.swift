//
//  ConversationListMainCell.swift
//  entourage
//
//  Created by Jerome on 22/08/2022.
//

import UIKit
import ActiveLabel

class ConversationListMainCell: UITableViewCell {
    
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_username: UILabel!
    @IBOutlet weak var ui_detail_message: ActiveLabel!
    @IBOutlet weak var ui_role: UILabel!
    @IBOutlet weak var ui_view_separator: UIView!
    
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_bt_user: UIButton!
    @IBOutlet weak var ui_picto_cat: UIImageView!
    
    @IBOutlet weak var ui_nb_unread: UILabel!
    var position = 0
    weak var delegate: ConversationListMainCellDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_image.layer.cornerRadius = ui_image.frame.height / 2
        
        ui_username.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_detail_message.setupFontAndColor(style: ApplicationTheme.getFontChampDefault(size: 13, color: .appGrisSombre40))
        ui_role.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange(size: 11, color: .appOrangeLight))
        ui_date.setupFontAndColor(style: ApplicationTheme.getFontChampDefault(size: 13, color: .appGrisSombre40))
        
        ui_nb_unread.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoBold(size: 12), color: .white))
        ui_nb_unread.layer.cornerRadius = ui_nb_unread.frame.height / 2
        
        ui_image.image = UIImage()
        ui_image.backgroundColor = UIColor.appBeige
        ui_picto_cat.isHidden = true
    }
    
    func populateCell(message:Conversation, delegate:ConversationListMainCellDelegate, position:Int) {
        ui_username.text = message.title
        if let count = message.members_count, count > 2, let members = message.members {
            let trimmedNames = members
                .prefix(5) // max 3 premiers
                .compactMap { $0.username } // éviter les nil
                .map { username -> String in
                    let end = username.index(username.endIndex, offsetBy: -2, limitedBy: username.startIndex) ?? username.startIndex
                    return String(username[..<end]) // enlève les 2 derniers caractères
                }

            ui_username.text = trimmedNames.joined(separator: ",")
        } else {
            ui_username.text = message.title
        }
        ui_role.text = message.getRolesWithPartnerFormated()
        if let _message = message.getLastMessage {
            ui_detail_message.text = _message
            ui_detail_message.handleURLTap { url in
                delegate.showWebUrl(url: url)
            }
        }
        ui_detail_message.text = message.getLastMessage
        ui_date.text = message.createdDateFormatted
        
        self.delegate = delegate
        self.position = position
        
        if !message.isOneToOne() {
            ui_bt_user.isHidden = true
            ui_picto_cat.isHidden = false
            ui_image.image = UIImage()
            ui_image.backgroundColor = UIColor.appBeige
            //TODO: load picto
            ui_picto_cat.image = UIImage.init(named: message.getPictoTypeFromSection())
        }
        else {
            ui_bt_user.isHidden = false
            ui_picto_cat.isHidden = true
            if let urlImg = message.user?.imageUrl, !urlImg.isEmpty, let mainUrl = URL(string: urlImg) {
                ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_user"))
            }
            else {
                ui_image.image = UIImage.init(named: "placeholder_user")
            }
        }
        
        //TODO: - actually click user disabled
        ui_bt_user.isHidden = true
        
        if message.hasUnread {
            ui_nb_unread.isHidden = false
            ui_nb_unread.text = "\(message.numberUnreadMessages!)"
            ui_date.textColor = .appOrange
            ui_detail_message.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoSemiBold(size: 13), color: .black))
        }
        else {
            ui_date.textColor = .appGrisSombre40
            ui_nb_unread.isHidden = true
            ui_detail_message.setupFontAndColor(style: ApplicationTheme.getFontChampDefault(size: 13, color: .appGrisSombre40))
        }
        
        if message.imBlocker() {
            ui_detail_message.text = "message_user_blocked_by_me_list".localized
            ui_detail_message.setupFontAndColor(style: ApplicationTheme.getFontChampDefault(size: 13, color: .rougeErreur))
        }
        if message.type == "outing" {
            self.ui_image.layer.cornerRadius = 10
            if let _url = URL(string: message.imageUrl ?? "") {
                ui_image.sd_setImage(with: _url, placeholderImage: UIImage.init(named: "ic_placeholder_my_event"))
            }
            self.ui_username.text = message.title
        }else {
            self.ui_image.layer.cornerRadius = ui_image.frame.height / 2
            if let urlImg = message.user?.imageUrl, !urlImg.isEmpty, let mainUrl = URL(string: urlImg) {
                ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_user"))
            }
            else {
                ui_image.image = UIImage.init(named: "placeholder_user")
            }
        }
    }
    
    @IBAction func action_send_message(_ sender: Any) {
        delegate?.showUserDetail(position)
    }
}

//MARK: - Protocol  -
protocol ConversationListMainCellDelegate:AnyObject {
    func showUserDetail(_ position:Int)
    func showWebUrl(url:URL)
}


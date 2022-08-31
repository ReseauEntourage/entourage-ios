//
//  NeighborhoodMessageCell.swift
//  entourage
//
//  Created by Jerome on 16/05/2022.
//

import UIKit
import CloudKit

class NeighborhoodMessageCell: UITableViewCell {

    @IBOutlet weak var ui_image_user: UIImageView!
   
    @IBOutlet weak var ui_view_message: UIView!
    @IBOutlet weak var ui_message: UILabel!
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_username: UILabel!
    
    @IBOutlet weak var ui_bt_signal_me: UIButton?
    
    @IBOutlet weak var ui_lb_error: UILabel!
    @IBOutlet weak var ui_view_error: UIView!
    
    
    let radius:CGFloat = 22
    var messageId:Int = 0
    var messageForRetry = ""
    var positionForRetry = 0
    var userId:Int? = nil
    
    weak var delegate:MessageCellSignalDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_image_user.layer.cornerRadius = ui_image_user.frame.height / 2
        ui_view_message.layer.cornerRadius = radius
        ui_message.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_date.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 11), color: .black))
        ui_username.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 11), color: .black))
        
        let alertTheme = MJTextFontColorStyle.init(font: ApplicationTheme.getFontNunitoRegularItalic(size: 11), color: .red)
        ui_lb_error?.setupFontAndColor(style: alertTheme)
        ui_lb_error?.text = "neighborhood_error_messageSend".localized
    }
    
    func populateCell(isMe:Bool,message:PostMessage,isRetry:Bool, positionRetry:Int = 0, delegate:MessageCellSignalDelegate) {
        messageId = message.uid
        userId = message.user?.sid
        
        self.delegate = delegate
        self.messageForRetry = message.content ?? ""
        self.positionForRetry = positionRetry
        
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
        
        if isRetry {
            ui_view_error?.isHidden = false
            ui_username.text = ""
            ui_date.text = ""
        }
        else {
            ui_view_error?.isHidden = true
            
            ui_date.text = "le \(message.createdDateTimeFormatted)"
            
            if !isMe {
            if let username = message.user?.displayName {
                ui_username.text = "\(username) - "
            }
            else {
                ui_username.text = "- !"
            }
            }
            else {
                ui_username.text = ""
            }
        }
    }
    
    func populateCellConversation(isMe:Bool,message:PostMessage,isRetry:Bool, positionRetry:Int = 0, isOne2One:Bool, delegate:MessageCellSignalDelegate) {
        messageId = message.uid
        userId = message.user?.sid
        
        self.delegate = delegate
        self.messageForRetry = message.content ?? ""
        self.positionForRetry = positionRetry
        
        ui_date.textColor = .appOrangeLight
        ui_username.textColor = .appOrangeLight
        
        if isMe {
            ui_view_message.backgroundColor = .appOrangeLight_50
        }
        else {
            ui_view_message.backgroundColor = .appBeige
        }
        
        if let _url = message.user?.avatarURL, let url = URL(string: _url) {
            ui_image_user.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_image_user.image = UIImage.init(named: "placeholder_user")
        }
        
        ui_message.text = message.content
        
        if isRetry {
            ui_view_error?.isHidden = false
            ui_username.text = ""
            ui_date.text = ""
        }
        else {
            ui_view_error?.isHidden = true
            if isOne2One {
                ui_date.text = "\(message.createdTimeFormatted)"
                ui_username.text = " "
            }
            else {
                if isMe {
                    ui_date.text = "\(message.createdTimeFormatted)"
                    ui_username.text = ""
                }
                else {
                    ui_date.text = " à \(message.createdTimeFormatted)"
                    if let username = message.user?.displayName {
                        ui_username.text = "\(username)"
                    }
                    else {
                        ui_username.text = "- !"
                    }
                }
            }
        }
    }

    @IBAction func action_signal_message(_ sender: Any) {
        delegate?.signalMessage(messageId: messageId)
    }
    
    @IBAction func action_retry(_ sender: Any) {
        delegate?.retrySend(message: messageForRetry,positionForRetry:positionForRetry)
    }
    
    @IBAction func action_show_user(_ sender: Any) {
        Logger.print("***** action show : \(userId)")
        delegate?.showUser(userId: userId)
    }
}

protocol MessageCellSignalDelegate:AnyObject {
    func signalMessage(messageId:Int)
    func retrySend(message:String, positionForRetry:Int)
    func showUser(userId:Int?)
}

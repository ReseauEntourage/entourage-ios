//
//  NeighborhoodPostCell.swift
//  entourage
//
//  Created by Jerome on 13/05/2022.
//

import UIKit

class NeighborhoodPostCell: UITableViewCell {
    @IBOutlet weak var ui_view_container: UIView!
    
    @IBOutlet weak var ui_iv_user: UIImageView!
    @IBOutlet weak var ui_username: UILabel!
    
    @IBOutlet weak var ui_date: UILabel!
    
    @IBOutlet weak var ui_comment: UILabel!
    
    @IBOutlet weak var ui_comments_nb: UILabel!
    
    @IBOutlet weak var ui_image_post: UIImageView!
    
    @IBOutlet weak var ui_view_comment: UIView!
    
    @IBOutlet weak var ui_view_bt_send: UIView!
    @IBOutlet weak var ui_lb_chat: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    weak var delegate:NeighborhoodPostCellDelegate? = nil
    var postId:Int = 0
    var currentIndexPath:IndexPath? = nil
    var userId:Int? = nil
    var imageUrl:URL? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_container.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        ui_iv_user.layer.cornerRadius = ui_iv_user.frame.height / 2
        
        ui_username.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoBold(size: 12), color: .black))
        ui_date.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoLight(size: 9), color: .black))
        ui_comment.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_comments_nb.setupFontAndColor(style: ApplicationTheme.getFontChampInput())
        
        ui_image_post?.layer.cornerRadius = 8
        
        ui_view_bt_send.layer.cornerRadius = ui_view_bt_send.frame.height / 2
        ui_view_comment.layer.cornerRadius = ui_view_comment.frame.height / 2
        ui_view_comment.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_comment.layer.borderWidth = 1
        ui_lb_chat.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange())
        
    }
    
    func populateCell(message:PostMessage, delegate:NeighborhoodPostCellDelegate, currentIndexPath:IndexPath?, userId:Int?) {
        self.delegate = delegate
        ui_username.text = message.user?.displayName
        ui_date.text = message.createdDateFormatted
        ui_comment.text = message.content
        self.currentIndexPath = currentIndexPath
        postId = message.uid
        self.userId = userId
        
        if let _url = message.user?.avatarURL, let url = URL(string: _url) {
            ui_iv_user.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_iv_user.image = UIImage.init(named: "placeholder_user")
        }
        
        if message.commentsCount == 0 {
            ui_comments_nb.text = "neighborhood_post_noComment".localized
            
            ui_comments_nb.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 13), color: .appGrisSombre40))

        }
        else {
            let msg:String = message.commentsCount ?? 0 <= 1 ? "neighborhood_post_1Comment".localized : "neighborhood_post_XComments".localized
            
            let attrStr = Utils.formatStringUnderline(textString: String.init(format: msg, message.commentsCount ?? 0), textColor: .black, font: ApplicationTheme.getFontChampInput().font)
            ui_comments_nb.attributedText = attrStr
        }
        
        if let urlStr = message.messageImageUrl, let url = URL(string: urlStr) {
            ui_image_post?.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_post"))
            imageUrl = url
        }
        else {
            ui_image_post?.image = UIImage.init(named: "placeholder_post")
        }
    }

    @IBAction func action_show_comments(_ sender: Any) {
        delegate?.showMessages(addComment: false,postId: postId, indexPathSelected: currentIndexPath)
    }
    
    @IBAction func action_add_comments(_ sender: Any) {
        delegate?.showMessages(addComment: true,postId: postId, indexPathSelected: currentIndexPath)
    }
    
    @IBAction func action_show_user(_ sender: Any) {
        delegate?.showUser(userId: userId)
    }
    
    @IBAction func action_show_image(_ sender: Any) {
        delegate?.showImage(imageUrl: imageUrl)
    }
}

protocol NeighborhoodPostCellDelegate: AnyObject {
    func showMessages(addComment:Bool, postId:Int, indexPathSelected:IndexPath?)
    func showUser(userId:Int?)
    func showImage(imageUrl:URL?)
}


class NeighborhoodPostTextCell: NeighborhoodPostCell {
    //override class var identifier: String {return self.description()}
}

class NeighborhoodPostImageCell: NeighborhoodPostCell {
   // override class var identifier: String {return self.description()}
}

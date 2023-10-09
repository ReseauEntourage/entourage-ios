//
//  DetailMessageTopPostCell.swift
//  entourage
//
//  Created by - on 10/01/2023.
//

import UIKit
import ActiveLabel

protocol DetailMessageTopCellDelegate{
    func showWebView(url:URL)
}

class DetailMessageTopPostCell: UITableViewCell {
    
    @IBOutlet weak var ui_iv_user: UIImageView!
    
    @IBOutlet weak var ui_user: UILabel!
    
    @IBOutlet weak var ui_comment: ActiveLabel!
    
    @IBOutlet weak var ui_image_post: UIImageView?
    
    
    class var identifier: String {
        return String(describing: self)
    }
    
    
    var postId:Int = 0
    var imageUrl:URL? = nil
    var delegate:DetailMessageTopCellDelegate?
    
    var postMessage:PostMessage!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_iv_user.layer.cornerRadius = ui_iv_user.frame.height / 2
        
        ui_user.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 12), color: .appOrangeLight))
        
        ui_comment.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_comment.enabledTypes = [.url]
        ui_comment.handleURLTap { url in
            // Ouvrez le lien dans Safari, par exemple
            self.delegate?.showWebView(url: url)
        }
        ui_image_post?.layer.cornerRadius = 8

    }
    
    func populateCell(message:PostMessage) {
        self.postMessage = message
        ui_user.text = "\(message.user?.displayName ?? "-") le \(message.createdDateFormatted)"
        ui_comment.text = message.content

        postId = message.uid
        
        if let _url = message.user?.avatarURL, let url = URL(string: _url) {
            ui_iv_user.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            ui_iv_user.image = UIImage.init(named: "placeholder_user")
        }
        
        if let urlStr = message.messageImageUrl, let url = URL(string: urlStr) {
            ui_image_post?.sd_setImage(with: url, placeholderImage: UIImage.init(named: "placeholder_post"))
            imageUrl = url
        }
        else {
            ui_image_post?.image = UIImage.init(named: "placeholder_post")
        }
    }
}

class DetailMessageTopPostTextCell: DetailMessageTopPostCell {
    //override class var identifier: String {return self.description()}
}

class DetailMessageTopPostImageCell: DetailMessageTopPostCell {
   // override class var identifier: String {return self.description()}
}

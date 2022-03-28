//
//  EditProfilePhotoCell.swift
//  entourage
//
//  Created by Jerome on 21/03/2022.
//

import UIKit

class EditProfilePhotoCell: UITableViewCell {
    
    @IBOutlet weak var ui_bt_mod_photo: UIButton!
    @IBOutlet weak var ui_image_user: UIImageView!
    @IBOutlet weak var ui_view_img_profile: UIView!
    
    weak var delegate:EditProfilePhotoDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_image_user.layer.cornerRadius = ui_image_user.frame.height / 2
        
        ui_view_img_profile.layer.cornerRadius = ui_image_user.frame.height / 2
        ui_view_img_profile.layer.borderColor = UIColor.white.cgColor
        ui_view_img_profile.layer.borderWidth = 1
        
        ui_view_img_profile.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        ui_view_img_profile.layer.shadowOpacity = 1
        ui_view_img_profile.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        ui_view_img_profile.layer.shadowRadius = 10
        
        ui_view_img_profile.layer.rasterizationScale = UIScreen.main.scale
        ui_view_img_profile.layer.shouldRasterize = true
        
        ui_bt_mod_photo.tintColor = .appOrange
        
        let btTitleAttr = Utils.formatStringUnderline(textString: "editUserModPhoto".localized, textColor: .appOrange, font: ApplicationTheme.getFontNunitoRegular(size: 14))
        ui_bt_mod_photo.setAttributedTitle(btTitleAttr, for: .normal)
    }
    
    func populateCell(photoUrl:String?,delegate:EditProfilePhotoDelegate) {
        self.delegate = delegate
        
        if let user = UserDefaults.currentUser,let _url = user.avatarURL, let mainUrl = URL(string: _url) {
            ui_image_user.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
    }
    
    @IBAction func action_take_photo(_ sender: Any) {
        delegate?.takeUserPhoto()
    }
}

//MARK: - EditProfilePhotoDelegate -
protocol EditProfilePhotoDelegate: AnyObject {
    func takeUserPhoto()
}

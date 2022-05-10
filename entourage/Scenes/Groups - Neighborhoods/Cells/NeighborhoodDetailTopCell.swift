//
//  NeighborhoodDetailTopCell.swift
//  entourage
//
//  Created by Jerome on 29/04/2022.
//

import UIKit

class NeighborhoodDetailTopCell: UITableViewCell {
    
    @IBOutlet weak var ui_constraint_listview_top_margin: NSLayoutConstraint?
    
    @IBOutlet weak var ui_main_view: UIView!
    
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_lbl_nb_members: UILabel!
    @IBOutlet weak var ui_img_member_1: UIImageView!
    @IBOutlet weak var ui_img_member_2: UIImageView!
    @IBOutlet weak var ui_img_member_3: UIImageView!
    @IBOutlet weak var ui_view_members_more: UIView!
    
    @IBOutlet weak var ui_view_button_join: UIView!
    @IBOutlet weak var ui_img_bt_join: UIImageView!
    @IBOutlet weak var ui_lbl_bt_join: UILabel!
    
    @IBOutlet weak var ui_lbl_about_title: UILabel!
    @IBOutlet weak var ui_lbl_about_desc: UILabel!
    
    @IBOutlet weak var ui_taglist_view: TagListView!
    
    weak var delegate:NeighborhoodDetailTopCellDelegate? = nil
    
    let topMarginConstraint:CGFloat = 24
    let cornerRadiusTag:CGFloat = 15
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_main_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lbl_nb_members.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lbl_about_title?.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_lbl_about_title?.text = "neighborhood_detail_about_title".localized
        ui_lbl_about_desc?.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lbl_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
        ui_view_button_join.layer.cornerRadius = ui_view_button_join.frame.height / 2
        ui_view_button_join.layer.borderColor = UIColor.appOrange.cgColor
        ui_view_button_join.layer.borderWidth = 1
        
        ui_taglist_view?.backgroundColor = .appBeigeClair
        ui_taglist_view?.tagBackgroundColor = ApplicationTheme.getFontCategoryBubble().color
        ui_taglist_view?.cornerRadius = cornerRadiusTag
        ui_taglist_view?.textFont = ApplicationTheme.getFontCategoryBubble().font
        ui_taglist_view?.textColor = .appOrange
        ui_taglist_view?.alignment = .center
        
        //Values to align and padding tags
        ui_taglist_view?.marginY = 12
        ui_taglist_view?.marginX = 12
        
        ui_taglist_view?.paddingX = 15
        ui_taglist_view?.paddingY = 9
        
        ui_img_member_1.layer.cornerRadius = ui_img_member_1.frame.height / 2
        ui_img_member_2.layer.cornerRadius = ui_img_member_2.frame.height / 2
        ui_img_member_3.layer.cornerRadius = ui_img_member_3.frame.height / 2
    }
    
    func populateCell(neighborhood:Neighborhood?, delegate:NeighborhoodDetailTopCellDelegate) {
        
        self.delegate = delegate
        ui_img_member_1.isHidden = true
        ui_img_member_2.isHidden = true
        ui_img_member_3.isHidden = true
        ui_view_members_more.isHidden = true
        
        guard let neighborhood = neighborhood else {
            return
        }
        
        for i in 0..<neighborhood.members.count {
            if i > 2 { break }
            switch i {
            case 0:
                ui_img_member_1.isHidden = false
                updateImageUrl(image: ui_img_member_1, imageUrl: neighborhood.members[i].imageUrl)
            case 1:
                ui_img_member_2.isHidden = false
                updateImageUrl(image: ui_img_member_2, imageUrl: neighborhood.members[i].imageUrl)
            case 2:
                ui_img_member_3.isHidden = false
                updateImageUrl(image: ui_img_member_3, imageUrl: neighborhood.members[i].imageUrl)
            default:
                break
            }
        }
        
        if neighborhood.membersCount > 3 {
            ui_view_members_more.isHidden = false
        }
        
        ui_lbl_nb_members.text = ""
        var membersCount = ""
        if neighborhood.members.count > 1 {
            membersCount = String.init(format: "neighborhood_detail_members".localized,neighborhood.membersCount)
        }
        else {
            membersCount = String.init(format: "neighborhood_detail_member".localized, neighborhood.membersCount)
        }
        
        let addressName:String = neighborhood.address?.displayAddress ?? "-"
        membersCount = "\(membersCount) \(addressName)"
        
        ui_lbl_nb_members.text = membersCount
        
        ui_title.text = neighborhood.name
        ui_lbl_about_desc?.text = neighborhood.aboutGroup
        
        let currentUserId = UserDefaults.currentUser?.sid
        if neighborhood.isFollowingGroup(myId: currentUserId) {
            ui_lbl_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonOrange())
            ui_view_button_join.backgroundColor = .clear
            ui_view_button_join.layer.borderWidth = 0
            ui_img_bt_join.image = UIImage.init(named: "ic_next_orange")
            ui_lbl_bt_join.attributedText = Utils.formatStringUnderline(textString: "neighborhood_detail_button_more".localized, textColor: .appOrange,font: ApplicationTheme.getFontH2Noir().font)
        }
        else if let _ = neighborhood.members.first(where: {$0.uid == currentUserId}) {
            ui_lbl_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonOrange())
            ui_view_button_join.backgroundColor = .clear
            ui_img_bt_join.image = UIImage.init(named: "ic_check_member_orange")
            ui_lbl_bt_join.text = "neighborhood_detail_button_join_member".localized
        }
        else {
            ui_lbl_bt_join.setupFontAndColor(style: ApplicationTheme.getFontBoutonBlanc())
            ui_view_button_join.backgroundColor = .appOrange
            ui_img_bt_join.image = UIImage.init(named: "ic_plus_white")
            ui_lbl_bt_join.text = "neighborhood_detail_button_join_join".localized
        }
        
        if let _interests = neighborhood.interests {
            ui_taglist_view?.removeAllTags()
            for interest in _interests {
                if let tagName = Metadatas.sharedInstance.tagsInterest?.getTagNameFrom(key: interest) {
                    ui_taglist_view?.addTag(tagName)
                }
                else {
                    ui_taglist_view?.addTag(interest)
                }
            }
            if _interests.isEmpty {
                ui_constraint_listview_top_margin?.constant = 0
            }
            else {
                ui_constraint_listview_top_margin?.constant = topMarginConstraint
            }
        }
        else {
            ui_constraint_listview_top_margin?.constant = topMarginConstraint
        }
    }
    
    private func updateImageUrl(image:UIImageView, imageUrl:String?) {
        if let imageUrl = imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_user"))
        }
        else {
            image.image = UIImage.init(named: "placeholder_user")
        }
    }
    
    
    @IBAction func action_show_members(_ sender: Any) {
        delegate?.showMembers()
    }
    
    @IBAction func action_join_leave(_ sender: Any) {
        delegate?.joinLeave()
    }
}

//MARK: - Protocol -
protocol NeighborhoodDetailTopCellDelegate : AnyObject {
    func showMembers()
    func joinLeave()
}

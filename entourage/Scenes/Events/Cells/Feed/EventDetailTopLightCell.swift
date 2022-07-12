//
//  EventDetailTopLightCell.swift
//  entourage
//
//  Created by Jerome on 08/07/2022.
//

import UIKit

class EventDetailTopLightCell: UITableViewCell {
    
    @IBOutlet weak var ui_main_view: UIView!
    
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_lbl_nb_members: UILabel!
    @IBOutlet weak var ui_img_member_1: UIImageView!
    @IBOutlet weak var ui_img_member_2: UIImageView!
    @IBOutlet weak var ui_img_member_3: UIImageView!
    @IBOutlet weak var ui_view_members_more: UIView!
    
    @IBOutlet weak var ui_start_time: UILabel!
    @IBOutlet weak var ui_start_date: UILabel!
    
    @IBOutlet weak var ui_view_place_limit: UIView!
    @IBOutlet weak var ui_place_limit_nb: UILabel!
    
    @IBOutlet weak var ui_location_name: UILabel!
    
    @IBOutlet weak var ui_view_button_more: UIView!
    @IBOutlet weak var ui_img_bt_more: UIImageView!
    @IBOutlet weak var ui_lbl_bt_more: UILabel!
    
    weak var delegate:EventDetailTopCellDelegate? = nil
    
    let cornerRadiusTag:CGFloat = 15
    
    class var identifier:String {return String(describing: self) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_main_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_lbl_nb_members.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        
        ui_img_member_1.layer.cornerRadius = ui_img_member_1.frame.height / 2
        ui_img_member_2.layer.cornerRadius = ui_img_member_2.frame.height / 2
        ui_img_member_3.layer.cornerRadius = ui_img_member_3.frame.height / 2
    }
    
    func populateCell(event:Event?, delegate:EventDetailTopCellDelegate) {
        self.delegate = delegate
        ui_img_member_1.isHidden = true
        ui_img_member_2.isHidden = true
        ui_img_member_3.isHidden = true
        ui_view_members_more.isHidden = true
        
        guard let event = event else {
            return
        }
        if let _members = event.members {
            for i in 0..<_members.count {
                if i > 2 { break }
                switch i {
                case 0:
                    ui_img_member_1.isHidden = false
                    updateImageUrl(image: ui_img_member_1, imageUrl: _members[i].imageUrl)
                case 1:
                    ui_img_member_2.isHidden = false
                    updateImageUrl(image: ui_img_member_2, imageUrl: _members[i].imageUrl)
                case 2:
                    ui_img_member_3.isHidden = false
                    updateImageUrl(image: ui_img_member_3, imageUrl: _members[i].imageUrl)
                default:
                    break
                }
            }
        }
        
        let _membersCount:Int = event.membersCount ?? 0
        
        if _membersCount > 3 {
            ui_view_members_more.isHidden = false
        }
        
        ui_lbl_nb_members.text = ""
        var membersCount = ""
        if _membersCount > 1 {
            membersCount = String.init(format: "event_members_cell_list".localized,_membersCount)
        }
        else {
            membersCount = String.init(format: "event_member_cell_list".localized, _membersCount)
        }
        
        ui_lbl_nb_members.text = membersCount
        
        ui_title.text = event.title
        
        if let placeLimit = event.metadata?.place_limit, placeLimit > 0 {
            ui_view_place_limit.isHidden = false
            ui_place_limit_nb.text = String.init(format: "event_places_detail".localized,placeLimit)
        }
        else {
            ui_view_place_limit.isHidden = true
        }
        
        ui_start_date.text = event.startDateNameFormatted
        ui_start_time.text = event.startTimeFormatted
        
        var _addressName = ""
        if event.isOnline ?? false {
            _addressName = event.onlineEventUrl ?? "-"
        }
        else {
            _addressName = event.addressName ?? "-"
        }
        
        ui_location_name.attributedText = Utils.formatStringUnderline(textString: _addressName, textColor: .black)
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
    
    @IBAction func action_show_place(_ sender: Any) {
        delegate?.showPlace()
    }
    
    @IBAction func action_show_detail_event(_ sender: Any) {
        delegate?.showDetailFull()
    }
}

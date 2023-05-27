//
//  EventDetailTopLightCell.swift
//  entourage
//
//  Created by Jerome on 08/07/2022.
//

import UIKit
import SDWebImage

class EventDetailTopLightCell: UITableViewCell {
    
    @IBOutlet weak var ui_iv_date: UIImageView!
    @IBOutlet weak var ui_iv_time: UIImageView!
    @IBOutlet weak var ui_iv_place: UIImageView!
    
    @IBOutlet weak var ui_main_view: UIView!
    
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_iv_location: UIImageView!
    @IBOutlet weak var ui_lbl_nb_members: UILabel!
    @IBOutlet weak var ui_img_member_1: UIImageView!
    @IBOutlet weak var ui_img_member_2: UIImageView!
    @IBOutlet weak var ui_img_member_3: UIImageView!
    @IBOutlet weak var ui_view_members_more: UIView!
    
    @IBOutlet weak var ui_view_start_date: UIView!
    @IBOutlet weak var ui_start_time: UILabel!
    @IBOutlet weak var ui_start_date: UILabel!
    
    @IBOutlet weak var ui_view_place_limit: UIView!
    @IBOutlet weak var ui_place_limit_nb: UILabel!
    
    @IBOutlet weak var ui_location_name: UILabel!
    
    @IBOutlet weak var ui_view_button_more: UIView!
    @IBOutlet weak var ui_img_bt_more: UIImageView!
    @IBOutlet weak var ui_lbl_bt_more: UILabel!
    
    @IBOutlet weak var ui_view_organised_by: UIView!
    weak var delegate:EventDetailTopCellDelegate? = nil
    
    @IBOutlet weak var ui_view_association: UIView!
    
    @IBOutlet weak var ui_label_association: UILabel!
    
    
    @IBOutlet weak var ui_label_organised_by: UILabel!
    @IBOutlet weak var ui_btn_organisez_by: UIButton!
    let cornerRadiusTag:CGFloat = 15
    
    class var identifier:String {return String(describing: self) }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_main_view.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_start_date.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_start_time.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_lbl_nb_members.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_lbl_bt_more.attributedText = Utils.formatStringUnderline(textString: "event_detail_button_more".localized, textColor: .appOrange,font: ApplicationTheme.getFontH2Noir().font)

        
        ui_img_member_1.layer.cornerRadius = ui_img_member_1.frame.height / 2
        ui_img_member_2.layer.cornerRadius = ui_img_member_2.frame.height / 2
        ui_img_member_3.layer.cornerRadius = ui_img_member_3.frame.height / 2
        ui_view_place_limit.isHidden = true
        ui_view_members_more.isHidden = true
    }
    
    func populateCell(event:Event?, delegate:EventDetailTopCellDelegate, isEntourageEvent:Bool) {
        self.delegate = delegate
        ui_img_member_1.isHidden = true
        ui_img_member_2.isHidden = true
        ui_img_member_3.isHidden = true
        ui_img_member_1.image = nil
        ui_img_member_2.image = nil
        ui_img_member_3.image = nil
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
        
        if event.isCanceled() {
            ui_title.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontQuickSandBold(size: 24), color: .appGris112))
            ui_start_date.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 15), color: .appGris112))
            ui_start_time.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 15), color: .appGris112))
            ui_location_name.textColor = .appGris112
            
            ui_iv_place.image = UIImage.init(named: "ic_event_group_grey")
            ui_iv_date.image = UIImage.init(named: "ic_event_date_grey")
            ui_iv_time.image = UIImage.init(named: "ic_event_time_grey")
            ui_place_limit_nb.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 15), color: .appGris112))
        }
        else {
            ui_title.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
            ui_start_date.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
            ui_start_time.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
            ui_place_limit_nb.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
            ui_iv_place.image = UIImage.init(named: "ic_event_group_clear")
            ui_iv_date.image = UIImage.init(named: "ic_event_date")
            ui_iv_time.image = UIImage.init(named: "ic_event_time")
        }
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
            ui_iv_location.image = event.isCanceled() ? UIImage.init(named: "ic_web_grey") : UIImage.init(named: "ic_web")
        }
        else {
            _addressName = event.addressName ?? "-"
            ui_iv_location.image = event.isCanceled() ? UIImage.init(named: "ic_location_grey") : UIImage.init(named: "ic_location")
        }
        if event.isCanceled() {
            ui_location_name.text = _addressName
        }
        else {
            ui_location_name.attributedText = Utils.formatStringUnderline(textString: _addressName, textColor: .black)
        }
        
        if let _author = event.author {
            ui_label_organised_by.text = "event_top_cell_organised_by".localized + _author.displayName
            ui_view_organised_by.isHidden = false
            if let _asso = _author.partner {
                ui_view_association.isHidden = false
                ui_label_association.text = String(format: "event_top_cell_asso".localized, _asso.name)
            }else{
                ui_view_association.isHidden = true
            }
            
        }else {
            ui_view_organised_by.isHidden = true
            ui_view_association.isHidden = true
        }
        if isEntourageEvent {
            ui_label_association.text = String(format: "event_top_cell_asso".localized, "Entourage")
            ui_view_association.isHidden = false
        }
    }
    
    private func updateImageUrl(image:UIImageView, imageUrl:String?) {
        if let imageUrl = imageUrl, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            image.sd_setImage(with: mainUrl, placeholderImage: nil, completed: { (_image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if error != nil {
                    image.image = UIImage.init(named: "placeholder_user")
                }
            })
        }
        else {
            image.image = UIImage.init(named: "placeholder_user")
        }
    }
    

    @IBAction func action_show_user(_ sender: Any) {
        delegate?.showUser()
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

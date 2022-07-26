//
//  EventListCell.swift
//  entourage
//
//  Created by Jerome on 05/07/2022.
//

import UIKit
import SDWebImage

class EventListCell: UITableViewCell {

    static let EventlistMeIdentifier = "EventListMeCell"
    
    @IBOutlet weak var ui_iv_canceled: UIImageView!
    @IBOutlet weak var ui_constraint_left_title: NSLayoutConstraint!
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_date: UILabel!
    @IBOutlet weak var ui_location: UILabel!
    @IBOutlet weak var ui_members: UILabel!
    @IBOutlet weak var ui_view_separator: UIView!
    
    @IBOutlet weak var ui_label_admin: UILabel?
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_date.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_location.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_members.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        
        ui_image.layer.cornerRadius = 20
        
        ui_label_admin?.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 15), color: .appOrangeLight))
        ui_label_admin?.text = "Admin".localized
    }
    
    func populateCell(event:Event, hideSeparator:Bool) {
        
        if event.isCanceled() {
            ui_iv_canceled.isHidden = false
            ui_constraint_left_title.constant = 38
            let str = "\(event.title) - \("event_cancel_list".localized)"
            let attrStr = Utils.formatString(messageTxt: str, messageTxtHighlight: "- \("event_cancel_list".localized)", fontColorType: MJTextFontColorStyle(font: ApplicationTheme.getFontQuickSandBold(size: 15), color: .appGris112), fontColorTypeHighlight: ApplicationTheme.getFontLegendGris(size: 13))
            ui_title.attributedText = attrStr
        }
        else {
            ui_constraint_left_title.constant = 10
            ui_title.text = event.title
            ui_iv_canceled.isHidden = true
        }
        
        if let imageUrl = event.metadata?.portrait_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: nil, options:SDWebImageOptions(rawValue: SDWebImageOptions.progressiveLoad.rawValue), completed: { [weak self] (image: UIImage?, error: Error?, cacheType: SDImageCacheType, url: URL?) in
                if error != nil {
                    self?.ui_image.image = UIImage.init(named: "ic_placeholder_event")
                }
            })
        }
        else {
            ui_image.image = UIImage.init(named: "ic_placeholder_event")
        }
    
        ui_view_separator.isHidden = hideSeparator
        
        ui_date.text = event.startDateTimeFormatted
        ui_location.text = event.addressName
        ui_members?.text = event.membersCount ?? 0 > 1 ? String.init(format: "event_members_cell_list".localized, event.membersCount!) : String.init(format: "event_member_cell_list".localized, event.membersCount!)
    }
}

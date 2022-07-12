//
//  EventListCell.swift
//  entourage
//
//  Created by Jerome on 05/07/2022.
//

import UIKit

class EventListCell: UITableViewCell {

    static let EventlistMeIdentifier = "EventListMeCell"
    
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
        
        ui_label_admin?.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange())
        ui_label_admin?.text = "Admin".localized
    }
    
    func populateCell(event:Event, hideSeparator:Bool) {
        ui_title.text = event.title
        
        if let imageUrl = event.metadata?.portrait_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "ic_placeholder_event"))
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

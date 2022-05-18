//
//  NeighborhoodEmptyEventCell.swift
//  entourage
//
//  Created by Jerome on 10/05/2022.
//

import UIKit

class NeighborhoodEmptyEventCell: UITableViewCell {

    @IBOutlet weak var ui_title_section: UILabel!
    @IBOutlet weak var ui_view_container: UIView!
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_subtitle: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_container.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        ui_title_section.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontH2Noir())
        ui_subtitle.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularOrange(size: 15, color: .appOrangeLight))
        
        ui_title_section.text = "neighborhood_event_group_section_title".localized
        ui_title.text = "neighborhood_empty_event_title".localized
        ui_subtitle.text = "neighborhood_empty_event_subtitle".localized
    }
}

class NeighborhoodEmptyPostCell: UITableViewCell {

    @IBOutlet weak var ui_title_section: UILabel!
    @IBOutlet weak var ui_view_container: UIView!
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_subtitle: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_container?.layer.cornerRadius = ApplicationTheme.bigCornerRadius
        
        ui_title_section?.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_title?.setupFontAndColor(style: ApplicationTheme.getFontH1Noir())
        ui_subtitle?.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_title_section?.text = "neighborhood_post_group_section_title".localized
        ui_title?.text = "neighborhood_empty_post_title".localized
        ui_subtitle?.text = "neighborhood_empty_post_subtitle".localized
    }
}

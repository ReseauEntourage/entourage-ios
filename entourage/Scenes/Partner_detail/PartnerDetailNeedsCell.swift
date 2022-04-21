//
//  PartnerDetailNeedsCell.swift
//  entourage
//
//  Created by Jerome on 05/04/2022.
//

import UIKit

class PartnerDetailNeedsCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_needs: UIView!
    @IBOutlet weak var ui_title_needs: UILabel!
    
    @IBOutlet weak var ui_view_needs_donation: UIView!
    @IBOutlet weak var ui_title_needs_donation: UILabel!
    @IBOutlet weak var ui_description_needs_donation: UILabel!
    
    @IBOutlet weak var ui_view_needs_volunteer: UIView!
    @IBOutlet weak var ui_title_needs_volunteer: UILabel!
    @IBOutlet weak var ui_description_needs_volunteer: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title_needs.textColor = ApplicationTheme.getFontH2Noir().color
        ui_title_needs.font = ApplicationTheme.getFontH2Noir().font
        ui_title_needs.text = "title_asso_needs".localized
        
        ui_title_needs_donation.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        ui_title_needs_donation.textColor = .appOrange
        ui_title_needs_donation.text = "title_asso_accept_needs".localized
        ui_description_needs_donation.font = ApplicationTheme.getFontLegend().font
        ui_description_needs_donation.textColor = ApplicationTheme.getFontLegend().color
        
        ui_title_needs_volunteer.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        ui_title_needs_volunteer.textColor = .appOrange
        ui_title_needs_volunteer.text = "title_asso_accept_volunteers".localized
        ui_description_needs_volunteer.font = ApplicationTheme.getFontLegend().font
        ui_description_needs_volunteer.textColor = ApplicationTheme.getFontLegend().color
    }
    
    func populateCell(partner:Partner?) {
        var hasNeeds = false
        
        if !(partner?.donations_needs?.isEmpty ?? true) {
            hasNeeds = true
            ui_view_needs_donation.isHidden = false
            ui_description_needs_donation.text = partner?.donations_needs
        }
        else {
            ui_view_needs_donation.isHidden = true
        }
        
        if !(partner?.volunteers_needs?.isEmpty ?? true) {
            hasNeeds = true
            ui_view_needs_volunteer.isHidden = false
            ui_description_needs_volunteer.text = partner?.volunteers_needs
        }
        else {
            ui_view_needs_volunteer.isHidden = true
        }
        
        if hasNeeds {
            ui_view_needs.isHidden = false
            ui_title_needs.isHidden = false
        }
        else {
            ui_view_needs.isHidden = true
            ui_title_needs.isHidden = true
        }
    }
}

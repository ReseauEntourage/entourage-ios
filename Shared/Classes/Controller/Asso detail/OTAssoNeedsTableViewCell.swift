//
//  OTAssoNeedsTableViewCell.swift
//  entourage
//
//  Created by Jr on 30/06/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit

class OTAssoNeedsTableViewCell: UITableViewCell {

    @IBOutlet weak var ui_tv_volunteers_description: UILabel!
    @IBOutlet weak var ui_tv_needs_description: UILabel!
    @IBOutlet weak var ui_tv_accept_needs: UILabel!
    @IBOutlet weak var ui_tv_accept_volunteers: UILabel!
    @IBOutlet weak var ui_view_volunteers: UIView!
    @IBOutlet weak var ui_view_needs: UIView!
    @IBOutlet weak var ui_tv_needs: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_tv_needs.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_needs")
        ui_tv_accept_needs.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_accept_needs")
        ui_tv_accept_volunteers.text = OTLocalisationService.getLocalizedValue(forKey: "title_asso_accept_volunteers")
    }

    func populateCell(donationsDescription:String?,volunteersDesription:String?) {
        
        if let _desc = donationsDescription {
            ui_view_needs.isHidden = false
            ui_tv_needs_description.text = _desc
        }
        else {
            ui_view_needs.isHidden = true
        }
        
        if let _desc = volunteersDesription {
            ui_view_volunteers.isHidden = false
            ui_tv_volunteers_description.text = _desc
        }
        else {
            ui_view_volunteers.isHidden = true
        }
        
    }

}

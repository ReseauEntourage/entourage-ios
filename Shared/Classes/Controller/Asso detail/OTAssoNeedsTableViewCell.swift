//
//  OTAssoNeedsTableViewCell.swift
//  entourage
//
//  Created by Jr on 30/06/2020.
//  Copyright © 2020 OCTO Technology. All rights reserved.
//

import UIKit
import TTTAttributedLabel

class OTAssoNeedsTableViewCell: UITableViewCell {

    @IBOutlet weak var ui_tv_volunteers_description: TTTAttributedLabel!
    @IBOutlet weak var ui_tv_needs_description: TTTAttributedLabel!
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
        
        setupLinksForLabel(_label: ui_tv_volunteers_description)
        setupLinksForLabel(_label: ui_tv_needs_description)
        
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
    
    func setupLinksForLabel(_label: TTTAttributedLabel) {
        _label.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
        _label.linkAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appOrange() as Any]
        _label.delegate = self
    }

}

extension OTAssoNeedsTableViewCell: TTTAttributedLabelDelegate {
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
}

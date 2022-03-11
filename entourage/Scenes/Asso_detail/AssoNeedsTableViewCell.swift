//
//  OTAssoNeedsTableViewCell.swift
//  entourage
//
//  Created by Jr on 30/06/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
//import TTTAttributedLabel
import Nantes

class AssoNeedsTableViewCell: UITableViewCell {

    @IBOutlet weak var ui_tv_volunteers_description: NantesLabel!//TTTAttributedLabel!
    @IBOutlet weak var ui_tv_needs_description: NantesLabel!//TTTAttributedLabel!
    @IBOutlet weak var ui_tv_accept_needs: UILabel!
    @IBOutlet weak var ui_tv_accept_volunteers: UILabel!
    @IBOutlet weak var ui_view_volunteers: UIView!
    @IBOutlet weak var ui_view_needs: UIView!
    @IBOutlet weak var ui_tv_needs: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_tv_needs.text = "title_asso_needs".localized
        ui_tv_accept_needs.text = "title_asso_accept_needs".localized
        ui_tv_accept_volunteers.text = "title_asso_accept_volunteers".localized
    }

    func populateCell(donationsDescription:String?,volunteersDesription:String?) {
        
        setupLinksForLabel(_label: ui_tv_volunteers_description)
        setupLinksForLabel(_label: ui_tv_needs_description)
        
        if let _desc = donationsDescription, _desc.count > 0 {
            ui_view_needs.isHidden = false
            ui_tv_needs_description.text = _desc
        }
        else {
            ui_view_needs.isHidden = true
        }
        
        if let _desc = volunteersDesription, _desc.count > 0 {
            ui_view_volunteers.isHidden = false
            ui_tv_volunteers_description.text = _desc
        }
        else {
            ui_view_volunteers.isHidden = true
        }
    }
    
    func setupLinksForLabel(_label: NantesLabel) {
        _label.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link
        _label.linkAttributes = [NSAttributedString.Key.foregroundColor : UIColor.appOrange as Any]
        _label.delegate = self
    }

}

extension AssoNeedsTableViewCell: NantesLabelDelegate {
    func attributedLabel(_ label: NantesLabel, didSelectLink link: URL) {
        UIApplication.shared.open(link, options: [:], completionHandler: nil)
    }
}

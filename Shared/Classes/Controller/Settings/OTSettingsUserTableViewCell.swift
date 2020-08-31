//
//  OTSettingsUserTableViewCell.swift
//  entourage
//
//  Created by Jr on 22/07/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTSettingsUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ui_image_user: UIImageView!
    @IBOutlet weak var ui_image_user_badge: UIImageView!
    @IBOutlet weak var ui_label_name: UILabel!
    @IBOutlet weak var ui_label_mod_profile: UILabel!
    
    @IBOutlet weak var ui_view_events: UIView!
    @IBOutlet weak var ui_label_nb_events: UILabel!
    @IBOutlet weak var ui_label_events_title: UILabel!
    @IBOutlet weak var ui_view_button_event: UIView!
    @IBOutlet weak var ui_label_button_event: UILabel!
    
    @IBOutlet weak var ui_view_actions: UIView!
    @IBOutlet weak var ui_label_nb_actions: UILabel!
    @IBOutlet weak var ui_label_actions_title: UILabel!
    @IBOutlet weak var ui_view_button_ection: UIView!
    @IBOutlet weak var ui_label_button_action: UILabel!
    
    weak var delegate:TapMenuProfileDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_image_user.layer.cornerRadius = ui_image_user.frame.width / 2
        ui_label_mod_profile.text = OTLocalisationService.getLocalizedValue(forKey: "modMyProfile")
        ui_label_mod_profile.underline()
        
        
        ui_label_events_title.text = OTLocalisationService.getLocalizedValue(forKey: "event_title")
        ui_label_actions_title.text = OTLocalisationService.getLocalizedValue(forKey: "action_title")
        ui_label_button_event.text = OTLocalisationService.getLocalizedValue(forKey: "event_button_title")
        ui_label_button_action.text = OTLocalisationService.getLocalizedValue(forKey: "action_button_title")
        
        roundPartielView(view: ui_view_events, isTop: true)
        roundPartielView(view: ui_view_actions, isTop: true)
        roundPartielView(view: ui_view_button_event, isTop: false)
        roundPartielView(view: ui_view_button_ection, isTop: false)
        
    }
    
    func roundPartielView(view:UIView,isTop:Bool) {
        let radius:CGFloat = 10
        if #available(iOS 11.0, *) {
            view.clipsToBounds = true
            view.layer.cornerRadius = radius
            view.layer.maskedCorners = isTop ? [.layerMinXMinYCorner, .layerMaxXMinYCorner] : [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        } else {
            view.clipsToBounds = true
            let pathTop = UIBezierPath(roundedRect: view.bounds,
                                       byRoundingCorners: [.topRight, .topLeft],
                                       cornerRadii: CGSize(width: radius, height: radius))
            let pathBottom = UIBezierPath(roundedRect: view.bounds,
                                          byRoundingCorners: [.topRight, .topLeft],
                                          cornerRadii: CGSize(width: radius, height: radius))
            
            let maskLayer = CAShapeLayer()
            
            maskLayer.path = isTop ? pathTop.cgPath : pathBottom.cgPath
            view.layer.mask = maskLayer
        }
    }
    
    func populateCell(currentUser:OTUser, delegate:TapMenuProfileDelegate) {
        self.delegate = delegate
        ui_label_name.text = currentUser.displayName
        ui_image_user.setup(fromUrl: currentUser.avatarURL, withPlaceholder: "user")
        
        if let _url = currentUser.partner?.smallLogoUrl {
            ui_image_user_badge.isHidden = false
            ui_image_user_badge.setup(fromUrl: _url, withPlaceholder: "badgeDefault")
        }
        else {
            ui_image_user_badge.isHidden = true
        }
        
        ui_label_nb_events.text = "\(currentUser.eventsCount)"
        ui_label_nb_actions.text = "\(currentUser.actionsCount)"
    }
    
    //MARK: - IBActions -
    @IBAction func action_show_profile(_ sender: Any) {
        delegate?.showProfile()
    }
    
    @IBAction func action_edit_profile(_ sender: Any) {
        delegate?.editProfile()
    }
    
    @IBAction func action_show_all(_ sender: Any) {
        delegate?.showAll()
    }
    
    @IBAction func action_show_events(_ sender: Any) {
        delegate?.showEvents()
    }
}

    //MARK: - TapMenuProfileDelegate -
protocol TapMenuProfileDelegate:class {
    func showProfile()
    func editProfile()
    func showEvents()
    func showAll()
}
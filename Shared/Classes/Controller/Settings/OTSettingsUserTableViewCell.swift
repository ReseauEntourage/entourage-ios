//
//  OTSettingsUserTableViewCell.swift
//  entourage
//
//  Created by Jr on 22/07/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit

class OTSettingsUserTableViewCell: UITableViewCell {
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_image_user: UIImageView!
    @IBOutlet weak var ui_image_user_badge: UIImageView!
    @IBOutlet weak var ui_label_name: UILabel!
    @IBOutlet weak var ui_label_mod_profile: UILabel!
    @IBOutlet weak var ui_button_image_profile: UIButton!
    @IBOutlet weak var ui_button_profile: UIButton!
    
    
    
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
    
    @IBOutlet weak var ui_view_choice_mode: UIView!
    @IBOutlet weak var ui_title_home_mode: UILabel!
    @IBOutlet weak var ui_view_choice_bis: UIView!
    @IBOutlet weak var ui_switch_home_mode: UISwitch!
    @IBOutlet weak var ui_title_info_account: UILabel!
    @IBOutlet weak var ui_description_info_account: UILabel!
    @IBOutlet weak var ui_constraint_height_view_choice_mode: NSLayoutConstraint!
    
    weak var delegate:TapMenuProfileDelegate? = nil
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_button_profile.accessibilityLabel = "Modifier profil"
        ui_button_image_profile.accessibilityLabel = "Afficher profil"
        
        
        ui_image_user.layer.cornerRadius = ui_image_user.frame.width / 2
        ui_label_mod_profile.text = OTLocalisationService.getLocalizedValue(forKey: "modMyProfile")
      //  ui_label_mod_profile.underline()
        
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "menu_info_title")
        ui_label_events_title.text = OTLocalisationService.getLocalizedValue(forKey: "event_title")
        ui_label_actions_title.text = OTLocalisationService.getLocalizedValue(forKey: "action_title")
        ui_label_button_event.text = OTLocalisationService.getLocalizedValue(forKey: "event_button_title")
        ui_label_button_action.text = OTLocalisationService.getLocalizedValue(forKey: "action_button_title")
        
        roundPartielView(view: ui_view_events, isTop: true)
        roundPartielView(view: ui_view_actions, isTop: true)
        roundPartielView(view: ui_view_button_event, isTop: false)
        roundPartielView(view: ui_view_button_ection, isTop: false)
        
        ui_label_mod_profile.layer.cornerRadius = 5
        ui_label_mod_profile.layer.borderWidth = 1
        ui_label_mod_profile.layer.borderColor = UIColor.appOrange()?.cgColor
        
        ui_view_choice_bis.layer.cornerRadius = 5
        ui_view_choice_bis.layer.borderWidth = 1
        ui_view_choice_bis.layer.borderColor = UIColor.appOrange()?.cgColor

        ui_title_info_account.text = OTLocalisationService.getLocalizedValue(forKey: "setting_home_title")
        ui_title_home_mode.text = OTLocalisationService.getLocalizedValue(forKey: "setting_home_button_type")
        ui_description_info_account.text = OTLocalisationService.getLocalizedValue(forKey: "setting_home_description")
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
        
        
        var isExpertMode = false
        if let isExpertSettings = UserDefaults.standard.object(forKey: "isExpertMode") as? Bool {
            isExpertMode = isExpertSettings
        }
        else {
            if currentUser.isUserTypeNeighbour() {
                isExpertMode = currentUser.isEngaged
            }
            UserDefaults.standard.setValue(isExpertMode, forKey: "isExpertMode")
        }
        
        if currentUser.isUserTypeNeighbour() {
            ui_view_choice_mode.isHidden = false
            ui_constraint_height_view_choice_mode.constant = 188
        }
        else {
            isExpertMode = true
            ui_view_choice_mode.isHidden = true
            ui_constraint_height_view_choice_mode.constant = 0
        }
        ui_switch_home_mode.isOn = !isExpertMode
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
    
    @IBAction func action_change_home_mode(_ sender: UISwitch) {
        if !sender.isOn {
            OTLogger.logEvent(Action_Switch_NeoToExpert)
        }
        else {
            OTLogger.logEvent(Action_Switch_ExpertToNeo)
        }
        delegate?.changeExpertMode(isExpert: !sender.isOn)
    }
}

    //MARK: - TapMenuProfileDelegate -
protocol TapMenuProfileDelegate:AnyObject {
    func showProfile()
    func editProfile()
    func showEvents()
    func showAll()
    func changeExpertMode(isExpert:Bool)
}

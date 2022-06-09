//
//  HomeContribgCell.swift
//  entourage
//
//  Created by Jerome on 07/06/2022.
//

import UIKit

class HomeContribCell: UITableViewCell {
    
    @IBOutlet weak var ui_view_meetings: UIView!
    @IBOutlet weak var ui_iv_meetings: UIImageView!
    @IBOutlet weak var ui_meetings_count: UILabel!
    @IBOutlet weak var ui_meetings_title: UILabel!
    
    
    @IBOutlet weak var ui_view_messages: UIView!
    @IBOutlet weak var ui_messages_count: UILabel!
    @IBOutlet weak var ui_message_title: UILabel!
    
    @IBOutlet weak var ui_view_no_messages: UIView!
    @IBOutlet weak var ui_no_message_title: UILabel!
    
    @IBOutlet weak var ui_view_events: UIView!
    @IBOutlet weak var ui_events_count: UILabel!
    @IBOutlet weak var ui_events_title: UILabel!
    
    @IBOutlet weak var ui_view_no_events: UIView!
    @IBOutlet weak var ui_no_events_title: UILabel!
    
    @IBOutlet weak var ui_view_groups: UIView!
    @IBOutlet weak var ui_groups_count: UILabel!
    @IBOutlet weak var ui_groups_title: UILabel!
    
    @IBOutlet weak var ui_view_no_groups: UIView!
    @IBOutlet weak var ui_no_group_title: UILabel!
    
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setRadiusView(view: ui_view_meetings,radius: 20)
        setRadiusView(view: ui_view_events)
        setRadiusView(view: ui_view_no_events)
        setRadiusView(view: ui_view_groups)
        setRadiusView(view: ui_view_no_groups)
        setRadiusView(view: ui_view_messages)
        setRadiusView(view: ui_view_no_messages)
        
        ui_meetings_title.text = "home_meeting_title".localized
        ui_message_title.text = "home_messages_title".localized
        ui_no_message_title.text = "home_no_message_title".localized
        ui_groups_title.text = "home_groups_title".localized
        ui_no_group_title.text = "home_no_group_title".localized
        ui_events_title.text = "home_events_title".localized
        ui_no_events_title.text = "home_no_event_title".localized
        
        setStyle()
    }
    
    private func setStyle() {
        ui_messages_count.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_events_count.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_groups_count.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_meetings_count.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoBold(size: 30), color: .black))
        
        ui_message_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_message_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_events_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        ui_groups_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir())
        
        ui_no_message_title.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoLight(size: 10), color: .appGris112))
        ui_no_group_title.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoLight(size: 10), color: .appGris112))
        ui_no_events_title.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoLight(size: 10), color: .appGris112))
        
    }
    
   private func setRadiusView(view:UIView,radius:CGFloat = 14) {
       addShadowAndRadius(customView: view,radius: radius)
    }
    
    private func addShadowAndRadius(customView:UIView,radius:CGFloat) {
        customView.layer.cornerRadius = radius
        customView.layer.shadowColor = UIColor.appOrangeLight.withAlphaComponent(0.35).cgColor
        customView.layer.shadowOpacity = 1
        customView.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        customView.layer.shadowRadius = 4
        
        customView.layer.rasterizationScale = UIScreen.main.scale
        customView.layer.shouldRasterize = true
    }
    
    func populateCell(userHome:UserHome) {
        if userHome.meetingsCount == 0 {
            ui_iv_meetings.image = UIImage.init(named: "ic_heart_grey")
            ui_meetings_title.text = "home_no_meeting_title".localized
        }
        else {
            ui_iv_meetings.image = UIImage.init(named: "ic_heart_orange")
            ui_meetings_title.text = "home_meeting_title".localized
            ui_meetings_count.text = "\(userHome.meetingsCount)"
        }
        
        if userHome.chatMessagesCount == 0 {
            ui_view_no_messages.isHidden = false
            ui_view_messages.isHidden = true
        }
        else {
            ui_view_no_messages.isHidden = true
            ui_view_messages.isHidden = false
            ui_messages_count.text = "\(userHome.chatMessagesCount)"
        }
        
        if userHome.outingParticipationsCount == 0 {
            ui_view_no_events.isHidden = false
            ui_view_events.isHidden = true
        }
        else {
            ui_view_no_events.isHidden = true
            ui_view_events.isHidden = false
            ui_events_count.text = "\(userHome.outingParticipationsCount)"
        }
        
        if userHome.neighborhoodParticipationsCount == 0 {
            ui_view_no_groups.isHidden = false
            ui_view_groups.isHidden = true
        }
        else {
            ui_view_no_groups.isHidden = true
            ui_view_groups.isHidden = false
            ui_groups_count.text = "\(userHome.neighborhoodParticipationsCount)"
        }
    }
    
}

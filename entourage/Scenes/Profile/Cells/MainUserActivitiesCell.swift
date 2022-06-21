//
//  MainUserActivitiesCell.swift
//  entourage
//
//  Created by Jerome on 09/03/2022.
//

import UIKit

class MainUserActivitiesCell: UITableViewCell {
    
    @IBOutlet weak var ui_title_other_user: UILabel!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_view_events: UIView!
    
    @IBOutlet weak var ui_view_actions: UIView!
    
    @IBOutlet weak var ui_iv_events: UIImageView!
    @IBOutlet weak var ui_events_count: UILabel!
    @IBOutlet weak var ui_events_title: UILabel!
    
    @IBOutlet weak var ui_iv_actions: UIImageView!
    @IBOutlet weak var ui_actions_count: UILabel!
    @IBOutlet weak var ui_actions_title: UILabel!
    
    @IBOutlet weak var ui_view_member: UIView!
    @IBOutlet weak var ui_member_title: UILabel!
    @IBOutlet weak var ui_member_date: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addShadowAndRadius(customView: ui_view_member)
        addShadowAndRadius(customView: ui_view_events)
        addShadowAndRadius(customView: ui_view_actions)
        
        ui_member_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15, color: .black))
        ui_member_date.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 15))
        ui_member_title.text = "memberSince".localized
        
        ui_title?.font = ApplicationTheme.getFontH2Noir().font
        ui_title?.textColor = ApplicationTheme.getFontH2Noir().color
        ui_title?.text = "mainUserTitleActivity".localized
        
        ui_title_other_user?.font = ApplicationTheme.getFontH2Noir().font
        ui_title_other_user?.textColor = ApplicationTheme.getFontH2Noir().color
        ui_title_other_user?.text = "detail_user_his_activity".localized
        
        ui_actions_title.text = "mainUserTitleActions".localized
        textColor(label: ui_actions_title, isEmpty: true, isCount: false)
        
        ui_events_title.text = "mainUserTitleEvents".localized
        textColor(label: ui_events_title, isEmpty: true, isCount: false)
        ui_events_count.text = "0"
        textColor(label: ui_events_count, isEmpty: true, isCount: true)
        ui_actions_count.text = "0"
        textColor(label: ui_actions_count, isEmpty: true, isCount: true)
    }
    
    func populateCell(isMe:Bool ,eventCount:Int,actionsCount:Int) {
        
        if isMe {
            ui_title_other_user?.text = "mainUserTitleActivity".localized
        }
        else {
            ui_title_other_user?.text = "detail_user_his_activity".localized
        }
        
        if eventCount == 0 {
            textColor(label: ui_events_title, isEmpty: true, isCount: false)
            textColor(label: ui_events_count, isEmpty: true, isCount: true)
        }
        else {
            textColor(label: ui_events_title, isEmpty: false, isCount: false)
            textColor(label: ui_events_count, isEmpty: false, isCount: true)
        }
        
        if actionsCount == 0 {
            textColor(label: ui_actions_title, isEmpty: true, isCount: false)
            textColor(label: ui_actions_count, isEmpty: true, isCount: true)
        }
        else {
            textColor(label: ui_actions_title, isEmpty: false, isCount: false)
            textColor(label: ui_actions_count, isEmpty: false, isCount: true)
        }
        
        ui_events_count.text = "\(eventCount)"
        ui_actions_count.text = "\(actionsCount)"
    }
    
    private func addShadowAndRadius(customView:UIView) {
        customView.layer.cornerRadius = 16
        customView.layer.shadowColor = UIColor.appOrangeLight.withAlphaComponent(0.25).cgColor
        customView.layer.shadowOpacity = 1
        customView.layer.shadowOffset = CGSize.init(width: 1, height: 1)
        customView.layer.shadowRadius = 4
        
        customView.layer.rasterizationScale = UIScreen.main.scale
        customView.layer.shouldRasterize = true
    }
    
    private func textColor(label:UILabel, isEmpty:Bool,isCount:Bool) {
        if isEmpty {
            label.textColor = .appOrangeLight
        }
        else {
            label.textColor = .black
        }
        
        if isCount {
            label.font = ApplicationTheme.getFontQuickSandBold(size: 16)
        }
        else {
            label.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        }
    }
}

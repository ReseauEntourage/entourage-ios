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
    @IBOutlet weak var ui_view_groups: UIView!
    @IBOutlet weak var ui_view_outings: UIView!
    
    @IBOutlet weak var ui_iv_groups: UIImageView!
    @IBOutlet weak var ui_groups_count: UILabel!
    @IBOutlet weak var ui_groups_title: UILabel!
    
    @IBOutlet weak var ui_iv_outings: UIImageView!
    @IBOutlet weak var ui_outings_count: UILabel!
    @IBOutlet weak var ui_outings_title: UILabel!
    
    @IBOutlet weak var ui_view_member: UIView!
    @IBOutlet weak var ui_member_title: UILabel!
    @IBOutlet weak var ui_member_date: UILabel!
    
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        addShadowAndRadius(customView: ui_view_member)
        addShadowAndRadius(customView: ui_view_groups)
        addShadowAndRadius(customView: ui_view_outings)
        
        ui_member_title.setupFontAndColor(style: ApplicationTheme.getFontCourantRegularNoir(size: 15, color: .black))
        ui_member_date.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir(size: 15))
        ui_member_title.text = "memberSince".localized
        
        ui_title?.font = ApplicationTheme.getFontH2Noir().font
        ui_title?.textColor = ApplicationTheme.getFontH2Noir().color
        ui_title?.text = "mainUserTitleActivity".localized
        
        ui_title_other_user?.font = ApplicationTheme.getFontH2Noir().font
        ui_title_other_user?.textColor = ApplicationTheme.getFontH2Noir().color
        ui_title_other_user?.text = "detail_user_his_activity".localized
        
        ui_outings_title.text = "mainUserTitleOutings".localized
        textColor(label: ui_outings_title, isCount: false)
        
        ui_groups_title.text = "mainUserTitleGroups".localized
        textColor(label: ui_groups_title, isCount: false)
        ui_groups_count.text = "0"
        textColor(label: ui_groups_count, isCount: true)
        ui_outings_count.text = "0"
        textColor(label: ui_outings_count, isCount: true)
    }
    
    func populateCell(isMe:Bool ,neighborhoodsCount:Int,outingsCount:Int,myDate:Date?) {
        
        if isMe {
            ui_title_other_user?.text = "mainUserTitleActivity".localized
        }
        else {
            ui_title_other_user?.text = "detail_user_his_activity".localized
        }
        
        ui_outings_title.text = outingsCount <= 1 ? "mainUserTitleOuting".localized : "mainUserTitleOutings".localized
        ui_groups_title.text = neighborhoodsCount <= 1 ? "mainUserTitleGroup".localized : "mainUserTitleGroups".localized
        
        if neighborhoodsCount == 0 {
            textColor(label: ui_groups_title, isCount: false)
            textColor(label: ui_groups_count, isCount: true)
        }
        else {
            textColor(label: ui_groups_title,  isCount: false)
            textColor(label: ui_groups_count,  isCount: true)
        }
        
        if outingsCount == 0 {
            textColor(label: ui_outings_title, isCount: false)
            textColor(label: ui_outings_count, isCount: true)
        }
        else {
            textColor(label: ui_outings_title, isCount: false)
            textColor(label: ui_outings_count, isCount: true)
        }
        
        ui_groups_count.text = "\(neighborhoodsCount)"
        ui_outings_count.text = "\(outingsCount)"
        
        let dateFormat = DateFormatter()
        dateFormat.locale = Locale.getPreferredLocale()
        dateFormat.dateFormat = "MM/YYYY"
        if let _date = myDate {
            ui_member_date.text = dateFormat.string(from: _date)
        }else{
            ui_member_date.text = ""
        }
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
    
    private func textColor(label:UILabel,isCount:Bool) {

        label.textColor = .black
        
        if isCount {
            label.font = ApplicationTheme.getFontQuickSandBold(size: 16)
        }
        else {
            label.font = ApplicationTheme.getFontNunitoRegular(size: 13)
        }
    }
}

//
//  MainStatUserCell.swift
//  entourage
//
//  Created by Clement entourage on 28/01/2025.
//

import Foundation
import UIKit

class MainStatUserCell:UITableViewCell {
    
    //OUTLET
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_groups_count: UILabel!
    @IBOutlet weak var ui_groups_title: UILabel!
    
    @IBOutlet weak var ui_outings_count: UILabel!
    @IBOutlet weak var ui_outings_title: UILabel!
  
    @IBOutlet weak var ui_member_title: UILabel!
    @IBOutlet weak var ui_member_date: UILabel!
    //VARIABLE
    class var identifier: String {
        return String(describing: self)
    }
    
    
    
    override func awakeFromNib() {
        
    }
    
    func populate(){
        
    }
    
    func populateCell(isMe:Bool ,neighborhoodsCount:Int,outingsCount:Int,myDate:Date?) {
        
        if isMe {
            ui_title?.text = "mainUserTitleActivity".localized
        }
        else {
            ui_title?.text = "detail_user_his_activity".localized
        }
        ui_title.setFontTitle(size: 15)
        
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
        ui_member_date.setFontBody(size: 15)
        ui_member_date.setFontTitle(size: 15)
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

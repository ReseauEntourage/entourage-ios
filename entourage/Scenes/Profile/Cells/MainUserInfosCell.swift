//
//  MainUserInfosCell.swift
//  entourage
//
//  Created by Jerome on 09/03/2022.
//

import UIKit

class MainUserInfosCell: UITableViewCell {
    
    @IBOutlet weak var ui_title: UILabel!
    
    @IBOutlet weak var ui_birth_title: UILabel!
    @IBOutlet weak var ui_birth_info: UILabel!
    
    @IBOutlet weak var ui_phone_title: UILabel!
    @IBOutlet weak var ui_phone_info: UILabel!
    
    @IBOutlet weak var ui_email_title: UILabel!
    @IBOutlet weak var ui_email_info: UILabel!
    
    @IBOutlet weak var ui_city_title: UILabel!
    @IBOutlet weak var ui_city_info: UILabel!
    
    @IBOutlet weak var ui_radius_title: UILabel!
    @IBOutlet weak var ui_radius_desc: UILabel!
    @IBOutlet weak var ui_radius_min: UILabel!
    @IBOutlet weak var ui_radius_max: UILabel!
    @IBOutlet weak var ui_radius_current: UILabel!
    
    
    @IBOutlet weak var ui_constraint_current_km_leading: NSLayoutConstraint!
    @IBOutlet weak var ui_view_progress: ProgressRadiusView!
    
    let minRadius = 1
    let maxRadius = 200
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.text = "mainUserTitleInfos".localized
        ui_birth_title.text = "mainUserTitleBirth".localized
        ui_phone_title.text = "mainUserTitlePhone".localized
        ui_email_title.text = "mainUserTitleEmail".localized
        ui_city_title.text = "mainUserTitleCity".localized
        
        ui_radius_title.text = "mainUserTitleRadius".localized
        ui_radius_desc.text = "mainUserDescRadius".localized
        ui_radius_min.text = "\(minRadius) \("km".localized)"
        ui_radius_max.text = "\(maxRadius) \("km".localized)"
        
        setupLabels()
    }
    
    private func setupLabels() {
        ui_title.font = ApplicationTheme.getFontSportStyle().font
        ui_title.textColor = ApplicationTheme.getFontSportStyle().color
        
        ui_radius_title.font = ApplicationTheme.getFontH6().font
        ui_radius_title.textColor = ApplicationTheme.getFontH6().color
        ui_radius_desc.font = ApplicationTheme.getFontH6().font
        ui_radius_desc.textColor = ApplicationTheme.getFontH6().color
        
        setLabelTitle(label: ui_birth_title)
        setLabelTitle(label: ui_phone_title)
        setLabelTitle(label: ui_email_title)
        setLabelTitle(label: ui_city_title)
        
        setLabelInfo(label: ui_birth_info)
        setLabelInfo(label: ui_phone_info)
        setLabelInfo(label: ui_email_info)
        setLabelInfo(label: ui_city_info)
        setLabelInfo(label: ui_radius_min)
        setLabelInfo(label: ui_radius_max)
    }
    
    private func setLabelTitle(label:UILabel) {
        label.font = ApplicationTheme.getFontH5().font
        label.textColor = ApplicationTheme.getFontH5().color
    }
    
    private func setLabelInfo(label:UILabel) {
        label.font = ApplicationTheme.getFontTextRegular().font
        label.textColor = ApplicationTheme.getFontTextRegular().color
    }
    
    func populateCell(user:User) {
        
        ui_birth_info.text = user.birthday ?? "mainUserBirthPlaceholder".localized
        ui_phone_info.text = user.phone
        ui_email_info.text = user.email ?? "mainUserEmailPlaceholder".localized
        ui_city_info.text = user.addressPrimary?.displayAddress
        
        let currentRadius = user.radiusDistance 
        let percentProgress = (Float(currentRadius) / Float(maxRadius)) * 100
        
        ui_radius_current.text = "\(currentRadius) \("km".localized)"
        ui_view_progress.progressPercent = CGFloat(percentProgress)
        ui_view_progress.setNeedsDisplay()
        let pos = ui_view_progress.getPercentScreenPosition()
        
        ui_constraint_current_km_leading.constant = pos - (ui_radius_current.intrinsicContentSize.width / 2)
    }
}

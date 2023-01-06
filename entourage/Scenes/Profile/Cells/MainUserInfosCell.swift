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
    
    @IBOutlet weak var ui_lb_radius: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title.text = "mainUserTitleInfos".localized
        ui_birth_title.text = "mainUserTitleBirth".localized
        ui_phone_title.text = "mainUserTitlePhone".localized
        ui_email_title.text = "mainUserTitleEmail".localized
        ui_city_title.text = "mainUserTitleCity".localized
        
        setupLabels()
    }
    
    private func setupLabels() {
        ui_title.font = ApplicationTheme.getFontH2Noir().font
        ui_title.textColor = ApplicationTheme.getFontH2Noir().color
        
        setLabelTitle(label: ui_birth_title)
        setLabelTitle(label: ui_phone_title)
        setLabelTitle(label: ui_email_title)
        setLabelTitle(label: ui_city_title)
        
        setLabelInfo(label: ui_birth_info)
        setLabelInfo(label: ui_phone_info)
        setLabelInfo(label: ui_email_info)
        setLabelInfo(label: ui_city_info)
    }
    
    private func setLabelTitle(label:UILabel) {
        label.font = ApplicationTheme.getFontRegular13Orange().font
        label.textColor = ApplicationTheme.getFontRegular13Orange().color
    }
    
    private func setLabelInfo(label:UILabel) {
        label.font = ApplicationTheme.getFontCourantRegularNoir().font
        label.textColor = ApplicationTheme.getFontCourantRegularNoir().color
    }
    
    func populateCell(user:User) {
        
        //Set placholder if !birthday
        if let _birthday = user.birthday {
            ui_birth_info.text = _birthday
        }else{
            ui_birth_info.text = "mainUserBirthPlaceholder".localized
            ui_birth_info.textColor = ApplicationTheme.getFontCourantRegularGris().color
        }
        
        //set placeholder if !email
        if let _email = user.email {
            ui_email_info.text = _email
        }else{
            ui_email_info.text = "mainUserEmailPlaceholder".localized
            ui_email_info.textColor = ApplicationTheme.getFontCourantRegularGris().color
        }
        
//        ui_birth_info.text = user.birthday ?? "mainUserBirthPlaceholder".localized
//        ui_email_info.text = user.email ?? "mainUserEmailPlaceholder".localized
        ui_phone_info.text = user.phone
        ui_city_info.text = user.addressPrimary?.displayAddress
        
        let currentRadius = user.radiusDistance ?? 0
        let str = String.init(format: "mainUserCityRadius".localized, currentRadius)
        let strBoldColor = String.init(format: "mainUserCityRadiusBold".localized, currentRadius)
        
        let strAttr = Utils.formatString(messageTxt: str, messageTxtHighlight: strBoldColor, fontColorType: ApplicationTheme.getFontLegend(), fontColorTypeHighlight: ApplicationTheme.getFontBoutonOrange(size: 13))
        
        ui_lb_radius.attributedText = strAttr
    }
}

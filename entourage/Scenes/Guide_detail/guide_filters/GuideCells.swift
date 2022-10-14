//
//  OTGuideCells.swift
//  entourage
//
//  Created by Jr on 18/09/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit


class GuideFilterCell: UITableViewCell {
    
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_label_title: UILabel!
    @IBOutlet weak var ui_switch: UISwitch?
    
    func populateCell(item:GuideFilterItem,position:Int,isAllActive:Bool) {
        
        var isOnTxt = item.active ? " ✔" : ""
        
        if item.active {
            ui_label_title.font = UIFont.boldSystemFont(ofSize: 15)
        }
        else {
            ui_label_title.font = UIFont.systemFont(ofSize: 15)
        }
        
        if isAllActive {
            isOnTxt = ""
            ui_label_title.font = UIFont.systemFont(ofSize: 15)
        }
        
        ui_label_title.text = item.title + isOnTxt
        
        ui_image.image = UIImage.init(named: item.image)
    }
    
    func populateCell(item:GuideFilterItem) {
        ui_label_title.text = item.title
        ui_image.image = UIImage.init(named: item.image)
    }
    
}

class GuideTopFilterCell: UITableViewCell {
    
    @IBOutlet weak var ui_title_info_multi: UILabel!
    @IBOutlet weak var ui_view_doante: UIView!
    @IBOutlet weak var ui_view_volunteer: UIView!
    @IBOutlet weak var ui_image_partner: UIImageView!
    @IBOutlet weak var ui_label_title_partner: UILabel!
    
    @IBOutlet weak var ui_label_title_donated: UILabel!
    @IBOutlet weak var ui_label_title_volunteer: UILabel!
    
    weak var delegate:ChangeFilterGDSDelegate? = nil
    
    func populateCell(isPartnerOn:Bool, isDonatedOn:Bool, isVolunteerOn:Bool, delegate:ChangeFilterGDSDelegate,isAllActive:Bool) {
    
        let fontBold = UIFont.boldSystemFont(ofSize: 15)
        let fontRegular = UIFont.systemFont(ofSize: 15)
        let isOnTxt = isAllActive ? "" : " ✔"
        
        
        ui_title_info_multi.text = "guide_display_info_mutli".localized
        
        if isPartnerOn && !isAllActive {
            ui_label_title_partner.font = fontBold
        }
        else {
            ui_label_title_partner.font = fontRegular
        }
        ui_image_partner.image = UIImage.init(named: "picto_cat_filter-8")
        let _addTxt = isPartnerOn ? isOnTxt : ""
        ui_label_title_partner.text = "guide_display_partners".localized + _addTxt
        
        
        
        if isDonatedOn && !isAllActive {
            ui_label_title_donated.font = fontBold
        }
        else {
            ui_label_title_donated.font = fontRegular
        }
        
        let _add1Txt = isDonatedOn ? isOnTxt : ""
        ui_label_title_donated.text = "guide_display_donate".localized + _add1Txt
        
        
        
        if isVolunteerOn && !isAllActive {
            ui_label_title_volunteer.font = fontBold
        }
        else {
            ui_label_title_volunteer.font = fontRegular
        }
        
        let _add2Txt = isVolunteerOn ? isOnTxt : ""
        ui_label_title_volunteer.text = "guide_display_volunteer".localized + _add2Txt
        
        self.delegate = delegate
    }
    
    @IBAction func action_select_partners(_ sender: Any) {
        delegate?.changeTop(1)
    }
    @IBAction func action_select_donate(_ sender: Any) {
        delegate?.changeTop(2)
    }
    @IBAction func action_select_volunteer(_ sender: Any) {
        delegate?.changeTop(3)
    }
}

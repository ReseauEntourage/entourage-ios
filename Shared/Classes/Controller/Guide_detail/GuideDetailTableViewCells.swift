//
//  GuideDetailTableViewCells.swift
//  entourage
//
//  Created by Jr on 02/10/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import Foundation


//MARK: - OTGuideDetailTopTableViewCell -
class OTGuideDetailTopTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    @IBOutlet weak var ui_picto_1: UIImageView!
    @IBOutlet weak var ui_picto_2: UIImageView!
    @IBOutlet weak var ui_picto_3: UIImageView!
    @IBOutlet weak var ui_picto_4: UIImageView!
    @IBOutlet weak var ui_picto_5: UIImageView!
    @IBOutlet weak var ui_picto_6: UIImageView!
    
    func populateCell(poi:OTPoi) {
        ui_title.text = poi.name
        ui_description.text = poi.details
        
        for i in 0...5 {
            getPicto(position: i)?.isHidden = true
        }
        
        for i in 0..<poi.categories_id.count {
            getPicto(position: i)?.isHidden = false
            if let _catId = poi.categories_id[i] as? NSNumber {
                let imageName = String.init(format: "picto_cat_filter-%d", _catId.intValue)
                getPicto(position: i)?.image = UIImage(named: imageName)
            }
        }
    }
    
    func getPicto(position:Int) -> UIImageView? {
        switch position {
        case 0:
            return ui_picto_1
        case 1:
            return ui_picto_2
        case 2:
            return ui_picto_3
        case 3:
            return ui_picto_4
        case 4:
            return ui_picto_5
        case 5:
            return ui_picto_6
        default:
            return nil
        }
    }
}

//MARK: - OTGuideDetailPublicTableViewCell -
class OTGuideDetailPublicTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_description: UILabel!
    
    func populateCell(description:String) {
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "DetailPoiPublic")
        ui_description.text = description
    }
}

//MARK: - OTGuideDetailContactTableViewCell -
class OTGuideDetailContactTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_view_phone: UIView!
    @IBOutlet weak var ui_button_phone: UIButton!
    @IBOutlet weak var ui_view_mail: UIView!
    @IBOutlet weak var ui_button_mail: UIButton!
    @IBOutlet weak var ui_view_web: UIView!
    @IBOutlet weak var ui_button_web: UIButton!
    @IBOutlet weak var ui_view_location: UIView!
    @IBOutlet weak var ui_button_location: UIButton!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        let buttons = [ui_button_mail,ui_button_phone,ui_button_web,ui_button_location]
        
        for button in buttons {
            button?.setTitleColor(ApplicationTheme.shared().primaryNavigationBarTintColor, for: .normal)
        }
    }
    
    func populateCell(poi:OTPoi) {
        ui_title.text = OTLocalisationService.getLocalizedValue(forKey: "DetailPoiContact")
        
        
        if poi.address != nil && poi.address.count > 0 {
            ui_view_location.isHidden = false
            ui_button_location.setTitle(poi.address, for: .normal)
        }
        else {
            ui_view_location.isHidden = true
        }
        
        if poi.phone != nil && poi.phone.count > 0 {
            ui_view_phone.isHidden = false
            let _phone = poi.phone ?? "-"
            ui_button_phone.setTitle("Tel: \(_phone)", for: .normal)
        }
        else {
            ui_view_phone.isHidden = true
        }
        
        if poi.email != nil && poi.email.count > 0 {
            ui_view_mail.isHidden = false
            ui_button_mail.setTitle(poi.email, for: .normal)
        }
        else {
            ui_view_mail.isHidden = true
        }
        
        if poi.website != nil && poi.website.count > 0 {
            ui_view_web.isHidden = false
            ui_button_web.setTitle(poi.website, for: .normal)
        }
        else {
            ui_view_web.isHidden = true
        }
    }
}

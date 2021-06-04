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
    
    @IBOutlet weak var ui_picto_sapce_1: UIImageView!
    @IBOutlet weak var ui_picto_sapce_2: UIImageView!
    @IBOutlet weak var ui_picto_sapce_3: UIImageView!
    @IBOutlet weak var ui_picto_sapce_4: UIImageView!
    @IBOutlet weak var ui_picto_sapce_5: UIImageView!
    @IBOutlet weak var ui_picto_sapce_6: UIImageView!
    
    
    func populateCell(poi:OTPoi) {
        ui_title.text = poi.name
        ui_description.text = poi.details
        
        for i in 0...5 {
            getPicto(position: i)?.isHidden = true
            getPictoSpacer(position: i)?.isHidden = true
        }
        
        for i in 0..<poi.categories_id.count {
            getPicto(position: i)?.isHidden = false
            getPictoSpacer(position: i)?.isHidden = false
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
    
    func getPictoSpacer(position:Int) -> UIImageView? {
        switch position {
        case 0:
            return ui_picto_sapce_1
        case 1:
            return ui_picto_sapce_2
        case 2:
            return ui_picto_sapce_3
        case 3:
            return ui_picto_sapce_4
        case 4:
            return ui_picto_sapce_5
        case 5:
            return ui_picto_sapce_6
        default:
            return nil
        }
    }
}

//MARK: - OTGuideDetailPublicTableViewCell -
class OTGuideDetailSoliguideTopTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_info1: UILabel!
    @IBOutlet weak var ui_info2: UILabel!
    @IBOutlet weak var ui_info_button: UILabel!
    @IBOutlet weak var ui_view_button: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_view_button.layer.cornerRadius = 10
        
        ui_info1.text = OTLocalisationService.getLocalizedValue(forKey: "info_soliguide_1")
        ui_info2.text = OTLocalisationService.getLocalizedValue(forKey: "info_soliguide_2")
        ui_info_button.text = OTLocalisationService.getLocalizedValue(forKey: "info_button_soliguide_consult")?.uppercased()
    }
}
//MARK: - OTGuideDetailSoliguideTableViewCell -
class OTGuideDetailSoliguideTableViewCell: UITableViewCell {
    @IBOutlet weak var ui_title_public: UILabel!
    @IBOutlet weak var ui_description_public: UILabel!
    @IBOutlet weak var ui_title_open_time: UILabel!
    @IBOutlet weak var ui_description_open_time: UILabel!
    @IBOutlet weak var ui_title_language: UILabel!
    @IBOutlet weak var ui_description_language: UILabel!
    
    @IBOutlet weak var ui_view_public: UIView!
    @IBOutlet weak var ui_view_language: UIView!
    @IBOutlet weak var ui_view_open_time: UIView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        ui_title_public.text = OTLocalisationService.getLocalizedValue(forKey: "DetailPoiPublic")
        ui_title_language.text = OTLocalisationService.getLocalizedValue(forKey: "DetailPoiLanguage")
        ui_title_open_time.text = OTLocalisationService.getLocalizedValue(forKey: "DetailPoiOpenTime")
    }
    
    func populateCell(publicTxt:String?,openTimeTxt:String?,languageTxt:String?) {
       
        ui_view_public.isHidden = publicTxt?.count ?? 0 > 0 ? false : true
        ui_description_public.text = publicTxt
        
        ui_view_language.isHidden = languageTxt?.count ?? 0 > 0 ? false : true
        ui_description_language.text = languageTxt
        
        ui_view_open_time.isHidden = openTimeTxt?.count ?? 0 > 0 ? false : true
        ui_description_open_time.text = openTimeTxt
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
            button?.setTitleColor(ApplicationTheme.shared().secondaryNavigationBarTintColor, for: .normal)
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

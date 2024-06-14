//
//  NeighborhoodHomeGroup.swift
//  entourage
//
//  Created by Jerome on 22/04/2022.
//

import UIKit

class NeighborhoodHomeGroupCell: UITableViewCell {

    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_members: UILabel!
    @IBOutlet weak var ui_events: UILabel!
    
    @IBOutlet weak var ui_picto_1: UIImageView!
    @IBOutlet weak var ui_picto_2: UIImageView!
    @IBOutlet weak var ui_picto_3: UIImageView!
    @IBOutlet weak var ui_picto_4: UIImageView!
    @IBOutlet weak var ui_picto_5: UIImageView!
    @IBOutlet weak var ui_picto_6: UIImageView!
    @IBOutlet weak var ui_picto_7: UIImageView!
    @IBOutlet weak var ui_picto_8: UIImageView!
    @IBOutlet weak var ui_picto_9: UIImageView!
    @IBOutlet weak var ui_picto_10: UIImageView!
    @IBOutlet weak var ui_label_news: UILabel!
    
    @IBOutlet weak var ui_label_admin: UILabel?
    class var identifier: String {
        return String(describing: self)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        hidePictos()
        
        ui_title.setupFontAndColor(style: ApplicationTheme.getFontCourantBoldNoir())
        ui_members.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        ui_events.setupFontAndColor(style: ApplicationTheme.getFontLegendGris())
        
        ui_label_admin?.setupFontAndColor(style: MJTextFontColorStyle(font: ApplicationTheme.getFontNunitoRegular(size: 15), color: .appOrangeLight))
        ui_label_admin?.text = "Admin".localized
        
        ui_image.layer.cornerRadius = 20
    }
    
    func populateCell(neighborhood:Neighborhood) {
        ui_title.text = neighborhood.name
        
        if let _unreadPostCount = neighborhood.unreadPostCount {
            var numberOfPost = ""
            if _unreadPostCount > 0 {
                self.ui_label_news.isHidden = false
                if _unreadPostCount > 9 {
                    numberOfPost = "+9"
                }else{
                    numberOfPost = String(_unreadPostCount)
                }
            }else{
                self.ui_label_news.isHidden = true
            }
        }else{
            self.ui_label_news.isHidden = true
        }
        
        if let imageUrl = neighborhood.image_url, !imageUrl.isEmpty, let mainUrl = URL(string: imageUrl) {
            ui_image.sd_setImage(with: mainUrl, placeholderImage: UIImage.init(named: "placeholder_photo_group"))
        }
        else {
            ui_image.image = UIImage.init(named: "placeholder_photo_group")
        }
        
        if neighborhood.future_outings_count > 1 {
            ui_events.text = String.init(format: "neighborhood_main_page_events_future_plural".localized, neighborhood.future_outings_count)
        }
        else {
            ui_events.text = String.init(format: "neighborhood_main_page_events_future_single".localized, neighborhood.future_outings_count)
        }
        if neighborhood.membersCount > 1 {
            ui_members.text = String.init(format: "neighborhood_main_page_members".localized, neighborhood.membersCount)
        }
        else {
            
            ui_members.text = String.init(format: "neighborhood_main_page_member".localized, neighborhood.membersCount)
        }
        
        hidePictos()
        
//        if let interests = neighborhood.interests {
//            for interest in interests {
//                switch interest {
//                case "activites":
//                    ui_picto_3.isHidden = false
//                case "animaux":
//                    ui_picto_6.isHidden = false
//                case "bien-etre":
//                    ui_picto_2.isHidden = false
//                case "other":
//                    ui_picto_7.isHidden = false
//                case "culture":
//                    ui_picto_5.isHidden = false
//                case "jeux":
//                    ui_picto_4.isHidden = false
//                case "sport":
//                    ui_picto_1.isHidden = false
//                case "nature":
//                    ui_picto_8.isHidden = false
//                case "cuisine":
//                    ui_picto_9.isHidden = false
//                case "marauding":
//                    ui_picto_10.isHidden = false
//                default:
//                    break
//                }
//            }
//        }
    }

    func hidePictos() {
        ui_picto_1.isHidden = true
        ui_picto_2.isHidden = true
        ui_picto_3.isHidden = true
        ui_picto_4.isHidden = true
        ui_picto_5.isHidden = true
        ui_picto_6.isHidden = true
        ui_picto_7.isHidden = true
        ui_picto_8.isHidden = true
        ui_picto_9.isHidden = true
        ui_picto_10.isHidden = true
    }
    
}

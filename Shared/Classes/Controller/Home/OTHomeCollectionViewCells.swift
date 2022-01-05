//
//  OTHomeCollectionViewCell.swift
//  entourage
//
//  Created by Jr on 11/03/2021.
//  Copyright © 2021 Entourage. All rights reserved.
//

import Foundation

//MARK: - OTHomeCollectionViewCell -
class OTHomeCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var ui_picto_action: UIImageView!
    @IBOutlet weak var ui_title_action: UILabel!
    @IBOutlet weak var ui_title_description: UILabel!
    
    @IBOutlet weak var ui_title_location: UILabel!
    @IBOutlet weak var ui_picto_location: UIImageView!
    
    @IBOutlet weak var ui_info_action_by: UILabel?
    @IBOutlet weak var ui_button_profile: UIButton!
    @IBOutlet weak var ui_picto_check_profile: UIImageView!
    @IBOutlet weak var ui_title_profile: UILabel!
    
    @IBOutlet weak var ui_title_nb_people: UILabel?
    
    @IBOutlet weak var ui_info_show_more: UILabel?
    
    weak var delegate:CellClickDelegate? = nil
    
    var item = OTEntourage()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.masksToBounds = true
    }
    
    func updateCell(item:OTEntourage,delegate:CellClickDelegate?) {
        self.delegate = delegate
        self.item = item
        if item.groupType == "outing" {
            ui_title_action.text = OTLocalisationService.getLocalizedValue(forKey: item.groupType)
            ui_title_action.textColor = UIColor.appOrange()
            ui_info_show_more?.text = OTLocalisationService.getLocalizedValue(forKey: "show_more_event")
            ui_info_action_by?.text = OTLocalisationService.getLocalizedValue(forKey: "home_event_info_user")
        }
        else {
            ui_title_action.text = OTLocalisationService.getLocalizedValue(forKey: item.entourage_type)
            ui_info_show_more?.text = OTLocalisationService.getLocalizedValue(forKey: "show_more")

            if item.entourage_type == "contribution" {
                ui_title_action.textColor = UIColor.appBlue()
                ui_info_action_by?.text = OTLocalisationService.getLocalizedValue(forKey: "home_action_contrib_info_user")
            }
            else {
                ui_title_action.textColor = UIColor.appOrange()
                ui_info_action_by?.text = OTLocalisationService.getLocalizedValue(forKey: "home_action_info_user")
            }
        }

        ui_title_description.text = item.title
        ui_title_profile.text = item.author.displayName

        //Picto
        if let pictoStr = OTAppAppearance.iconName(forEntourageItem: item, isAnnotation: false) {
            ui_picto_action.image = UIImage.init(named: pictoStr)
        }

        if item.isOnline.boolValue {
            ui_title_location.text = OTLocalisationService.getLocalizedValue(forKey: "info_feed_item_event_online")
        }
        else {
            let distance = HomeCellUtils.getDistance(item: item)
            var distanceStr = ""

            if distance < 1000000 {
                distanceStr = HomeCellUtils.formattedItemDistance(distance: distance)
                if distanceStr.count > 0 {
                    distanceStr = String.init(format: "%@ - ", distanceStr)
                }
            }
            else {
                distanceStr = ""
            }
            ui_title_location.text = String.init(format: "%@%@", distanceStr,item.postalCode)
        }

        if OTAppConfiguration.shouldShowCreatorImagesForNewsFeedItems() {
            ui_button_profile.setupAsProfilePicture(fromUrl: item.author.avatarUrl)
            ui_button_profile.isHidden = false

            if item.author.partner == nil {
                ui_picto_check_profile.isHidden = true
            }
            else {
                ui_picto_check_profile.isHidden = false
                ui_picto_check_profile.setup(fromUrl: item.author.partner.smallLogoUrl, withPlaceholder: "badgeDefault")
            }
        }
        else {
            ui_button_profile.isHidden = true
            ui_picto_check_profile.isHidden = true
        }

        let nbPeople = item.noPeople.intValue
        if nbPeople == 1 {
            ui_title_nb_people?.text = "\(nbPeople) \(OTLocalisationService.getLocalizedValue(forKey: "participant")!)"
        }
        else {
            ui_title_nb_people?.text = "\(nbPeople) \(OTLocalisationService.getLocalizedValue(forKey: "participants")!)"
        }
    }
    
    func updateCellVariant(item:OTEntourage,delegate:CellClickDelegate?) {
        self.delegate = delegate
        self.item = item
        
        let cat = getCat(type: item.type, category: item.category)
        
        ui_title_action.text = cat.title_list
        ui_info_show_more?.text = OTLocalisationService.getLocalizedValue(forKey: "show_more")
    
        ui_title_description.text = item.title
        ui_title_profile.text = item.author.displayName
        
        //Picto
        if let pictoStr = OTAppAppearance.iconName(forEntourageItem: item, isAnnotation: false) {
            ui_picto_action.image = UIImage.init(named: pictoStr)
        }
        
        let distance = HomeCellUtils.getDistance(item: item)
        var distanceStr = ""
        
        if distance < 1000000 {
            distanceStr = HomeCellUtils.formattedItemDistance(distance: distance)
            if distanceStr.count > 0 {
                distanceStr = String.init(format: "%@ - ", distanceStr)
            }
        }
        if item.postalCode.count == 0 && distanceStr.count == 0 {
            distanceStr = " "
        }
        ui_title_location.text = String.init(format: "%@%@", distanceStr,item.postalCode)
        
        
        if OTAppConfiguration.shouldShowCreatorImagesForNewsFeedItems() {
            ui_button_profile.setupAsProfilePicture(fromUrl: item.author.avatarUrl)
            ui_button_profile.isHidden = false
            
            if item.author.partner == nil {
                ui_picto_check_profile.isHidden = true
            }
            else {
                ui_picto_check_profile.isHidden = false
                ui_picto_check_profile.setup(fromUrl: item.author.partner.smallLogoUrl, withPlaceholder: "badgeDefault")
            }
        }
        else {
            ui_button_profile.isHidden = true
            ui_picto_check_profile.isHidden = true
        }
    }
    
    func getCat(type:String,category:String) -> OTCategory {
        var cat = OTCategory.init()
        if let _array = OTCategoryFromJsonService.getData() as? [OTCategoryType] {
            
            for item in _array {
                if item.type == type {
                    for _item2 in item.categories {
                        if let _cat = _item2 as? OTCategory {
                            if _cat.category == category {
                                cat = _cat
                                break
                            }
                        }
                    }
                    break
                }
            }
        }
        return cat
    }
    
    @IBAction func action_show_profile(_ sender: UIButton) {
        self.delegate?.showDetailUser(userId: item.author.uID)
    }
}

//MARK: - OTHomeEventCollectionViewCell -
class OTHomeEventCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ui_main_view: UIView?
    @IBOutlet weak var ui_image_event: UIImageView!
    
    @IBOutlet weak var ui_title_description: UILabel!
    
    @IBOutlet weak var ui_title_event_date: UILabel!
    @IBOutlet weak var ui_title_location: UILabel!
    @IBOutlet weak var ui_picto_location: UIImageView!
    @IBOutlet weak var ui_title_nb_people: UILabel!
    
    @IBOutlet weak var ui_info_show_more: UILabel?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.masksToBounds = true
        
        ui_info_show_more?.text = OTLocalisationService.getLocalizedValue(forKey: "show_more")
    }
    
    func updateCell(item:OTEntourage) {
        
        ui_title_description.text = item.title
        
        ui_title_event_date.text = HomeCellUtils.formatEventDate(item: item).uppercased()
        
        if item.isOnline.boolValue {
            ui_title_location.text = OTLocalisationService.getLocalizedValue(forKey: "info_feed_item_event_online")
        }
        else {
            let distance = HomeCellUtils.getDistance(item: item)
            var distanceStr = ""
            
            if distance < 1000000 {
                distanceStr = HomeCellUtils.formattedItemDistance(distance: distance)
                if distanceStr.count > 0 {
                    distanceStr = String.init(format: "%@ - ", distanceStr)
                }
            }
            else {
                distanceStr = ""
            }
            ui_title_location.text = String.init(format: "%@%@", distanceStr,item.postalCode)
        }
        
        let nbPeople = item.noPeople.intValue
        if nbPeople == 1 {
            ui_title_nb_people?.text = "\(nbPeople) \(OTLocalisationService.getLocalizedValue(forKey: "participant")!)"
        }
        else {
            ui_title_nb_people?.text = "\(nbPeople) \(OTLocalisationService.getLocalizedValue(forKey: "participants")!)"
        }
        
        if let url = item.entourage_event_url_image_landscape {
            ui_image_event.setup(fromUrl: url, withPlaceholder: "ic_placeholder_event_horizontal")
        }
    }
}

//MARK: - OTHomeImageCollectionViewCell -
class OTHomeImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var ui_image: UIImageView!
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_view_trans: UIView!
    @IBOutlet weak var ui_view_show_more: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.masksToBounds = true
        
        ui_view_trans.isHidden = true
        ui_view_show_more.isHidden = true
        ui_title.isHidden = true
        
        self.ui_image.layer.cornerRadius = 8
    }
    
    func updateCell(title:String, imageUrl:String) {
        if imageUrl.count == 0 {
            self.ui_view_show_more.isHidden = false
            self.ui_title.isHidden = false
            self.ui_title.text = title
            self.ui_image.image = UIImage()
            return
        }
        
        ui_image.setup(fromUrl: imageUrl, withPlaceholder: nil) { (request, response, _image) in
            self.ui_image.image = _image
            self.ui_view_trans.isHidden = true
            self.ui_view_show_more.isHidden = true
            self.ui_title.isHidden = true
        } failure: { (request, response, error) in
            self.ui_view_show_more.isHidden = false
            self.ui_title.isHidden = false
            self.ui_title.text = title
            self.ui_image.image = UIImage()
        }
    }
}

//MARK: - OTHomeCellOther -
class OTHomeCellOther: UICollectionViewCell {
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_image: UIImageView?
    @IBOutlet weak var ui_label_more: UILabel!
    @IBOutlet weak var ui_image_bottom: UIImageView?
    var isShowZone = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.layer.cornerRadius = 8.0
        self.contentView.layer.masksToBounds = true
        self.ui_image_bottom?.isHidden = true
    }
    
    func populateCell(title:String,isShowZone:Bool, isAction:Bool) {
        ui_title.text = title
        self.isShowZone = isShowZone
        self.ui_image_bottom?.isHidden = true
        self.ui_image?.isHidden = false
        
        if !isAction {
            self.contentView.backgroundColor = UIColor.appOrange()
        }
        else {
            self.contentView.backgroundColor = UIColor.init(red: 158 / 255.0, green: 158 / 255.0, blue: 158 / 255.0, alpha: 1.0)
        }
    }
    
    func populateCell(title:String,buttonMoreTxt:String) {
        ui_title.text = title
        self.isShowZone = false
        self.contentView.backgroundColor = UIColor.appOrange()
        ui_label_more.text = buttonMoreTxt
        self.ui_image?.isHidden = true
        self.ui_image_bottom?.isHidden = false
    }
}


//MARK: - HomeCell Utils -
struct HomeCellUtils {
    static func getDistance(item:OTEntourage) -> Double {
        if item.location == nil {
            return -1
        }
        if let currentLocation = OTLocationManager.sharedInstance()?.currentLocation {
            return currentLocation.distance(from: item.location)
        }
        return -1
    }
    
    static func formattedItemDistance(distance:Double) -> String {
        if distance < 0 {
            return ""
        }
        var distanceAmount:Int
        
        if distance < 1000 {
            distanceAmount = Int(round(distance))
        }
        else {
            distanceAmount = Int(round(distance / 1000))
        }
        
        let distanceQualifier = distance < 1000 ? "m" : "km"
        
        let distanceStr = String.init(format: "%d%@", distanceAmount, distanceQualifier)
        
        return String.init(format: OTLocalisationService.getLocalizedValue(forKey: "entourage_distance"),distanceStr)
    }
    
    static func formatEventDate(item:OTEntourage) -> String {
        var dateString = ""
        //  let eventName = OTLocalisationService.getLocalizedValue(forKey: "event")!.capitalized
        
        if item.startsAt != nil {
            if NSCalendar.current.isDate(item.startsAt, inSameDayAs: item.endsAt) {
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "EEEE dd/MM"
                let _dateStr = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "le_"), dateFormat.string(from: item.startsAt))
                //dateString = String.init(format: "%@ %@", eventName,_dateStr)
                dateString = _dateStr
            }
            else {
                let dateFormat = DateFormatter()
                dateFormat.dateFormat = "dd/MM"
                
                let _dateStr = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "du_au"), dateFormat.string(from: item.startsAt),dateFormat.string(from: item.endsAt))
                //dateString = String.init(format: "%@ %@", eventName,_dateStr)
                dateString = _dateStr
            }
        }
        
        return dateString
    }
}

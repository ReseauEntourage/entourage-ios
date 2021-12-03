//
//  OTDetailActionEventTopCell.swift
//  entourage
//
//  Created by Jr on 03/11/2020.
//  Copyright © 2020 Entourage. All rights reserved.
//

import UIKit
import TTTAttributedLabel

//MARK: - OTDetailActionEventTopCell -
class OTDetailActionEventTopCell: UITableViewCell {
    
    @IBOutlet weak var ui_constraint_image_height: NSLayoutConstraint?
    
    @IBOutlet weak var ui_constraint_image_ratio: NSLayoutConstraint?
    
    @IBOutlet weak var ui_image_top: UIImageView?
    
    @IBOutlet weak var ui_constraint_height_view_status: NSLayoutConstraint?
    @IBOutlet weak var ui_label_status: UILabel?
    
    
    
    @IBOutlet weak var ui_title: UILabel!
    @IBOutlet weak var ui_view_button_join: UIView?
    @IBOutlet weak var ui_view_button_share: UIView?
    @IBOutlet weak var ui_label_button_action: UILabel?
    @IBOutlet weak var ui_image_button_action: UIImageView?
    
    @IBOutlet weak var ui_label_button_joined: UILabel?
    @IBOutlet weak var ui_view_button_joined: UIView?
    @IBOutlet weak var ui_label_private: TTTAttributedLabel?
    @IBOutlet weak var ui_view_private: UIView?
    @IBOutlet weak var ui_constraint_height_view_private: NSLayoutConstraint?
    let view_private_height:CGFloat = 44
    
    weak var delegate:ActionCellTopDelegate? = nil
    var isJoinAccepted = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_button_join?.layer.borderWidth = 1
        ui_view_button_join?.layer.cornerRadius = 8
        ui_view_button_join?.layer.borderColor = UIColor.appOrange()?.cgColor
        ui_view_button_share?.layer.cornerRadius = 8
        ui_view_button_joined?.layer.cornerRadius = 8
        ui_view_button_joined?.isHidden = true
        ui_constraint_height_view_private?.constant = 0
        ui_view_private?.isHidden = true
    }
    
    @objc func populate(feedItem:OTEntourage) {
        populate(feedItem: feedItem, delegate: nil)
    }
    
    
    func populate(feedItem:OTEntourage,delegate:ActionCellTopDelegate?) {
        self.delegate = delegate
        
        if feedItem.isOuting()  {
            ui_image_top?.image = UIImage.init(named: "placeholder_event")
            
            ImageLoaderSwift.getImage(from: feedItem.entourage_event_url_image_landscape) { image in
                if let _img = image {
                    self.ui_image_top?.image = _img
                }
                else {
                    self.ui_image_top?.image = UIImage.init(named: "ic_placeholder_event_horizontal")
                }
            }
            
            if feedItem.status == "full" {
                ui_label_status?.text = OTLocalisationService.getLocalizedValue(forKey: "info_event_closed").uppercased()
                ui_constraint_height_view_status?.constant = 40
                ui_label_status?.isHidden = false
            }
            else {
                ui_constraint_height_view_status?.constant = 0
                ui_label_status?.isHidden = true
            }
        }
        
        if !feedItem.isPublicEntourage() {
            ui_label_private?.text = feedItem.isOuting() ? OTLocalisationService.getLocalizedValue(forKey: "info_event_private") : OTLocalisationService.getLocalizedValue(forKey: "info_action_private")
            ui_constraint_height_view_private?.constant = view_private_height
            ui_view_private?.isHidden = false
        }
        
        ui_title.text = feedItem.title
        
        var title = ""
        switch feedItem.joinStatus {
        case JOIN_ACCEPTED:
            isJoinAccepted = true
            title = OTLocalisationService.getLocalizedValue(forKey: "join_active_other")
            ui_label_button_joined?.text = title.uppercased()
            ui_view_button_joined?.isHidden = false
            
        case JOIN_PENDING:
            title = OTLocalisationService.getLocalizedValue(forKey: "join_pending")
            
            ui_image_button_action?.image = UIImage.init(named: "picto_wait")
            ui_label_button_action?.textColor = UIColor.appOrange()
            ui_view_button_join?.backgroundColor = UIColor(red: 254 / 255.0, green: 239 / 255.0, blue: 233 / 255.0, alpha: 1.0)
        default:
            title = OTLocalisationService.getLocalizedValue(forKey: "join_entourage2_btn")
            if feedItem.isOuting() {
                title = OTLocalisationService.getLocalizedValue(forKey: "join_entourage_btn")
            }
        }
        ui_label_button_action?.text = title.uppercased()
        if feedItem.status == FEEDITEM_STATUS_CLOSED  { //|| feedItem.joinStatus == JOIN_ACCEPTED
            ui_view_button_join?.isHidden = true
        }
        else {
            ui_view_button_join?.isHidden = false
        }
    }
    
    @IBAction func action_join(_ sender: Any) {
        if !isJoinAccepted {
            delegate?.actionJoin()
        }
    }
    
    @IBAction func action_share(_ sender: Any) {
        delegate?.actionShare()
    }
}

//MARK: - ActionCellTopDelegate -
protocol ActionCellTopDelegate: AnyObject {
    func actionJoin()
    func actionShare()
}

//MARK: - OTDetailActionEventDateCell -
class OTDetailActionEventDateCell: UITableViewCell {
    
    @IBOutlet weak var ui_picto: UIImageView!
    @IBOutlet weak var ui_label_event: TTTAttributedLabel!
    
    @objc func populate(feedItem:OTFeedItem) {
        let _DateStr = Utils.eventInfoDescrioption(startDate: feedItem.startsAt, endDate: feedItem.endsAt)
        ui_label_event.text = _DateStr
    }
}

//MARK: - OTDetailActionEventLocationCell -
class OTDetailActionEventLocationCell: UITableViewCell, TTTAttributedLabelDelegate {
    @IBOutlet weak var ui_postalCode: TTTAttributedLabel!
    @IBOutlet weak var ui_picto: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_postalCode.delegate = self
        
        self.ui_postalCode.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.address.rawValue
        self.ui_postalCode.textColor = ApplicationTheme.shared().titleLabelColor
        
        self.ui_postalCode.linkAttributes = [NSAttributedString.Key.font:UIFont(name: "SFUIText-Bold", size: 15.0) as Any,
                                             NSAttributedString.Key.foregroundColor: ApplicationTheme.shared().addActionButtonColor,
                                             NSAttributedString.Key.underlineColor: ApplicationTheme.shared().addActionButtonColor,
                                             NSAttributedString.Key.underlineStyle:  NSUnderlineStyle.single.rawValue]
    }
    
    @objc func populate(feedItem:OTFeedItem) {
        
        if feedItem.isAction() {
            ui_postalCode.text = feedItem.postalCode
            if feedItem.postalCode.count == 0 {
                ui_postalCode.text = " - "
            }
            ui_picto.image = UIImage.init(named: "ic_detail_poi_location")
        }
        else {
            if feedItem.isEventOnline() {
                self.ui_postalCode.enabledTextCheckingTypes = NSTextCheckingResult.CheckingType.link.rawValue
                
                let link = feedItem.eventUrl != nil ? feedItem.eventUrl! : ""
                ui_postalCode.text = "En ligne\n\(link)"
                ui_picto.image = UIImage.init(named: "ic_detail_event_link")
            }
            else {
                ui_picto.image = UIImage.init(named: "ic_detail_poi_location")
                ui_postalCode.text = feedItem.displayAddress
            }
        }
    }
    
    //MARK: - TTTAttributedLabelDelegate
    func attributedLabel(_ label: TTTAttributedLabel, didSelectLinkWithAddress addressComponents: [AnyHashable : Any]?) {
        
        guard let addressComponents = addressComponents  else {
            return
        }
        
        let strAddress = String.init(format: "http://maps.apple.com/?address=1,%@ %@ %@", addressComponents[NSTextCheckingKey.street] as! CVarArg,addressComponents[NSTextCheckingKey.zip] as! CVarArg,
                                     addressComponents[NSTextCheckingKey.city] as! CVarArg)
        
        if let _strQuery = strAddress.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed), let url = URL.init(string: _strQuery) {
            UIApplication.shared.openURL(url)
        }
    }
    
    func attributedLabel(_ label: TTTAttributedLabel!, didSelectLinkWith url: URL!) {
        UIApplication.shared.openURL(url)
    }
}

//MARK: - OTDetailActionEventCreatorCell -
class OTDetailActionEventCreatorCell: UITableViewCell {
    
    @IBOutlet weak var ui_bt_avatar: UIButton!
    @IBOutlet weak var ui_img_asso: UIImageView!
    
    @IBOutlet weak var ui_label_username: UILabel!
    @IBOutlet weak var ui_label_role: UILabel!
    @IBOutlet weak var ui_button_asso: UIButton!
    @IBOutlet weak var ui_label_information: UILabel!
    
    @IBOutlet weak var ui_label_asso: UILabel?
    @IBOutlet weak var ui_constraint_bottom_username: NSLayoutConstraint!
    @IBOutlet weak var ui_constraint_top_username: NSLayoutConstraint!
    @IBOutlet weak var ui_label_ambassador: UILabel?
    
    weak var delegate:ActionCellCreatorDelegate? = nil
    
    @objc func populate(feedItem:OTFeedItem) {
        populate(feedItem: feedItem,authorUser: nil, delegate: nil)
    }
    
    @objc func populate(feedItem:OTFeedItem,authorUser:OTUser?, delegate:ActionCellCreatorDelegate?) {
        self.delegate = delegate
        
        ui_label_ambassador?.isHidden = true
        
        if feedItem.isNeighborhood() || feedItem.isPrivateCircle() {
            ui_bt_avatar.isHidden = true;
        } else {
            ui_bt_avatar.isHidden = false;
            self.ui_bt_avatar.setupAsProfilePicture(fromUrl: feedItem.author.avatarUrl)
        }
        
        self.ui_img_asso.isHidden = feedItem.author.partner == nil
        if feedItem.author.partner != nil {
            self.ui_img_asso.setup(fromUrl: feedItem.author.partner.smallLogoUrl, withPlaceholder: "badgeDefault")
        }
        
        if feedItem.author.hasToShowRoleAndPartner {
            var roleStr = ""
            if feedItem.author.partner_role_title.count > 0 {
                roleStr = "\(feedItem.author.partner_role_title!) -"
            }
            self.ui_label_role.text = roleStr;
            self.ui_button_asso.isHidden = false
            self.ui_label_asso?.isHidden = false
            
            self.ui_button_asso.setTitle(" ", for: .normal)
            var keyJoined = "info_asso_user"
            if feedItem.author.partner.isFollowing {
                keyJoined = "info_asso_user_joined"
            }
            
            
            let titleButton = String.init(format:"%@ %@", feedItem.author.partner.name,OTLocalisationService.getLocalizedValue(forKey: keyJoined));
            let coloredStr:String = OTLocalisationService.getLocalizedValue(forKey: keyJoined)
            
            let attStr = Utilitaires.formatString(stringMessage: titleButton, coloredTxt: coloredStr, color: UIColor.appOrange(), colorHighlight: UIColor.appOrange(), fontSize: 15, fontWeight: .medium, fontColoredWeight: .bold)
            
            self.ui_label_asso?.attributedText = attStr
            
            self.ui_button_asso.tag = feedItem.author.partner.aid.intValue
        }
        else if let _autUser = authorUser, _autUser.roles.count > 0 {
            for role in _autUser.roles {
                if let roleName = role as? String, roleName == "ambassador" {
                    if let dict = OTAppConfiguration.community()["roles"] as? NSDictionary, let nameDict = dict[roleName] as? NSDictionary {
                        if let title = nameDict["title"] as? String {
                            let attStr = Utilitaires.formatString(stringMessage: "  \(title)  ", coloredTxt: title, color: UIColor.white, colorHighlight: UIColor.white, fontSize: 13, fontWeight: .medium, fontColoredWeight: .bold)
                            self.ui_label_ambassador?.layer.backgroundColor = UIColor.appOrange().cgColor
                            self.ui_label_ambassador?.layer.cornerRadius = 4
                            self.ui_label_ambassador?.attributedText = attStr
                            self.ui_label_ambassador?.isHidden = false
                            self.ui_label_role?.text = ""
                        }
                    }
                    break
                }
            }
        }
        else {
            ui_constraint_top_username.constant = 30
            ui_constraint_bottom_username.constant = 0
            self.ui_label_role.isHidden = true
            self.ui_button_asso.isHidden = true
            self.ui_label_asso?.isHidden = true
        }
        
        self.ui_label_username.text = feedItem.author.displayName
        
        if feedItem.isAction() {
            if feedItem.type == "ask_for_help" {
                self.ui_label_information.text = OTLocalisationService.getLocalizedValue(forKey: "detail_action_creator_help")
            }
            else {
                self.ui_label_information.text = OTLocalisationService.getLocalizedValue(forKey: "detail_action_creator_gift")
            }
        }
        else {
            self.ui_label_information.text = OTLocalisationService.getLocalizedValue(forKey: "detail_action_creator_event")
        }
    }
    
    @IBAction func action_show_profile(_ sender: Any) {
        delegate?.actionShowUser()
    }
    
    @IBAction func action_show_partner(_ sender: Any) {
        delegate?.actionshowPartner()
    }
}

//MARK: - ActionCellCreatorDelegate -
@objc protocol ActionCellCreatorDelegate: class {
    func actionshowPartner()
    func actionShowUser()
}

//MARK: - OTDetailActionEventDescriptionCell -
class OTDetailActionEventDescriptionCell: UITableViewCell {
    @IBOutlet weak var ui_view_description: UIView!
    
    @IBOutlet weak var ui_label_last_update: UILabel!
    @IBOutlet weak var ui_label_description: OTThemedText!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        ui_view_description.layer.cornerRadius = 8
    }
    
    @objc func populate(feedItem:OTEntourage) {
        
        if feedItem.desc == nil || feedItem.desc.count == 0 {
            ui_label_description?.removeFromSuperview()
            ui_view_description?.isHidden = true
        }
        else {
            ui_label_description?.text = feedItem.desc
        }
        
        if !feedItem.isOuting() {
            ui_label_last_update.text = Utils.formattedTimestamp(createDate: feedItem.creationDate, updateDate: feedItem.updatedDate)
        }
    }
}

//MARK: - OTDetailActionEventMapCell -
class OTDetailActionEventMapCell: UITableViewCell {
    @IBOutlet weak var ui_map: MKMapView!
    
    var mapProvider:OTMapAnnotationProviderBehavior? = nil
    
    @objc func populate(feedItem:OTFeedItem) {
        mapProvider = OTMapAnnotationProviderBehavior()
        mapProvider?.map = ui_map
        mapProvider?.configure(with: feedItem)
        mapProvider?.addStartPoint()
        mapProvider?.drawData()
    }
}

//MARK: - Util struct for detail event/action to bypass feeditems factorys !! -
struct Utils {
    static func formattedTimestamp(createDate:Date,updateDate:Date) -> String {
        var createDateStr = formatDaysIntervalFromToday(date: createDate)
        createDateStr = String.init(format: "%@ %@", OTLocalisationService.getLocalizedValue(forKey: "group_timestamps_created_at"),createDateStr)
        
        if Calendar.current.isDateInToday(createDate) {
            return createDateStr
        }
        
        var updateDateStr = formatDaysIntervalFromToday(date: updateDate)
        updateDateStr = String.init(format: "%@ %@", OTLocalisationService.getLocalizedValue(forKey: "group_timestamps_updated_at"),updateDateStr)
        
        return "\(createDateStr) - \(updateDateStr)"
    }
    
    static func formatDaysIntervalFromToday(date:Date) -> String {
        
        if Calendar.current.isDateInToday(date) {
            return OTLocalisationService.getLocalizedValue(forKey: "today")
        }
        if Calendar.current.isDateInYesterday(date) {
            return OTLocalisationService.getLocalizedValue(forKey: "yesterday")
        }
        let _set:Set = [Calendar.Component.day]
        let _days = NSCalendar.current.dateComponents(_set, from: date, to:Date.init())
        
        if let days = _days.day, days < 15 {
            Logger.print("***** days ici : \(days)")
            let daysStr = String.init(format: "%d %@", days,OTLocalisationService.getLocalizedValue(forKey: "days"))
            return String.init(format: OTLocalisationService.getLocalizedValue(forKey: "formatter_time_ago"), daysStr)
        }
        if let days = _days.day, days <= 30 {
            return OTLocalisationService.getLocalizedValue(forKey: "this_month")
        }
        
        if let days = _days.day {
            Logger.print("***** days : \(days) -> \(Double(( days / 30)) + 0.5) ")
            let months = Double(( days / 30)) + 0.5
            let monthsStr = String.init(format: "%d %@", Int(months), OTLocalisationService.getLocalizedValue(forKey: "months"))
            
            return String.init(format: OTLocalisationService.getLocalizedValue(forKey: "formatter_time_ago"), monthsStr)
        }
        return ""
    }
    
    static func eventInfoDescrioption(startDate:Date,endDate:Date) -> String {
        
        let dateFormatter = DateFormatter.init()
        dateFormatter.dateFormat = "EEEE dd MMMM YYYY"
        
        let startDateInfo = dateFormatter.string(from: startDate)
        let startTimeInfo = (startDate as NSDate).toRoundedQuarterTimeString()
        
        
        let endDateInfo = dateFormatter.string(from: endDate)
        let endTimeInfo = (endDate as NSDate).toRoundedQuarterTimeString()
        
        var dateInfoTxt = ""
        
        if Calendar.current.isDate(startDate, inSameDayAs: endDate) {
            let _str = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "Le_"), startDateInfo)
            dateInfoTxt = String.init(format: "%@",_str)
            
            let _dateStr = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "de_a"), startTimeInfo!,endTimeInfo!)
            dateInfoTxt = String.init(format: "%@\n%@", dateInfoTxt,_dateStr)
        }
        else {
            let _dateStartStr = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "Du_a"), startDateInfo,startTimeInfo!)
            let _dateEndStr = String.init(format: OTLocalisationService.getLocalizedValue(forKey: "au_a"), endDateInfo,endTimeInfo!)
            
            dateInfoTxt = String.init(format: "%@ %@", _dateStartStr,_dateEndStr)
        }
        
        return dateInfoTxt
    }
}



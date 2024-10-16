//
//  Neighborhood.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import Foundation
struct Neighborhood:Codable {
    var uid:Int = 0
    var uuid_v2:String = ""
    var name:String = ""
    
    var aboutGroup:String?
    var welcomeMessage:String?
    var membersCount:Int = 0
    
    var address:Address? = nil
    var interests:[String]? = nil
    var members:[MemberLight] = [MemberLight]()
    
    var creator:MemberLight = MemberLight(uid: 0)
    
    var aboutEthics:String? = nil
    var past_outings_count:Int = 0
    var future_outings_count:Int = 0
    var has_ongoing_outing = false
    var national:Bool? = false
    
    var image_url:String?
    var neighborhood_image_id:Int? = nil // Use to pass the image info from the gallery
    var tagOtherMessage:String? = nil
    
    var futureEvents:[Event]?
    var messages:[PostMessage]? = nil
    var isMember = false
    var unreadPostCount:Int? = 0
    
    var isSelected = false
    
    var nameTranslations: Translations? = nil
    var aboutGroupTranslations: Translations? = nil
    var welcomeMessageTranslations: Translations? = nil
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case uuid_v2 = "uuid_v2"
        case name
        case aboutGroup = "description"
        case welcomeMessage = "welcome_message"
        case membersCount = "members_count"
        case image_url = "image_url"
        case aboutEthics = "ethics"
        
        case creator = "user"
        
        case address
        
        case interests
        case members
        
        case past_outings_count
        case future_outings_count
        case has_ongoing_outing
        
        case isMember = "member"
        case messages = "posts"
        case futureEvents = "future_outings"
        case nameTranslations = "name_translations"
        case aboutGroupTranslations = "description_translations"
        case welcomeMessageTranslations = "welcome_message_translations"
        case unreadPostCount = "unread_posts_count"
        case national
    }
    
    func dictionaryForWS() -> [String:Any] {
        var dict = [String:Any]()
        
        if name.count > 0 {
            dict["name"] = name
        }
        
        //TODO: avec la nouvelle version du WS de nico
        if address?.displayAddress?.count ?? 0 > 0 {
            dict["place_name"] = address!.displayAddress!
        }
        if address?.latitude ?? 0 != 0 {
            dict["latitude"] = address!.latitude
        }
        if address?.longitude ?? 0 != 0 {
            dict["longitude"] = address!.longitude
        }
        if address?.google_place_id?.count ?? 0 > 0 {
            dict["google_place_id"] = address!.google_place_id!
        }
        
        if !(aboutGroup?.isEmpty ?? true) {
            dict["description"] = aboutGroup!
        }
        
        if !(aboutEthics?.isEmpty ?? true) {
            dict["ethics"] = aboutEthics!
        }
        if !(welcomeMessage?.isEmpty ?? true) {
            dict["welcome_message"] = welcomeMessage!
        }
        
        if let interests = interests, interests.count > 0 {
            dict["interests"] = interests
        }
       
        if !(image_url?.isEmpty ?? true) {
            dict["image_url"] = image_url!
        }
        
        if let neighborhood_image_id = neighborhood_image_id {
            dict["neighborhood_image_id"] = neighborhood_image_id
        }
        
        if let tagOtherMessage = tagOtherMessage {
            dict["other_interest"] = tagOtherMessage
        }
        
        return dict
    }
}

//MARK: - NeighborhoodImage -
struct NeighborhoodImage:Codable {
    var uid:Int
    var title:String?
    var imageUrl:String
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case title
        case imageUrl = "image_url"
    }
}

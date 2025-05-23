//
//  Neighborhood.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import Foundation

// MARK: - Neighborhood Struct
struct Neighborhood: Codable {
    var uid: Int = 0
    var uuid_v2: String = ""
    var name: String = ""
    
    var aboutGroup: String?
    var welcomeMessage: String?
    var membersCount: Int = 0
    
    var address: Address? = nil
    var interests: [String]? = nil
    var members: [MemberLight] = [MemberLight]()
    
    var creator: MemberLight = MemberLight(uid: 0)
    
    var aboutEthics: String? = nil
    var past_outings_count: Int = 0
    var future_outings_count: Int = 0
    var has_ongoing_outing = false
    var national: Bool? = false
    
    var image_url: String?
    var neighborhood_image_id: Int? = nil // Utilisé pour passer l'info image depuis la galerie
    var tagOtherMessage: String? = nil
    
    var futureEvents: [Event]?
    var messages: [PostMessage]? = nil
    var isMember = false
    var unreadPostCount: Int? = 0
    
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
    
    func dictionaryForWS() -> [String: Any] {
        var dict = [String: Any]()
        
        if name.count > 0 {
            dict["name"] = name
        }
        
        if let displayAddress = address?.displayAddress, !displayAddress.isEmpty {
            dict["place_name"] = displayAddress
        }
        if let latitude = address?.latitude, latitude != 0 {
            dict["latitude"] = latitude
        }
        if let longitude = address?.longitude, longitude != 0 {
            dict["longitude"] = longitude
        }
        if let googlePlaceID = address?.google_place_id, !googlePlaceID.isEmpty {
            dict["google_place_id"] = googlePlaceID
        }
        
        if let aboutGroup = aboutGroup, !aboutGroup.isEmpty {
            dict["description"] = aboutGroup
        }
        
        if let aboutEthics = aboutEthics, !aboutEthics.isEmpty {
            dict["ethics"] = aboutEthics
        }
        if let welcomeMessage = welcomeMessage, !welcomeMessage.isEmpty {
            dict["welcome_message"] = welcomeMessage
        }
        
        if let interests = interests, !interests.isEmpty {
            dict["interests"] = interests
        }
        
        if let image_url = image_url, !image_url.isEmpty {
            dict["image_url"] = image_url
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



// MARK: - NeighborhoodImage Struct
struct NeighborhoodImage: Codable {
    var uid: Int
    var title: String?
    var imageUrl: String
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case title
        case imageUrl = "image_url"
    }
}

//
//  Neighborhood.swift
//  entourage
//
//  Created by Jerome on 01/04/2022.
//

import Foundation
struct Neighborhood:Codable {
    var uid:Int = 0
    var name:String = ""
    var aboutGroup:String?
    var welcomeMessage:String?
    var membersCount:Int = 0
    
    var address:Address? = nil
    var interests:[String]? = nil
    var members:[NeighborhoodUserLight] = [NeighborhoodUserLight]()
    
    var creator:NeighborhoodUserLight = NeighborhoodUserLight(uid: 0)
    
    var aboutEthics:String? = nil
    var past_outings_count:Int = 0
    var future_outings_count:Int = 0
    var has_ongoing_outing = false
    
    var image_url:String?
    var neighborhood_image_id:Int? = nil // Use to pass the image info from the gallery
    var tagOtherMessage:String? = nil
    
    var futureEvents:[Event]?
    var messages:[PostMessage]? = nil
    var isMember = false
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
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
        if address?.location?.coordinate.latitude ?? 0 > 0 {
            dict["latitude"] = address!.location!.coordinate.latitude
        }
        if address?.location?.coordinate.longitude ?? 0 > 0 {
            dict["longitude"] = address!.location!.coordinate.longitude
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

//MARK: - NeighborhoodUserLight -
struct NeighborhoodUserLight:Codable {
    var uid:Int
    var username:String?
    var imageUrl:String?
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case username = "display_name"
        case imageUrl = "avatar_url"
    }
}


struct PostMessage:Codable {
    var uid:Int = 0
    var content:String = ""
    
    var createdDate:Date {
        get {
            return Utils.getDateFromWSDateString(createdDateString)
        }
    }
    var createdDateFormatted:String {
        get {
            return Utils.formatEventDate(date:createdDate)
        }
    }
    
    var createdDateTimeFormatted:String {
        get {
            return Utils.formatEventDateTime(date:createdDate)
        }
    }
    
    var isPostImage:Bool {
        get {
            return messageImageUrl != nil
        }
    }
    
    var createdDateString:String = ""
    var messageType:String = ""
    var parentPostId:Int? = nil
    var hasComments:Bool? = false
    var user:UserLightNeighborhood? = nil
    var commentsCount:Int = 0
    var messageImageUrl:String? = nil
    
    var isRetryMsg = false
    
    private var read:Bool? = nil
    var isRead:Bool {
        get {
            return read ?? false
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case content
        case user
        case createdDateString = "created_at"
        case messageType = "message_type"
        case parentPostId = "post_id"
        case hasComments = "has_comments"
        case commentsCount = "comments_count"
        case messageImageUrl = "image_url"
        case read
    }
}
//
//  GlobalObjects.swift
//  entourage
//
//  Created by Jerome on 12/07/2022.
//

import Foundation


//MARK: - Messages Post + Comments -
struct PostMessage:Codable {
    var uid:Int = 0
    var content:String? = ""
    
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
    var parentPostId:Int? = nil
    var hasComments:Bool? = false
    var user:UserLightNeighborhood? = nil
    var commentsCount:Int? = 0
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
        case parentPostId = "post_id"
        case hasComments = "has_comments"
        case commentsCount = "comments_count"
        case messageImageUrl = "image_url"
        case read
    }
}


//MARK: -MemberLight use on feed -> Event/neighborhood -
struct MemberLight:Codable {
    var uid:Int
    var username:String?
    var imageUrl:String?
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case username = "display_name"
        case imageUrl = "avatar_url"
    }
}

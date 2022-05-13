//
//  Entourage.swift
//  entourage
//
//  Created by Jerome on 12/05/2022.
//

import Foundation


struct Event:Codable {
    var uid:Int
    var uuid:String
    var title:String
    var descriptionEvent:String? = nil
    
    var shareUrl:String? = nil
    var imageUrl:String? = nil
    var isOnline:Bool? = false
    var onlineEventUrl:String? = nil
    
    var author:EventAuthor? = nil
    
    var location:EventLocation? = nil
    
    var metadata:EventMetadata? = nil
    
    var startDate:Date {
        get {
            return Utils.getDateFromWSDateString(metadata?.starts_at)
        }
    }
    var startDateFormatted:String {
        get {
            return Utils.formatEventDate(date:startDate)
        }
    }
    var endDate:Date{
        get {
            return Utils.getDateFromWSDateString(metadata?.ends_at)
        }
    }
    var endDateFormatted:String {
        get {
            return Utils.formatEventDate(date:endDate)
        }
    }
    
    var addressName:String {
        get {
            return metadata?.place_name ?? "-"
        }
    }
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case uuid
        case title
        case descriptionEvent = "description"
        case shareUrl = "share_url"
        case imageUrl = "image_url"
        case isOnline = "online"
        case onlineEventUrl = "event_url"
        
        case author
        case location
        case metadata
    }
}

struct EventLocation:Codable {
    var latitude:Double? = nil
    var longitude:Double? = nil
    
    enum CodingKeys: String, CodingKey {
        case latitude
        case longitude
    }
}

struct EventMetadata:Codable {
    var starts_at:String
    var ends_at:String
    var place_name:String
    var street_address:String
    var google_place_id:String
}

struct EventAuthor:Codable {
    var uid:Int
    var displayName:String
    var avatarURL:String? = nil
    var partner:Partner? = nil
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case displayName = "display_name"
        case avatarURL = "avatar_url"
        case partner
    }
}

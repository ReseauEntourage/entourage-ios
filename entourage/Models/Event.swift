//
//  Event.swift
//  entourage
//
//

import Foundation


struct Event:Codable {
    var uid:Int = 0
    var uuid:String = ""
    var title:String = ""
    var descriptionEvent:String? = nil
    
    var shareUrl:String? = nil
  //  var imageUrl:String? = nil
    var imageId:Int? = nil
    
    var isOnline:Bool? = false
    var onlineEventUrl:String? = nil
    
    var author:EventAuthor? = nil
    
    var location:EventLocation? = nil
    
    var metadata:EventMetadata? = nil
    
    var interests:[String]? = nil
    var tagOtherMessage:String? = nil
    
    var neiborhoodIds:[Int]? = nil
    
    var recurrence:EventRecurrence = .once
    
    private var _startDate:Date? = nil
    var startDate:Date? {
        set {
            _startDate = newValue
            
            if let _value = newValue {
                metadata?.starts_at = "\(_value)"
            }
            else {
                metadata?.starts_at = nil
            }
        }
        get {
            return _startDate
        }
    }
    
    var startDateFormatted:String {
        get {
            return Utils.formatEventDate(date:Utils.getDateFromWSDateString(metadata?.starts_at))
        }
    }
    
    private var _endDate:Date? = nil
    var endDate:Date? {
        set {
            _endDate = newValue
            if let _value = newValue {
                metadata?.ends_at = "\(_value)"
            }
            else {
                metadata?.ends_at = nil
            }
        }
        get { return _endDate }
    }
    
    func getStartEndDate() -> (startDate:Date,endDate:Date) {
        return (Utils.getDateFromWSDateString(metadata?.starts_at),Utils.getDateFromWSDateString(metadata?.ends_at))
    }
    
    var endDateFormatted:String {
        get {
            return Utils.formatEventDate(date:Utils.getDateFromWSDateString(metadata?.ends_at))
        }
    }
    
    var addressName:String? {
        set { metadata?.display_address = newValue }
        get {
            return metadata?.display_address ?? "-"
        }
    }
    
    var imageUrl:String? {
        get {
            if metadata?.portrait_url != nil {
                return metadata?.portrait_url
            }
            return metadata?.landscape_url
        }
    }
    
    enum CodingKeys: String, CodingKey {
        case uid = "id"
        case uuid
        case title
        case descriptionEvent = "description"
        case shareUrl = "share_url"
       // case imageUrl = "image_url"
        case isOnline = "online"
        case onlineEventUrl = "event_url"
        
        case author
        case location
        case metadata
        
        case interests
        case neiborhoodIds = "neighborhood_ids"
        case imageId = "entourage_image_id"
    }
    
    func dictionaryForWS() -> [String:Any] {
        var dict = [String:Any]()
        
        if title.count > 0 {
            dict["title"] = title
        }
        
        if !(descriptionEvent?.isEmpty ?? true) {
            dict["description"] = descriptionEvent!
        }
        
        if let imageId = imageId {
            dict["entourage_image_id"] = imageId
        }
        
        if location?.latitude ?? 0 > 0 {
            dict["latitude"] = location!.latitude
        }
        else {
            dict["latitude"] = 0
        }
        
        if location?.longitude ?? 0 > 0 {
            dict["longitude"] = location!.longitude
        }
        else {
            dict["longitude"] = 0
        }
        
        //Interests
        if let interests = interests, interests.count > 0 {
            dict["interests"] = interests
        }
        if let tagOtherMessage = tagOtherMessage {
            dict["other_interest"] = tagOtherMessage
        }
        
        
        if let event_url = onlineEventUrl {
            dict["event_url"] = event_url
        }
        
        if let isOnline = isOnline {
            dict["online"] = isOnline
        }
        else {
            dict["online"] = false
        }
        
        if let neiborhoodIds = neiborhoodIds, neiborhoodIds.count > 0 {
            dict["neighborhood_ids"] = neiborhoodIds
        }
        
        //MEtadatas
        var metadatas = [String:Any]()
        if addressName?.count ?? 0 > 0 {
            metadatas["place_name"] = addressName!
        }
        else {
            metadatas["place_name"] = ""
        }
        
        if metadata?.street_address.count ?? 0 > 0 {
            metadatas["street_address"] = metadata?.street_address
        }
        else {
            metadatas["street_address"] = ""
        }
       
        if metadata?.google_place_id?.count ?? 0 > 0 {
            metadatas["google_place_id"] = metadata!.google_place_id!
        }
        else {
            metadatas["google_place_id"] = ""
        }
        
        if metadata?.starts_at?.count ?? 0 > 0 {
            metadatas["starts_at"] = metadata!.starts_at!
        }
        else {
            metadatas["starts_at"] = ""
        }
        
        if metadata?.ends_at?.count ?? 0 > 0 {
            metadatas["ends_at"] = metadata!.ends_at!
        }
        else {
            metadatas["ends_at"] = ""
        }
        
        if let place = metadata?.place_limit , place > 0 {
            metadatas["place_limit"] = place
        }

        dict["metadata"] = metadatas
        
        return dict
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
    var starts_at:String? = nil
    var ends_at:String? = nil
    var place_name:String = ""
    var street_address:String = ""
    var google_place_id:String? = nil
    var display_address:String? = nil
    var place_limit:Int? = 0
    var portrait_url:String? = nil
    var landscape_url:String? = nil
    
    var hasPlaceLimit:Bool = false
    
    enum CodingKeys: String, CodingKey {
        case starts_at
        case ends_at
        case place_name
        case street_address
        case google_place_id
        case display_address
        case place_limit
        case portrait_url
        case landscape_url
    }
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

//MARK: - NeighborhoodImage -
struct EventImage:Codable {
    var id:Int
    var title:String?
    var url_image_landscape:String? = ""
    var url_image_landscape_small:String? = ""
    var url_image_portrait:String? = ""
    var url_image_portrait_small:String? = ""
    
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case url_image_landscape = "landscape_url"
        case url_image_landscape_small = "landscape_small_url"
        case url_image_portrait = "portrait_url"
        case url_image_portrait_small = "portrait_small_url"
    }
}


enum EventRecurrence: Int {
    case once = 1
    case week = 2
    case every2Weeks = 3
    case month = 4
}

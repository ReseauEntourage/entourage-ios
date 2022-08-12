//
//  Action.swift
//  entourage
//
//  Created by Jerome on 01/08/2022.
//

import Foundation


struct Action:Codable {
    var id:Int = 0
    var uuid:String = ""
    var status:String = ""
    
    var title:String? = nil
    var description:String? = nil
    var imageUrl:String? = nil
    var author:EventAuthor? = nil
    
    var sectionName:String? = nil
    var location:EventLocation? = nil
    
    var keyImage:String? = nil
    var metadata:ActionMetadata? = nil
    
    private var actionType:String? = nil
    
    private var statusChangedAt:String? = nil
    private var createdAt:String? = nil
    private var updatedAt:String? = nil
    
    func getChangedStatusDate() -> Date? {
        return statusChangedAt == nil ? nil : Utils.getDateFromWSDateString(statusChangedAt)
    }
    
    func getCreatedDate(capitalizeFirst:Bool = true) -> String {
        let createdDate = Utils.getDateFromWSDateString(createdAt)
        
        let dateStr = Utils.formatActionDateName(date: createdDate, capitalizeFirst: capitalizeFirst)
        
        return dateStr
    }
    
    func isCanceled() -> Bool {
        return status == "closed"
    }
    mutating func setCancel() {
        status = "closed"
    }
    
    func isContrib() -> Bool {
        return actionType == "contribution"
    }
    
    func isMine() -> Bool {
        if let _userId = UserDefaults.currentUser?.sid {
            return _userId == author?.uid
        }
        return false
    }
    
    enum CodingKeys: String, CodingKey {
        case id = "id"
        case uuid
        case status
        case title
        case description
        case imageUrl = "image_url"
        case sectionName = "section"
        
        case author
        case location
        case metadata
        
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case statusChangedAt = "status_changed_at"
        case actionType = "action_type"
    }
    
    func dictionaryForWS() -> [String:Any] {
        var dict = [String:Any]()
        
        if title?.count ?? 0 > 0 {
            dict["title"] = title!
        }
        
        if !(description?.isEmpty ?? true) {
            dict["description"] = description!
        }
        if sectionName?.count ?? 0 > 0 {
            dict["section"] = sectionName!
        }
        
        if location?.latitude ?? 0 != 0 && location?.longitude ?? 0 != 0 {
            var locationDict = [String:Double]()
            
            locationDict["latitude"] = location?.latitude
            locationDict["longitude"] = location?.longitude
            dict["location"] = locationDict
        }
        
        if let keyImage = keyImage {
            dict["image_url"] = keyImage
        }
        
        if dict.count > 0 {
            dict["recipient_consent_obtained"] = true
        }
        
        return dict
    }
}


struct ActionMetadata:Codable {
    var city:String? = nil
    var displayAddress:String? = nil
    
    enum CodingKeys: String, CodingKey {
        case city
        case displayAddress = "display_address"
    }
}

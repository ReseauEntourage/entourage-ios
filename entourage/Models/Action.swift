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
    
    private var statusChangedAt:String? = nil
    private var createdAt:String? = nil
    private var updatedAt:String? = nil
    
    func getChangedStatusDate() -> Date? {
        return statusChangedAt == nil ? nil : Utils.getDateFromWSDateString(statusChangedAt)
    }
    
    func getCreateUpdateDate() -> (dateStr:String,isCreated:Bool) {
        var date:Date? = nil
        var isCreated = true
        
        let createdDate = Utils.getDateFromWSDateString(createdAt)
        let updateDate = Utils.getDateFromWSDateString(updatedAt)
        
        isCreated = createdDate == updateDate
        date = isCreated ?  createdDate : updateDate
        
        let dateStr = Utils.formatEventDateName(date: date)
        
        return (dateStr,isCreated)
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
        
        case createdAt = "created_at"
        case updatedAt = "updated_at"
        case statusChangedAt = "status_changed_at"
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
        
        dict["recipient_consent_obtained"] = true
        
        
        
        
        if location?.latitude ?? 0 > 0 && location?.longitude ?? 0 > 0 {
            var locationDict = [String:Double]()
            
            locationDict["latitude"] = location?.latitude
            locationDict["longitude"] = location?.longitude
            dict["location"] = locationDict
        }
        else {
            var locationDict = [String:Double]()
            
            locationDict["latitude"] = 0
            locationDict["longitude"] = 0
            dict["location"] = locationDict
        }
        
        if let keyImage = keyImage {
            dict["image_url"] = keyImage
        }
        
        return dict
    }
}
